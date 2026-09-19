import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firebase_service.dart';
import 'customer_orders_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  // HeriTrace Signature Luxury Brand Palette (Cohesive Across Entire App)
  static const Color _background = Color(0xFFF5EFE6);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _raised = Color(0xFFFAF7F2);
  static const Color _text = Color(0xFF1D2A24);
  static const Color _muted = Color(0xFF6B746E);
  static const Color _accent = Color(0xFF7A2012); // Royal Terracotta Silk
  static const Color _gold = Color(0xFFD4A056);   // Antique Gold
  static const Color _border = Color(0xFFE8DFD3);

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
    final confirm = _confirmPasswordController.text;

    if (user == null || user.email == null) return;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill all password fields.');
      return;
    }

    if (newPassword != confirm) {
      _showMessage('New passwords do not match.');
      return;
    }

    setState(() => _changingPassword = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
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
    } catch (e) {
      _showMessage('Could not update password.');
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Account & Heritage Settings',
              style: TextStyle(
                color: _text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Royal Terracotta Profile Hero Banner
                        _profileHero(),

                        const SizedBox(height: 16),

                        // 2. Quick Navigation Shortcuts (Orders, Auctions, Lens)
                        _buildQuickActionRail(),

                        const SizedBox(height: 20),

                        // 3. Personal Information Form
                        _section(
                          title: 'Personal Information',
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            children: [
                              _field(
                                _nameController,
                                'Full Name',
                                Icons.badge_outlined,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _phoneController,
                                'Phone Number',
                                Icons.phone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _locationController,
                                'Delivery City & Address',
                                Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _saving ? null : _saveProfile,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 17,
                                          height: 17,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle_outline, size: 18),
                                  label: Text(
                                    _saving ? 'Saving...' : 'Save Profile Changes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 4. Notifications Preferences
                        _section(
                          title: 'Notification Alerts',
                          icon: Icons.notifications_none_rounded,
                          child: Column(
                            children: [
                              _toggle(
                                'Order & Delivery Updates',
                                'Real-time master artisan tracking & dispatch notifications',
                                _orderUpdates,
                                (value) =>
                                    setState(() => _orderUpdates = value),
                              ),
                              const Divider(color: _border, height: 16),
                              _toggle(
                                'Live Auction Bidding Alerts',
                                'Get notified when your bids need attention or lots end',
                                _auctionAlerts,
                                (value) =>
                                    setState(() => _auctionAlerts = value),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 5. Account Security
                        _section(
                          title: 'Security & Password',
                          icon: Icons.lock_outline_rounded,
                          child: Column(
                            children: [
                              _field(
                                _oldPasswordController,
                                'Current Password',
                                Icons.lock_clock_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _newPasswordController,
                                'New Password',
                                Icons.lock_reset_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _confirmPasswordController,
                                'Confirm New Password',
                                Icons.verified_user_outlined,
                                obscure: true,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _accent,
                                    side: const BorderSide(color: _accent),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _changingPassword
                                      ? null
                                      : _changePassword,
                                  icon: const Icon(Icons.key_outlined, size: 18),
                                  label: Text(
                                    _changingPassword
                                        ? 'Updating...'
                                        : 'Update Account Password',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 6. Logout
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFC62828),
                              side: const BorderSide(color: Color(0xFFEF9A9A)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text(
                              'Sign Out from HeriTrace',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
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

  // 1. Royal Terracotta Profile Hero Card
  Widget _profileHero() {
    final name = _nameController.text.trim();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A2012), Color(0xFF9E341B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A2012).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _gold.withValues(alpha: 0.3),
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : (_profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : null),
                    child: _profileImageBytes == null && _profileImageUrl.isEmpty
                        ? Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _uploadingPhoto ? null : _pickProfilePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: _gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF1D2A24),
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? 'HeriTrace Patron' : name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: _gold,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium, color: _gold, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'GI Heritage Patron • Gold Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_profileImageBytes != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: const Color(0xFF1D2A24),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _uploadingPhoto ? null : _uploadProfilePhoto,
              child: Text(
                _uploadingPhoto ? 'Uploading photo...' : 'Save Uploaded Photo',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Quick Action Rail (Orders, Auctions, Lens)
  Widget _buildQuickActionRail() {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            icon: Icons.receipt_long_rounded,
            title: 'My Orders',
            subtitle: 'Track deliveries',
            color: _accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionButton(
            icon: Icons.gavel_rounded,
            title: 'Auctions',
            subtitle: 'Live bids',
            color: _gold,
            onTap: () {
              Navigator.pushNamed(context, '/customer-auctions');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionButton(
            icon: Icons.qr_code_scanner_rounded,
            title: 'GI Lens',
            subtitle: 'Verify DNA',
            color: const Color(0xFF00897B),
            onTap: () {
              Navigator.pushNamed(context, '/heritage-features');
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
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
      style: const TextStyle(color: _text, fontWeight: FontWeight.w600, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted, fontSize: 13),
        prefixIcon: Icon(icon, color: _accent, size: 20),
        filled: true,
        fillColor: _raised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
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
        style: const TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 13.5),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: _muted, fontSize: 11),
      ),
      value: value,
      activeThumbColor: _accent,
      activeTrackColor: _accent.withValues(alpha: 0.35),
      onChanged: onChanged,
    );
  }
}
