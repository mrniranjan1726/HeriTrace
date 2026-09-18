import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import '../models/product.dart';
import '../models/auction.dart';

class FirebaseService {
  // ============================================================
  // FIREBASE INSTANCES
  // ============================================================

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => auth.currentUser;

  String? get currentUserId => auth.currentUser?.uid;

  bool get isLoggedIn => auth.currentUser != null;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<UserCredential> register(
    String email,
    String password, {
    String role = 'artisan',
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create user account.');
      }

      // Create the user's Firestore profile.
      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim(),
        'role': role.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Registration failed. Please try again.');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserCredential> login(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Login failed. Please try again.');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await auth.signOut();
  }

  Future<String> uploadImage(Uint8List bytes, String path) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first.');
    }

    try {
      final reference = FirebaseStorage.instance.ref().child(path);
      await reference.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await reference.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Could not upload image: ${e.message ?? e.code}');
    }
  }

  // ============================================================
  // GET CURRENT USER ROLE
  // ============================================================

  Future<String> getUserRole() async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    try {
      final snapshot = await db.collection('users').doc(user.uid).get();

      if (!snapshot.exists) {
        // If an old account doesn't have a profile,
        // create a default artisan profile.
        await db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'role': 'artisan',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return 'artisan';
      }

      final data = snapshot.data();

      final role = data?['role']?.toString().trim().toLowerCase();

      if (role == null || role.isEmpty) {
        return 'artisan';
      }

      return role;
    } catch (e) {
      throw Exception('Unable to load your account role. Please try again.');
    }
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> saveProduct(Product product) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please login first.');
    }

    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(product.id)
          .set(product.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Exception('Could not save product: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Could not save product. Please try again.');
    }
  }

  // ============================================================
  // GET CURRENT ARTISAN PRODUCTS
  // ============================================================

  Stream<List<Product>> products() {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return const Stream<List<Product>>.empty();
    }

    return db
        .collection('users')
        .doc(uid)
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return Product.fromMap(document.id, document.data());
          }).toList();
        });
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> deleteProduct(String productId) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please login first.');
    }

    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(productId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Could not delete product: ${e.message ?? e.code}');
    }
  }

  Stream<List<Auction>> artisanAuctions() {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Auction>>.empty();
    }

    return db
        .collection('auctions')
        .where('artisanId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final auctions = snapshot.docs
              .map((document) => Auction.fromMap(document.id, document.data()))
              .toList();
          auctions.sort((a, b) => b.endsAt.compareTo(a.endsAt));
          return auctions;
        });
  }

  Future<void> createAuction({
    required String title,
    required String description,
    required double startingPrice,
    required DateTime endsAt,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Please login first.');
    }

    try {
      await db.collection('auctions').add({
        'artisanId': uid,
        'title': title.trim(),
        'description': description.trim(),
        'startingPrice': startingPrice,
        'currentBid': startingPrice,
        'bidCount': 0,
        'status': 'open',
        'endsAt': Timestamp.fromDate(endsAt),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Could not create auction: ${e.message ?? e.code}');
    }
  }

  Future<void> closeAuction(String auctionId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Please login first.');
    }

    try {
      await db.collection('auctions').doc(auctionId).update({
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Could not close auction: ${e.message ?? e.code}');
    }
  }

  Future<void> placeBid({
    required Auction auction,
    required double amount,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Please login first.');
    }
    if (!auction.isOpen) {
      throw Exception('This auction is no longer accepting bids.');
    }
    if (amount <= auction.currentBid) {
      throw Exception('Your bid must be higher than the current bid.');
    }

    final auctionRef = db.collection('auctions').doc(auction.id);
    final bidRef = auctionRef.collection('bids').doc();

    await db.runTransaction((transaction) async {
      final snapshot = await transaction.get(auctionRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw Exception('Auction not found.');
      }

      final latest = Auction.fromMap(snapshot.id, data);
      if (!latest.isOpen || amount <= latest.currentBid) {
        throw Exception('Another bid was placed. Please bid higher.');
      }

      transaction.update(auctionRef, {
        'currentBid': amount,
        'bidCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(bidRef, {
        'bidderId': user.uid,
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ============================================================
  // UPDATE USER PROFILE
  // ============================================================

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? city,
    String? state,
    String? bio,
  }) async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please login first.');
    }

    final Map<String, dynamic> data = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) {
      data['name'] = name.trim();
    }

    if (phone != null) {
      data['phone'] = phone.trim();
    }

    if (city != null) {
      data['city'] = city.trim();
    }

    if (state != null) {
      data['state'] = state.trim();
    }

    if (bio != null) {
      data['bio'] = bio.trim();
    }

    await db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      return null;
    }

    final snapshot = await db.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // ============================================================
  // AUTH ERROR MESSAGES
  // ============================================================

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
