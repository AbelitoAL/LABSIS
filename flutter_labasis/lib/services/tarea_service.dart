// lib/services/tarea_service.dart

import '../config/api_config.dart';
import '../models/tarea_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TareaService {
  // Obtener todas las tareas
  static Future<List<TareaModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        ApiConfig.tareasEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TareaModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo tareas');
    } catch (e) {
      throw Exception('Error obteniendo tareas: $e');
    }
  }

  // Obtener mis tareas
  static Future<List<TareaModel>> getMisTareas() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        ApiConfig.misTareasEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TareaModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo mis tareas');
    } catch (e) {
      throw Exception('Error obteniendo mis tareas: $e');
    }
  }

  // Obtener tarea por ID
  static Future<TareaModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.tareasEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        return TareaModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo tarea');
    } catch (e) {
      throw Exception('Error obteniendo tarea: $e');
    }
  }

  // Crear tarea (solo admin)
  static Future<Map<String, dynamic>> create(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        ApiConfig.tareasEndpoint,
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error creando tarea: $e');
    }
  }

  // Actualizar tarea
  static Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.put(
        '${ApiConfig.tareasEndpoint}/$id',
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error actualizando tarea: $e');
    }
  }

  // Marcar como completada
  static Future<Map<String, dynamic>> marcarCompletada(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.tareasEndpoint}/$id/completar',
        {},
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error marcando tarea como completada: $e');
    }
  }

  // Eliminar tarea (solo admin)
  static Future<Map<String, dynamic>> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.tareasEndpoint}/$id',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error eliminando tarea: $e');
    }
  }
}
