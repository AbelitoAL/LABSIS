// lib/services/user_service.dart

import '../config/api_config.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UserService {
  // Obtener todos los usuarios (solo admin)
  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        ApiConfig.usersEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((user) => user as Map<String, dynamic>).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo usuarios');
    } catch (e) {
      throw Exception('Error obteniendo usuarios: $e');
    }
  }

  // Obtener solo auxiliares
  static Future<List<Map<String, dynamic>>> getAuxiliares() async {
    try {
      final usuarios = await getAll();
      return usuarios.where((user) => user['rol'] == 'auxiliar').toList();
    } catch (e) {
      throw Exception('Error obteniendo auxiliares: $e');
    }
  }

  // Obtener usuario por ID
  static Future<Map<String, dynamic>> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.usersEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      }

      throw Exception(response['message'] ?? 'Error obteniendo usuario');
    } catch (e) {
      throw Exception('Error obteniendo usuario: $e');
    }
  }
}