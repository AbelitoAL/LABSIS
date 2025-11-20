// lib/services/auth_service.dart

import 'dart:convert';
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
      print('🔐 Intentando login para: $email');
      
      final response = await ApiService.post(
        ApiConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      print('📥 Respuesta del servidor: $response');

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        print('✅ Login exitoso, guardando datos...');

        // Guardar token y datos del usuario
        await _saveToken(token);
        await _saveUser(userData);

        print('✅ Datos guardados correctamente');

        return {
          'success': true,
          'token': token,
          'user': UserModel.fromJson(userData),
        };
      }

      throw Exception(response['message'] ?? 'Error en el login');
    } catch (e) {
      print('❌ Error en login: $e');
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
      print('📝 Intentando registro para: $email');
      
      final response = await ApiService.post(
        ApiConfig.registerEndpoint,
        {
          'email': email,
          'password': password,
          'nombre': nombre,
        },
      );

      print('📥 Respuesta del servidor: $response');

      if (response['success'] == true) {
        final token = response['data']['token'];
        final userData = response['data']['user'];

        print('✅ Registro exitoso, guardando datos...');

        // Guardar token y datos del usuario
        await _saveToken(token);
        await _saveUser(userData);

        print('✅ Datos guardados correctamente');

        return {
          'success': true,
          'token': token,
          'user': UserModel.fromJson(userData),
        };
      }

      throw Exception(response['message'] ?? 'Error en el registro');
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception('Error en registro: $e');
    }
  }

  // Obtener información del usuario actual
  static Future<UserModel> getCurrentUser() async {
    try {
      print('👤 Obteniendo información del usuario actual...');
      
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await ApiService.get(
        ApiConfig.meEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Usuario obtenido correctamente');
        
        // Actualizar datos guardados
        await _saveUser(response['data']);
        return UserModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo usuario');
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      throw Exception('Error obteniendo usuario: $e');
    }
  }

  // Guardar token
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token guardado en SharedPreferences');
    } catch (e) {
      print('❌ Error guardando token: $e');
      throw e;
    }
  }

  // Guardar datos del usuario - CON jsonEncode
  static Future<void> _saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // ✅ IMPORTANTE: Usar jsonEncode para guardar como JSON válido
      final userJson = jsonEncode(userData);
      await prefs.setString(_userKey, userJson);
      print('✅ Datos de usuario guardados: ${userData['email']}');
    } catch (e) {
      print('❌ Error guardando usuario: $e');
      throw e;
    }
  }

  // Obtener token guardado
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        print('🔑 Token encontrado en SharedPreferences');
      } else {
        print('⚠️ No se encontró token en SharedPreferences');
      }
      return token;
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  // Obtener usuario guardado
  static Future<Map<String, dynamic>?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      
      if (userString != null && userString.isNotEmpty) {
        // Decodificar JSON
        final userData = jsonDecode(userString) as Map<String, dynamic>;
        print('👤 Usuario encontrado: ${userData['email']}');
        return userData;
      }
      
      print('⚠️ No se encontró usuario guardado');
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario guardado: $e');
      return null;
    }
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final hasToken = token != null && token.isNotEmpty;
      
      if (hasToken) {
        print('✅ Sesión activa detectada');
      } else {
        print('⚠️ No hay sesión activa');
      }
      
      return hasToken;
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      return false;
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      print('🚪 Cerrando sesión...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      throw e;
    }
  }

  // Limpiar todos los datos (útil para debugging)
  static Future<void> clearAll() async {
    try {
      print('🗑️ Limpiando todos los datos...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('✅ Todos los datos eliminados');
    } catch (e) {
      print('❌ Error limpiando datos: $e');
      throw e;
    }
  }
}