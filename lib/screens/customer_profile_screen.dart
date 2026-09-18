import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/firebase_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  static const _background = Color(0xFF0B1513);
  static const _surface = Color(0xFF12231F);
  static const _raised = Color(0xFF1A302A);
  static const _text = Color(0xFFF2FAF6);
  static const _muted = Color(0xFFA7BBB4);
  static const _accent = Color(0xFF4FD1B5);

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _picker = ImagePicker();
  final _firebaseService = FirebaseService();
  Uint8List? _profileImageBytes;
  String _profileImageUrl = '';
  bool _uploadingPhoto = false;

  bool _loading = true;
  bool _saving = false;
  bool _changingPassword = false;
  bool _orderUpdates = true;
  bool _auctionAlerts = true;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data() ?? {};

    _nameController.text =
        (data['name'] ?? data['displayName'] ?? user.displayName ?? '')
            .toString();
    _phoneController.text = (data['phone'] ?? '').toString();
    _locationController.text = (data['location'] ?? data['address'] ?? '')
        .toString();
    _profileImageUrl = (data['photoUrl'] ?? user.photoURL ?? '').toString();
    _orderUpdates = data['orderUpdates'] as bool? ?? true;
    _auctionAlerts = data['auctionAlerts'] as bool? ?? true;

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickProfilePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _profileImageBytes = bytes);
  }

  Future<void> _uploadProfilePhoto() async {
    final user = _user;
    final bytes = _profileImageBytes;
    if (user == null || bytes == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await _firebaseService.uploadImage(
        bytes,
        'profiles/${user.uid}/avatar.jpg',
      );
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updatePhotoURL(url);
      if (mounted) {
        setState(() {
          _profileImageUrl = url;
          _profileImageBytes = null;
        });
        _showMessage('Profile photo updated.');
      }
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = _user;
    if (user == null || _nameController.text.trim().isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'displayName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'orderUpdates': _orderUpdates,
        'auctionAlerts': _auctionAlerts,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(_nameController.text.trim());
      _showMessage('Profile settings saved.');
    } on FirebaseException catch (e) {
      _showMessage(e.message ?? 'Could not save your profile.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final user = _user;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (user?.email == null) {
      _showMessage('Password change is unavailable for this account.');
      return;
    }
    if (oldPassword.isEmpty || newPassword.length < 6) {
      _showMessage(
        'Enter your current password and a new password of 6+ characters.',
      );
      return;
    }
    if (newPassword != _confirmPasswordController.text) {
      _showMessage('New passwords do not match.');
      return;
    }

    setState(() => _changingPassword = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showMessage('Password updated successfully.');
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e));
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  String _authMessage(FirebaseAuthException e) {
    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return 'Current password is incorrect.';
    }
    if (e.code == 'weak-password') return 'Choose a stronger password.';
    return e.message ?? 'Could not update password.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        title: const Text('Profile & Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileHero(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/heritage-features',
                              );
                            },
                            icon: const Icon(Icons.account_tree_outlined),
                            label: const Text('Open Heritage Intelligence'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _section(
                          title: 'Personal information',
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            children: [
                              _field(
                                _nameController,
                                'Full name',
                                Icons.badge_outlined,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _phoneController,
                                'Phone number',
                                Icons.phone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _locationController,
                                'City or location',
                                Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _saving ? null : _saveProfile,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 17,
                                          height: 17,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _background,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(
                                    _saving ? 'Saving...' : 'Save profile',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _section(
                          title: 'Notifications',
                          icon: Icons.notifications_none_rounded,
                          child: Column(
                            children: [
                              _toggle(
                                'Order updates',
                                'Delivery and order status notifications',
                                _orderUpdates,
                                (value) =>
                                    setState(() => _orderUpdates = value),
                              ),
                              _toggle(
                                'Auction alerts',
                                'Get notified when your bids need attention',
                                _auctionAlerts,
                                (value) =>
                                    setState(() => _auctionAlerts = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _section(
                          title: 'Security',
                          icon: Icons.lock_outline_rounded,
                          child: Column(
                            children: [
                              _field(
                                _oldPasswordController,
                                'Current password',
                                Icons.lock_clock_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _newPasswordController,
                                'New password',
                                Icons.lock_reset_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _confirmPasswordController,
                                'Confirm new password',
                                Icons.verified_user_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _changingPassword
                                      ? null
                                      : _changePassword,
                                  icon: const Icon(Icons.key_outlined),
                                  label: Text(
                                    _changingPassword
                                        ? 'Updating...'
                                        : 'Change password',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Color(0xFF713D43)),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Log out of HeriTrace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _profileHero() {
    final name = _nameController.text.trim();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176B5B), Color(0xFF0F5145)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: _accent,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : (_profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : null),
                child: _profileImageBytes == null && _profileImageUrl.isEmpty
                    ? Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: const TextStyle(
                          color: _background,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Your profile' : name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _user?.email ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_user_outlined, color: _accent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _uploadingPhoto ? null : _pickProfilePhoto,
                icon: const Icon(Icons.photo_camera_outlined, size: 17),
                label: const Text('Choose photo'),
                style: TextButton.styleFrom(foregroundColor: _accent),
              ),
              if (_profileImageBytes != null)
                TextButton(
                  onPressed: _uploadingPhoto ? null : _uploadProfilePhoto,
                  child: Text(_uploadingPhoto ? 'Uploading...' : 'Upload'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF29443B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accent, size: 21),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted),
        prefixIcon: Icon(icon, color: _accent),
        fillColor: _raised,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF29443B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _muted, fontSize: 12),
      ),
      value: value,
      activeThumbColor: _accent,
      onChanged: onChanged,
    );
  }
}
