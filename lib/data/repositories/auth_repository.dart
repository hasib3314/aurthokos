import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AppDatabase _db = AppDatabase.instance;
  static const String _loggedInUserKey = 'logged_in_user_id';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // === Register ===

  Future<({bool success, String message})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty) {
      return (success: false, message: 'Name is required');
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return (success: false, message: 'Enter a valid email');
    }
    if (password.length < 6) {
      return (success: false, message: 'Password must be at least 6 characters');
    }

    final exists = await _db.emailExists(trimmedEmail);
    if (exists) {
      return (success: false, message: 'An account with this email already exists');
    }

    final user = UserModel(
      id: const Uuid().v4(),
      name: name.trim(),
      email: trimmedEmail,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.insertUser(user);
    await _saveSession(user.id);

    return (success: true, message: 'Account created successfully');
  }

  // === Login ===

  Future<({bool success, String message})> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty) {
      return (success: false, message: 'Email is required');
    }
    if (password.isEmpty) {
      return (success: false, message: 'Password is required');
    }

    final user = await _db.getUserByEmail(trimmedEmail);
    if (user == null) {
      return (success: false, message: 'No account found with this email');
    }

    final inputHash = _hashPassword(password);
    if (inputHash != user.passwordHash) {
      return (success: false, message: 'Incorrect password');
    }

    await _saveSession(user.id);
    return (success: true, message: 'Login successful');
  }

  // === Session ===

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, userId);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_loggedInUserKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_loggedInUserKey);
    if (userId == null) return null;
    return await _db.getUserById(userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }
}
