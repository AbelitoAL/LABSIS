// lib/services/objeto_perdido_service.dart

import '../config/api_config.dart';
import '../models/objeto_perdido_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ObjetoPerdidoService {
  // Obtener todos los objetos perdidos
  static Future<List<ObjetoPerdidoModel>> getAll({
    String? estado,
    int? laboratorioId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Construir query params
      String endpoint = ApiConfig.objetosPerdidosEndpoint;
      List<String> params = [];

      if (estado != null) {
        params.add('estado=$estado');
      }
      if (laboratorioId != null) {
        params.add('laboratorio_id=$laboratorioId');
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
        return data.map((json) => ObjetoPerdidoModel.fromJson(json)).toList();
      }

      throw Exception(
          response['message'] ?? 'Error obteniendo objetos perdidos');
    } catch (e) {
      throw Exception('Error obteniendo objetos perdidos: $e');
    }
  }

  // Obtener objeto perdido por ID
  static Future<ObjetoPerdidoModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.objetosPerdidosEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        return ObjetoPerdidoModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo objeto');
    } catch (e) {
      throw Exception('Error obteniendo objeto: $e');
    }
  }

  // Registrar objeto perdido
  static Future<Map<String, dynamic>> create(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        ApiConfig.objetosPerdidosEndpoint,
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error registrando objeto: $e');
    }
  }

  // Registrar entrega de objeto
  static Future<Map<String, dynamic>> registrarEntrega(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.objetosPerdidosEndpoint}/$id/entregar',
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error registrando entrega: $e');
    }
  }

  // Actualizar objeto perdido
  static Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.put(
        '${ApiConfig.objetosPerdidosEndpoint}/$id',
        data,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error actualizando objeto: $e');
    }
  }

  // Eliminar objeto perdido
  static Future<Map<String, dynamic>> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.objetosPerdidosEndpoint}/$id',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Error eliminando objeto: $e');
    }
  }
}