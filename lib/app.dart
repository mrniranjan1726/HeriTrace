import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/products_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/business_screen.dart';
import 'screens/customer_cart_screen.dart';
import 'screens/customer_wishlist_screen.dart';
import 'screens/customer_orders_screen.dart';
import 'screens/artisan_orders_screen.dart';
import 'screens/artisan_profile_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/artisan_auctions_screen.dart';
import 'screens/customer_auctions_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/heritage_features_screen.dart';

class HeriTraceApp extends StatelessWidget {
  const HeriTraceApp({super.key});

  static const Color primary = Color(0xFF176B5B);
  static const Color background = Color(0xFFF7F8F4);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeriTrace',

      // ------------------------------------------------------------
      // THEME
      // ------------------------------------------------------------
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        scaffoldBackgroundColor: background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),

        fontFamily: 'Arial',

        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Color(0xFF17201D),
          elevation: 0,
          centerTitle: false,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5EAE7)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5EAE7)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),

      // ------------------------------------------------------------
      // ROUTES
      // ------------------------------------------------------------
      routes: {
        // Login
        '/login': (context) {
          return const LoginScreen();
        },
        '/customer-wishlist': (context) {
          return const CustomerWishlistScreen();
        },
        '/customer-profile': (context) {
          return const CustomerProfileScreen();
        },
        '/heritage-features': (context) {
          return const HeritageFeaturesScreen();
        },
        // ----------------------------------------------------------
        // ARTISAN
        // ----------------------------------------------------------

        '/artisan-profile': (context) {
          return const ArtisanProfileScreen();
        },
        '/dashboard': (context) {
          return const DashboardScreen();
        },
        '/customer-orders': (context) => const CustomerOrdersScreen(),
        '/add': (context) {
          return const Material(color: background, child: AddProductScreen());
        },

        '/pricing': (context) {
          return const Material(color: background, child: PricingScreen());
        },

        '/products': (context) {
          return const Material(color: background, child: ProductsScreen());
        },
        '/artisan-orders': (context) => const ArtisanOrdersScreen(),
        '/artisan-auctions': (context) => const ArtisanAuctionsScreen(),
        '/customer-auctions': (context) => const CustomerAuctionsScreen(),
        '/marketplace': (context) {
          return const Material(color: background, child: MarketplaceScreen());
        },

        '/business': (context) {
          return const Material(color: background, child: BusinessScreen());
        },

        // ----------------------------------------------------------
        // CUSTOMER
        // ----------------------------------------------------------
        '/customer-cart': (context) {
          return const CustomerCartScreen();
        },
      },

      // ------------------------------------------------------------
      // INITIAL SCREEN
      // ------------------------------------------------------------
      home: const AuthGate(),
    );
  }
}
