import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/screens/login_screen.dart';
import 'package:hetanshi_enterprise/screens/dashboard_screen.dart';
import 'package:hetanshi_enterprise/screens/product/product_list_screen.dart';
import 'package:hetanshi_enterprise/screens/party/party_list_screen.dart';
import 'package:hetanshi_enterprise/screens/user/user_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_history_screen.dart';

void main() {
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
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/login',
      routes: {
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
