import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'admin_dashboard_screen.dart';
import 'customer_home_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  FirebaseService? _firebaseService;
  int _roleLoadAttempt = 0;

  @override
  Widget build(BuildContext context) {
    if (firebase_core.Firebase.apps.isEmpty) {
      return const _AuthLoadingScreen(message: 'Firebase is not configured.');
    }

    final firebaseService = _firebaseService ??= FirebaseService();

    return StreamBuilder<User?>(
      stream: firebaseService.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          key: ValueKey(_roleLoadAttempt),
          future: firebaseService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _AuthLoadingScreen(
                message: 'Loading your workspace...',
              );
            }

            if (roleSnapshot.hasError) {
              return _AuthErrorScreen(
                onRetry: () => setState(() => _roleLoadAttempt++),
              );
            }

            return _destinationForRole(roleSnapshot.data);
          },
        );
      },
    );
  }

  Widget _destinationForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'customer':
        return const CustomerHomeScreen();
      case 'admin':
        return const AdminDashboardScreen();
      case 'artisan':
      default:
        return const HomeScreen();
    }
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen({this.message = 'Preparing HeriTrace...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 42),
              const SizedBox(height: 16),
              const Text(
                'We could not load your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
