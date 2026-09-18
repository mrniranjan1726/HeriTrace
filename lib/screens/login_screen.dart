import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();

  final FirebaseService firebaseService = FirebaseService();

  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  bool register = false;
  bool busy = false;
  bool obscurePassword = true;

  String selectedRole = 'artisan';
  String? error;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN / REGISTER
  // ============================================================

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    if (email.text.trim().isEmpty) {
      setState(() {
        error = 'Please enter your email address.';
      });
      return;
    }

    if (password.text.isEmpty) {
      setState(() {
        error = 'Please enter your password.';
      });
      return;
    }

    if (password.text.length < 6) {
      setState(() {
        error = 'Password must contain at least 6 characters.';
      });
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      if (register) {
        if (selectedRole == 'admin') {
          throw Exception(
            'Admin accounts cannot be created through public registration.',
          );
        }

        await firebaseService.register(
          email.text.trim(),
          password.text,
          role: selectedRole,
        );
      } else {
        await firebaseService.login(email.text.trim(), password.text);
      }
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ============================================================
  // TOGGLE LOGIN / REGISTER
  // ============================================================

  void toggleMode() {
    FocusScope.of(context).unfocus();

    setState(() {
      register = !register;
      error = null;
    });

    _cardController
      ..reset()
      ..forward();
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _animatedBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 35,
                ),
                child: AnimatedBuilder(
                  animation: _cardAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 35 * (1 - _cardAnimation.value)),
                      child: Opacity(
                        opacity: _cardAnimation.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _loginCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANIMATED BACKGROUND
  // ============================================================

  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final value = _backgroundController.value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5F0), Color(0xFFF7F8F4), Color(0xFFFDF3E8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + (value * 25),
                left: -60,
                child: _glowCircle(size: 240, color: const Color(0xFF176B5B)),
              ),
              Positioned(
                bottom: -100 + (value * 35),
                right: -70,
                child: _glowCircle(size: 280, color: const Color(0xFFE68A3A)),
              ),
              Positioned(
                top: 180 + (value * 35),
                right: 80,
                child: _smallCircle(),
              ),
              Positioned(
                bottom: 180 - (value * 25),
                left: 100,
                child: _smallCircle(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _glowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _smallCircle() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0x33176B5B),
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _loginCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 850;

        return Container(
          width: isDesktop ? 900 : 460,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 45,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(child: _brandPanel()),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(42),
                        child: _formPanel(),
                      ),
                    ),
                  ],
                )
              : Padding(padding: const EdgeInsets.all(28), child: _formPanel()),
        );
      },
    );
  }

  // ============================================================
  // BRAND PANEL
  // ============================================================

  Widget _brandPanel() {
    return Container(
      height: 620,
      padding: const EdgeInsets.all(45),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF176B5B), Color(0xFF0E5044)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const Spacer(),

          const Text(
            'Preserve heritage.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Empower artisans.',
            style: TextStyle(
              color: Color(0xFFFFD6A8),
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            'HeriTrace connects traditional craftsmanship '
            'with modern digital commerce.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 15,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 30),

          _feature(Icons.auto_awesome, 'AI-powered business tools'),

          _feature(Icons.language_rounded, 'Multilingual commerce'),

          _feature(Icons.public_rounded, 'Reach customers everywhere'),

          const Spacer(),

          Text(
            'HERITAGE • TECHNOLOGY • COMMUNITY',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  Widget _formPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4EF),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF176B5B),
                  size: 32,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'HeriTrace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18221F),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                register ? 'Create your account' : 'Welcome back',
                style: const TextStyle(color: Color(0xFF6B756F), fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ROLE SELECTOR
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: register
              ? Column(
                  key: const ValueKey('roles'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose your role',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18221F),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _roleCard(
                            'Artisan',
                            'Sell your crafts',
                            Icons.handyman_rounded,
                            'artisan',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _roleCard(
                            'Customer',
                            'Discover crafts',
                            Icons.shopping_bag_rounded,
                            'customer',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('no_roles')),
        ),

        // EMAIL
        _label('Email address'),

        const SizedBox(height: 7),

        _inputField(
          controller: email,
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 17),

        // PASSWORD
        _label('Password'),

        const SizedBox(height: 7),

        _inputField(
          controller: password,
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscure: obscurePassword,
          suffix: IconButton(
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF7A8580),
              size: 20,
            ),
          ),
        ),

        // ERROR
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: error == null
              ? const SizedBox.shrink()
              : Container(
                  key: const ValueKey('error'),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD5D5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 22),

        // MAIN BUTTON
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: busy ? null : submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF176B5B),
              disabledBackgroundColor: const Color(0xFF9ABDB5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: busy
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      register ? 'Create Account' : 'Login',
                      key: ValueKey(register),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // SWITCH MODE
        Center(
          child: TextButton(
            onPressed: busy ? null : toggleMode,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B756F)),
                children: [
                  TextSpan(
                    text: register
                        ? 'Already have an account? '
                        : "Don't have an account? ",
                  ),
                  TextSpan(
                    text: register ? 'Login' : 'Create one',
                    style: const TextStyle(
                      color: Color(0xFF176B5B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        Center(
          child: Text(
            'Secure authentication powered by Firebase',
            style: TextStyle(color: const Color(0xFF9AA39E), fontSize: 10),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _roleCard(String title, String subtitle, IconData icon, String role) {
    final selected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4F4EF) : const Color(0xFFF8F9F7),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? const Color(0xFF176B5B) : const Color(0xFFE3E8E5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF176B5B)
                    : const Color(0xFFE8ECEA),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 19,
                color: selected ? Colors.white : const Color(0xFF66716C),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? const Color(0xFF176B5B)
                          : const Color(0xFF27312D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF7A8580),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF27312D),
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: (_) {
        if (error != null) {
          setState(() {
            error = null;
          });
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA1AAA6), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF7A8580), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F9F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E9E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E9E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF176B5B), width: 1.5),
        ),
      ),
    );
  }
}
