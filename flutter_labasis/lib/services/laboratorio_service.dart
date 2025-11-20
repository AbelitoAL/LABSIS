// lib/services/laboratorio_service.dart

import '../config/api_config.dart';
import '../models/laboratorio_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class LaboratorioService {
  // Obtener todos los laboratorios
  static Future<List<LaboratorioModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        ApiConfig.laboratoriosEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => LaboratorioModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo laboratorios');
    } catch (e) {
      throw Exception('Error obteniendo laboratorios: $e');
    }
  }

  // Obtener laboratorio por ID
  static Future<LaboratorioModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.laboratoriosEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        return LaboratorioModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo laboratorio');
    } catch (e) {
      throw Exception('Error obteniendo laboratorio: $e');
    }
  }

  // Crear laboratorio (solo admin)
  static Future<Map<String, dynamic>> create(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        ApiConfig.laboratoriosEndpoint,
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error creando laboratorio: $e');
    }
  }

  // Actualizar laboratorio (solo admin)
  static Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.put(
        '${ApiConfig.laboratoriosEndpoint}/$id',
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error actualizando laboratorio: $e');
    }
  }

  // Eliminar laboratorio (solo admin)
  static Future<Map<String, dynamic>> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.laboratoriosEndpoint}/$id',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error eliminando laboratorio: $e');
    }
  }
}