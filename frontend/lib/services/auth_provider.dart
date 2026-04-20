import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _userId;
  bool _isAuthenticated = false;
  bool _isFirstLogin = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstLogin => _isFirstLogin;

  Future<bool> studentLogin(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.studentLogin(
        email: email,
        password: password,
      );

      if (result['success']) {
        _accessToken = result['accessToken'];
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> supervisorLogin(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.supervisorLogin(
        email: email,
        password: password,
      );

      if (result['success']) {
        _accessToken = result['accessToken'];
        _userId = result['userId'];
        _isFirstLogin = result['isFirstLogin'] ?? false;
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> moduleLeaderLogin(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.moduleLeaderLogin(
        email: email,
        password: password,
      );

      if (result['success']) {
        _accessToken = result['accessToken'];
        _userId = result['userId'];
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String degree,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.registerStudent(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        degree: degree,
      );

      if (result['success']) {
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _accessToken = null;
    _isAuthenticated = false;
    _clearError();
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _accessToken = await _authService.getToken();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearError() {
    _errorMessage = null;
  }
}
