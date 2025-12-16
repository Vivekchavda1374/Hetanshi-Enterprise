import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hetanshi_enterprise/firebase_options.dart';
import 'package:hetanshi_enterprise/screens/login_screen.dart';
import 'package:hetanshi_enterprise/screens/splash_screen.dart';
import 'package:hetanshi_enterprise/screens/dashboard_screen.dart';
import 'package:hetanshi_enterprise/screens/product/product_list_screen.dart';
import 'package:hetanshi_enterprise/screens/party/party_list_screen.dart';
import 'package:hetanshi_enterprise/screens/user/user_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hetanshi Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFF1F2937),
            displayColor: const Color(0xFF1F2937),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1FA2A6), // Deep Teal
          secondary: Color(0xFFD4AF37), // Soft Champagne Gold
          surface: Color(0xFFFFFFFF), // Snow White
          background: Color(0xFFF8F9FA), // Porcelain White
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1F2937),
          onBackground: Color(0xFF1F2937),
          error: Color(0xFFDC2626), // Muted Red
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1FA2A6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05), // Very soft shadow
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1FA2A6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/products': (context) => const ProductListScreen(),
        '/parties': (context) => const PartyListScreen(),
        '/users': (context) => const UserListScreen(),
        '/orders': (context) => const OrderListScreen(),
        '/history': (context) => const OrderHistoryScreen(),
      },
    );
  }
}
