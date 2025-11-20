// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Constructor
  AuthProvider() {
    _checkLoginStatus();
  }

  // Verificar si hay una sesión activa
  Future<void> _checkLoginStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        final token = await AuthService.getToken();
        _token = token;
        
        // Obtener datos del usuario
        final user = await AuthService.getCurrentUser();
        _user = user;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await AuthService.login(email, password);

      if (response['success'] == true) {
        _token = response['token'];
        _user = response['user'];
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _error = 'Error en el login';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Registro
  Future<bool> register(String email, String password, String nombre) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await AuthService.register(email, password, nombre);

      if (response['success'] == true) {
        _token = response['token'];
        _user = response['user'];
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _error = 'Error en el registro';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await AuthService.logout();
      _user = null;
      _token = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Actualizar información del usuario
  Future<void> refreshUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      _user = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
