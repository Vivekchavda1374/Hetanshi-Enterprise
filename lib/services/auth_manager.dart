import 'package:hetanshi_enterprise/models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthManager {
  // Singleton instance
  static final AuthManager _instance = AuthManager._internal();
  static AuthManager get instance => _instance;

  AuthManager._internal();

  // State
  bool _isAdmin = false;
  UserModel? _currentUser;

  // Getters
  bool get isAdmin => _isAdmin;
  bool get isUser => _currentUser != null && !_isAdmin;
  UserModel? get currentUser => _currentUser;

  // Actions
  void loginAdmin() {
    _isAdmin = true;
    _currentUser = null;
    debugPrint("AuthManager: Admin Logged In");
  }

  void loginUser(UserModel user) {
    _isAdmin = false;
    _currentUser = user;
    debugPrint("AuthManager: User ${user.email} Logged In");
  }

  void loginGuest() {
    _isAdmin = false;
    debugPrint("AuthManager: Guest Logged In");
  }

  void logout() {
    _isAdmin = false;
    _currentUser = null;
    debugPrint("AuthManager: Logged Out");
  }
}
