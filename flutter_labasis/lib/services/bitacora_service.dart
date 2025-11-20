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
  static Future<int> create({
    required String nombre,
    required int laboratorioId,
    int? plantillaId,
    String? fecha,
    String turno = 'mañana',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validaciones
      if (nombre.trim().isEmpty) {
        throw Exception('El nombre es requerido');
      }

      // Preparar datos
      final data = {
        'nombre': nombre.trim(),
        'laboratorio_id': laboratorioId,
        if (plantillaId != null) 'plantilla_id': plantillaId,
        if (fecha != null) 'fecha': fecha,
        'turno': turno,
      };

      final response = await ApiService.post(
        ApiConfig.bitacorasEndpoint,
        data,
        token: token,
      );

      if (response['success'] == true) {
        return response['data']['id'] as int;
      }

      throw Exception(response['message'] ?? 'Error creando bitácora');
    } catch (e) {
      if (e.toString().contains('laboratorio')) {
        throw Exception('El laboratorio seleccionado no es válido');
      }
      throw Exception('Error creando bitácora: $e');
    }
  }

  // Actualizar bitácora
  static Future<void> update({
    required int id,
    String? nombre,
    String? estado,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Preparar datos
      final data = <String, dynamic>{};

      if (nombre != null && nombre.trim().isNotEmpty) {
        data['nombre'] = nombre.trim();
      }
      if (estado != null && ['borrador', 'completada'].contains(estado)) {
        data['estado'] = estado;
      }

      if (data.isEmpty) {
        throw Exception('No hay campos para actualizar');
      }

      final response = await ApiService.put(
        '${ApiConfig.bitacorasEndpoint}/$id',
        data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando bitácora');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La bitácora no existe');
      }
      if (e.toString().contains('permiso')) {
        throw Exception('No tienes permiso para actualizar esta bitácora');
      }
      throw Exception('Error actualizando bitácora: $e');
    }
  }

  // Completar bitácora
  static Future<void> completar(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.bitacorasEndpoint}/$id/completar',
        {},
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(
            response['message'] ?? 'Error completando bitácora');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La bitácora no existe');
      }
      if (e.toString().contains('permiso')) {
        throw Exception('No tienes permiso para completar esta bitácora');
      }
      throw Exception('Error completando bitácora: $e');
    }
  }

  // Eliminar bitácora
  static Future<void> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.bitacorasEndpoint}/$id',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando bitácora');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La bitácora no existe');
      }
      if (e.toString().contains('permiso')) {
        throw Exception('No tienes permiso para eliminar esta bitácora');
      }
      throw Exception('Error eliminando bitácora: $e');
    }
  }

  // Obtener por estado
  static Future<List<BitacoraModel>> getByEstado(String estado) async {
    try {
      final bitacoras = await getAll();
      return bitacoras.where((b) => b.estado == estado).toList();
    } catch (e) {
      throw Exception('Error obteniendo bitácoras por estado: $e');
    }
  }

  // Obtener borradores
  static Future<List<BitacoraModel>> getBorradores() async {
    return getByEstado('borrador');
  }

  // Obtener completadas
  static Future<List<BitacoraModel>> getCompletadas() async {
    return getByEstado('completada');
  }

  // Obtener por laboratorio
  static Future<List<BitacoraModel>> getByLaboratorio(int laboratorioId) async {
    return getAll(laboratorioId: laboratorioId);
  }

  // Validar datos
  static String? validarDatos({
    String? nombre,
    String? turno,
    String? estado,
  }) {
    if (nombre != null) {
      if (nombre.trim().isEmpty) {
        return 'El nombre no puede estar vacío';
      }
      if (nombre.length < 3) {
        return 'El nombre debe tener al menos 3 caracteres';
      }
      if (nombre.length > 200) {
        return 'El nombre no puede exceder 200 caracteres';
      }
    }

    if (turno != null) {
      if (!['mañana', 'tarde', 'noche'].contains(turno)) {
        return 'Turno inválido';
      }
    }

    if (estado != null) {
      if (!['borrador', 'completada'].contains(estado)) {
        return 'Estado inválido';
      }
    }

    return null;
  }

  // Obtener estadísticas
  static Future<Map<String, int>> getEstadisticas() async {
    try {
      final bitacoras = await getAll();

      return {
        'total': bitacoras.length,
        'borradores': bitacoras.where((b) => b.estado == 'borrador').length,
        'completadas': bitacoras.where((b) => b.estado == 'completada').length,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }
}