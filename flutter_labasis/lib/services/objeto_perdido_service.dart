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

  // Obtener objeto por ID
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

  // Crear objeto perdido
  static Future<int> create({
    required String descripcion,
    required int laboratorioId,
    String categoria = 'otros',
    String? fotoObjeto,
    String? fechaEncontrado,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validaciones
      if (descripcion.trim().isEmpty) {
        throw Exception('La descripción es requerida');
      }

      // Preparar datos
      final data = {
        'descripcion': descripcion.trim(),
        'laboratorio_id': laboratorioId,
        'categoria': categoria,
        if (fotoObjeto != null) 'foto_objeto': fotoObjeto,
        if (fechaEncontrado != null) 'fecha_encontrado': fechaEncontrado,
      };

      final response = await ApiService.post(
        ApiConfig.objetosPerdidosEndpoint,
        data,
        token: token,
      );

      if (response['success'] == true) {
        return response['data']['id'] as int;
      }

      throw Exception(response['message'] ?? 'Error registrando objeto');
    } catch (e) {
      if (e.toString().contains('laboratorio')) {
        throw Exception('El laboratorio seleccionado no es válido');
      }
      throw Exception('Error registrando objeto: $e');
    }
  }

  // Actualizar objeto perdido
  static Future<void> update({
    required int id,
    String? descripcion,
    String? categoria,
    String? fotoObjeto,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Preparar datos
      final data = <String, dynamic>{};

      if (descripcion != null && descripcion.trim().isNotEmpty) {
        data['descripcion'] = descripcion.trim();
      }
      if (categoria != null &&
          ['electronica', 'ropa', 'documentos', 'otros'].contains(categoria)) {
        data['categoria'] = categoria;
      }
      if (fotoObjeto != null) {
        data['foto_objeto'] = fotoObjeto;
      }

      if (data.isEmpty) {
        throw Exception('No hay campos para actualizar');
      }

      final response = await ApiService.put(
        '${ApiConfig.objetosPerdidosEndpoint}/$id',
        data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando objeto');
      }
    } catch (e) {
      if (e.toString().contains('no encontrado')) {
        throw Exception('El objeto no existe');
      }
      throw Exception('Error actualizando objeto: $e');
    }
  }

  // Eliminar objeto perdido
  static Future<void> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.objetosPerdidosEndpoint}/$id',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando objeto');
      }
    } catch (e) {
      if (e.toString().contains('no encontrado')) {
        throw Exception('El objeto no existe');
      }
      throw Exception('Error eliminando objeto: $e');
    }
  }

  // Registrar entrega
  static Future<void> registrarEntrega({
    required int id,
    required String nombreCompleto,
    required String documentoIdentidad,
    String tipoDocumento = 'CI',
    String? fotoPersona,
    String? telefono,
    String? email,
    String? relacionObjeto,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validaciones
      if (nombreCompleto.trim().isEmpty) {
        throw Exception('El nombre completo es requerido');
      }
      if (documentoIdentidad.trim().isEmpty) {
        throw Exception('El documento de identidad es requerido');
      }

      // Preparar datos
      final data = {
        'nombre_completo': nombreCompleto.trim(),
        'documento_identidad': documentoIdentidad.trim(),
        'tipo_documento': tipoDocumento,
        if (fotoPersona != null) 'foto_persona': fotoPersona,
        if (telefono != null && telefono.trim().isNotEmpty)
          'telefono': telefono.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (relacionObjeto != null && relacionObjeto.trim().isNotEmpty)
          'relacion_objeto': relacionObjeto.trim(),
      };

      final response = await ApiService.post(
        '${ApiConfig.objetosPerdidosEndpoint}/$id/entregar',
        data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error registrando entrega');
      }
    } catch (e) {
      if (e.toString().contains('no encontrado')) {
        throw Exception('El objeto no existe');
      }
      if (e.toString().contains('ya fue entregado')) {
        throw Exception('Este objeto ya fue entregado');
      }
      throw Exception('Error registrando entrega: $e');
    }
  }

  // Obtener por estado
  static Future<List<ObjetoPerdidoModel>> getByEstado(String estado) async {
    return getAll(estado: estado);
  }

  // Obtener en custodia
  static Future<List<ObjetoPerdidoModel>> getEnCustodia() async {
    return getByEstado('en_custodia');
  }

  // Obtener entregados
  static Future<List<ObjetoPerdidoModel>> getEntregados() async {
    return getByEstado('entregado');
  }

  // Obtener por laboratorio
  static Future<List<ObjetoPerdidoModel>> getByLaboratorio(
      int laboratorioId) async {
    return getAll(laboratorioId: laboratorioId);
  }

  // Validar datos
  static String? validarDatos({
    String? descripcion,
    String? categoria,
    String? nombreCompleto,
    String? documentoIdentidad,
  }) {
    if (descripcion != null) {
      if (descripcion.trim().isEmpty) {
        return 'La descripción no puede estar vacía';
      }
      if (descripcion.length < 3) {
        return 'La descripción debe tener al menos 3 caracteres';
      }
      if (descripcion.length > 500) {
        return 'La descripción no puede exceder 500 caracteres';
      }
    }

    if (categoria != null) {
      if (!['electronica', 'ropa', 'documentos', 'otros'].contains(categoria)) {
        return 'Categoría inválida';
      }
    }

    if (nombreCompleto != null) {
      if (nombreCompleto.trim().isEmpty) {
        return 'El nombre completo no puede estar vacío';
      }
      if (nombreCompleto.length < 3) {
        return 'El nombre debe tener al menos 3 caracteres';
      }
    }

    if (documentoIdentidad != null) {
      if (documentoIdentidad.trim().isEmpty) {
        return 'El documento de identidad no puede estar vacío';
      }
    }

    return null;
  }

  // Obtener estadísticas
  static Future<Map<String, int>> getEstadisticas() async {
    try {
      final objetos = await getAll();

      return {
        'total': objetos.length,
        'en_custodia': objetos.where((o) => o.estado == 'en_custodia').length,
        'entregados': objetos.where((o) => o.estado == 'entregado').length,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }
}