import 'package:api_practice/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  UserModel _userModel = UserModel();
  String? _token;

  UserModel getUser() => _userModel;

  String? getToken() => _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  void setUser(UserModel model) {
    _userModel = model;
    notifyListeners();
  }

  /// Stores the auth token in memory and persists it to disk so the
  /// user stays logged in across app restarts.
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    notifyListeners();
  }

  /// Attempts to restore a previously saved token.
  /// Returns true if a token was found.
  Future<bool> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_token');
    if (saved != null && saved.isNotEmpty) {
      _token = saved;
      return true;
    }
    return false;
  }

  /// Clears session data both in memory and on disk.
  Future<void> logout() async {
    _userModel = UserModel();
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
