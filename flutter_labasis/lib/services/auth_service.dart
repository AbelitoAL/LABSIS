// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        // Guardar token y datos del usuario
        await _saveToken(token);
        await _saveUser(userData);

        return {
          'success': true,
          'token': token,
          'user': UserModel.fromJson(userData),
        };
      }

      throw Exception(response['message'] ?? 'Error en el login');
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // Registro público (como auxiliar)
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.registerEndpoint,
        {
          'email': email,
          'password': password,
          'nombre': nombre,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        // Guardar token y datos del usuario
        await _saveToken(token);
        await _saveUser(userData);

        return {
          'success': true,
          'token': token,
          'user': UserModel.fromJson(userData),
        };
      }

      throw Exception(response['message'] ?? 'Error en el registro');
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  // Obtener información del usuario actual
  static Future<UserModel> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await ApiService.get(
        ApiConfig.meEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        return UserModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo usuario');
    } catch (e) {
      throw Exception('Error obteniendo usuario: $e');
    }
  }

  // Guardar token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Guardar datos del usuario
  static Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData.toString());
  }

  // Obtener token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}