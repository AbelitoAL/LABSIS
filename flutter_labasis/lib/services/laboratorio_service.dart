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
  static Future<int> create({
    required String nombre,
    required String codigo,
    String? ubicacion,
    int? capacidad,
    List<String>? equipamiento,
    String estado = 'activo',
    List<String>? imagenes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validaciones
      if (nombre.trim().isEmpty) {
        throw Exception('El nombre es requerido');
      }
      if (codigo.trim().isEmpty) {
        throw Exception('El código es requerido');
      }

      // Preparar datos
      final data = {
        'nombre': nombre.trim(),
        'codigo': codigo.trim().toUpperCase(),
        if (ubicacion != null && ubicacion.isNotEmpty)
          'ubicacion': ubicacion.trim(),
        if (capacidad != null && capacidad > 0) 'capacidad': capacidad,
        if (equipamiento != null && equipamiento.isNotEmpty)
          'equipamiento': equipamiento,
        'estado': estado,
        if (imagenes != null && imagenes.isNotEmpty) 'imagenes': imagenes,
      };

      final response = await ApiService.post(
        ApiConfig.laboratoriosEndpoint,
        data,
        token: token,
      );

      if (response['success'] == true) {
        // Retornar el ID del laboratorio creado
        return response['data']['id'] as int;
      }

      throw Exception(response['message'] ?? 'Error creando laboratorio');
    } catch (e) {
      if (e.toString().contains('código ya existe')) {
        throw Exception('El código del laboratorio ya existe');
      }
      throw Exception('Error creando laboratorio: $e');
    }
  }

  // Actualizar laboratorio (solo admin)
  static Future<void> update({
    required int id,
    String? nombre,
    String? codigo,
    String? ubicacion,
    int? capacidad,
    List<String>? equipamiento,
    String? estado,
    List<String>? imagenes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validar que al menos un campo se va a actualizar
      if (nombre == null &&
          codigo == null &&
          ubicacion == null &&
          capacidad == null &&
          equipamiento == null &&
          estado == null &&
          imagenes == null) {
        throw Exception('Debes proporcionar al menos un campo para actualizar');
      }

      // Preparar datos (solo campos no nulos)
      final data = <String, dynamic>{};

      if (nombre != null && nombre.trim().isNotEmpty) {
        data['nombre'] = nombre.trim();
      }
      if (codigo != null && codigo.trim().isNotEmpty) {
        data['codigo'] = codigo.trim().toUpperCase();
      }
      if (ubicacion != null) {
        data['ubicacion'] = ubicacion.trim();
      }
      if (capacidad != null && capacidad > 0) {
        data['capacidad'] = capacidad;
      }
      if (equipamiento != null) {
        data['equipamiento'] = equipamiento;
      }
      if (estado != null &&
          ['activo', 'mantenimiento', 'inactivo'].contains(estado)) {
        data['estado'] = estado;
      }
      if (imagenes != null) {
        data['imagenes'] = imagenes;
      }

      final response = await ApiService.put(
        '${ApiConfig.laboratoriosEndpoint}/$id',
        data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(
            response['message'] ?? 'Error actualizando laboratorio');
      }
    } catch (e) {
      if (e.toString().contains('no encontrado')) {
        throw Exception('El laboratorio no existe');
      }
      if (e.toString().contains('código ya existe')) {
        throw Exception('El código del laboratorio ya existe');
      }
      throw Exception('Error actualizando laboratorio: $e');
    }
  }

  // Actualizar solo el estado (método conveniente)
  static Future<void> updateEstado(int id, String estado) async {
    try {
      // Validar estado
      if (!['activo', 'mantenimiento', 'inactivo'].contains(estado)) {
        throw Exception('Estado inválido');
      }

      await update(id: id, estado: estado);
    } catch (e) {
      throw Exception('Error actualizando estado: $e');
    }
  }

  // Eliminar laboratorio (solo admin)
  static Future<void> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.laboratoriosEndpoint}/$id',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando laboratorio');
      }
    } catch (e) {
      if (e.toString().contains('no encontrado')) {
        throw Exception('El laboratorio no existe');
      }
      throw Exception('Error eliminando laboratorio: $e');
    }
  }

  // Verificar si un código ya existe
  static Future<bool> codigoExiste(String codigo) async {
    try {
      final laboratorios = await getAll();
      return laboratorios
          .any((lab) => lab.codigo.toLowerCase() == codigo.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  // Obtener laboratorios por estado
  static Future<List<LaboratorioModel>> getByEstado(String estado) async {
    try {
      final laboratorios = await getAll();
      return laboratorios.where((lab) => lab.estado == estado).toList();
    } catch (e) {
      throw Exception('Error obteniendo laboratorios por estado: $e');
    }
  }

  // Obtener laboratorios activos
  static Future<List<LaboratorioModel>> getActivos() async {
    return getByEstado('activo');
  }

  // Buscar laboratorios por nombre o código
  static Future<List<LaboratorioModel>> buscar(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAll();
      }

      final laboratorios = await getAll();
      final queryLower = query.toLowerCase();

      return laboratorios.where((lab) {
        return lab.nombre.toLowerCase().contains(queryLower) ||
            lab.codigo.toLowerCase().contains(queryLower) ||
            (lab.ubicacion?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error buscando laboratorios: $e');
    }
  }

  // Validar datos de laboratorio antes de crear/actualizar
  static String? validarDatos({
    String? nombre,
    String? codigo,
    int? capacidad,
    String? estado,
  }) {
    if (nombre != null) {
      if (nombre.trim().isEmpty) {
        return 'El nombre no puede estar vacío';
      }
      if (nombre.length < 3) {
        return 'El nombre debe tener al menos 3 caracteres';
      }
      if (nombre.length > 100) {
        return 'El nombre no puede exceder 100 caracteres';
      }
    }

    if (codigo != null) {
      if (codigo.trim().isEmpty) {
        return 'El código no puede estar vacío';
      }
      if (codigo.length < 2) {
        return 'El código debe tener al menos 2 caracteres';
      }
      if (codigo.length > 20) {
        return 'El código no puede exceder 20 caracteres';
      }
      // Solo letras, números y guiones
      if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(codigo)) {
        return 'El código solo puede contener letras, números y guiones';
      }
    }

    if (capacidad != null) {
      if (capacidad <= 0) {
        return 'La capacidad debe ser mayor a 0';
      }
      if (capacidad > 200) {
        return 'La capacidad no puede exceder 200 personas';
      }
    }

    if (estado != null) {
      if (!['activo', 'mantenimiento', 'inactivo'].contains(estado)) {
        return 'Estado inválido';
      }
    }

    return null; // No hay errores
  }

  // Obtener estadísticas de laboratorios
  static Future<Map<String, int>> getEstadisticas() async {
    try {
      final laboratorios = await getAll();

      return {
        'total': laboratorios.length,
        'activos': laboratorios.where((lab) => lab.estado == 'activo').length,
        'mantenimiento':
            laboratorios.where((lab) => lab.estado == 'mantenimiento').length,
        'inactivos':
            laboratorios.where((lab) => lab.estado == 'inactivo').length,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }
}