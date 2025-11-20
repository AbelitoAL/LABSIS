// lib/services/bitacora_service.dart

import '../config/api_config.dart';
import '../models/bitacora_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class BitacoraService {
  // Obtener todas las bitácoras
  static Future<List<BitacoraModel>> getAll({
    int? laboratorioId,
    int? auxiliarId,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Construir query params
      String endpoint = ApiConfig.bitacorasEndpoint;
      List<String> params = [];

      if (laboratorioId != null) {
        params.add('laboratorio_id=$laboratorioId');
      }
      if (auxiliarId != null) {
        params.add('auxiliar_id=$auxiliarId');
      }
      if (fechaDesde != null) {
        params.add('fecha_desde=$fechaDesde');
      }
      if (fechaHasta != null) {
        params.add('fecha_hasta=$fechaHasta');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await ApiService.get(
        endpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => BitacoraModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo bitácoras');
    } catch (e) {
      throw Exception('Error obteniendo bitácoras: $e');
    }
  }

  // Obtener bitácora por ID
  static Future<BitacoraModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.bitacorasEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        return BitacoraModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo bitácora');
    } catch (e) {
      throw Exception('Error obteniendo bitácora: $e');
    }
  }

  // Crear bitácora
  static Future<Map<String, dynamic>> create(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        ApiConfig.bitacorasEndpoint,
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error creando bitácora: $e');
    }
  }

  // Actualizar bitácora
  static Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.put(
        '${ApiConfig.bitacorasEndpoint}/$id',
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error actualizando bitácora: $e');
    }
  }

  // Completar bitácora
  static Future<Map<String, dynamic>> completar(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.bitacorasEndpoint}/$id/completar',
        {},
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error completando bitácora: $e');
    }
  }

  // Eliminar bitácora
  static Future<Map<String, dynamic>> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.bitacorasEndpoint}/$id',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error eliminando bitácora: $e');
    }
  }
}
