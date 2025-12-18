import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:hetanshi_enterprise/firebase_options.dart';
import 'package:hetanshi_enterprise/screens/login_screen.dart';
import 'package:hetanshi_enterprise/screens/auth/register_screen.dart';
import 'package:hetanshi_enterprise/screens/splash_screen.dart';
import 'package:hetanshi_enterprise/screens/dashboard_screen.dart';
import 'package:hetanshi_enterprise/screens/product/product_list_screen.dart';
import 'package:hetanshi_enterprise/screens/party/party_list_screen.dart';
import 'package:hetanshi_enterprise/screens/user/user_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_list_screen.dart';
import 'package:hetanshi_enterprise/screens/order/order_history_screen.dart';

import 'package:hetanshi_enterprise/utils/app_theme.dart';

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
      theme: AppTheme.lightTheme,
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
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
