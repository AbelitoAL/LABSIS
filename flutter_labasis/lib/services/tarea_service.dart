// lib/services/tarea_service.dart

import '../config/api_config.dart';
import '../models/tarea_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class TareaService {
  // Obtener todas las tareas (filtradas por rol en backend)
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

  // Obtener mis tareas asignadas
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
  static Future<int> create({
    required String titulo,
    required int auxiliarId,
    String? descripcion,
    int? laboratorioId,
    String prioridad = 'media',
    String? fechaLimite,
    List<String>? tags,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validaciones
      if (titulo.trim().isEmpty) {
        throw Exception('El título es requerido');
      }

      // Preparar datos
      final data = {
        'titulo': titulo.trim(),
        'auxiliar_id': auxiliarId,
        if (descripcion != null && descripcion.isNotEmpty)
          'descripcion': descripcion.trim(),
        if (laboratorioId != null) 'laboratorio_id': laboratorioId,
        'prioridad': prioridad,
        if (fechaLimite != null) 'fecha_limite': fechaLimite,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      };

      final response = await ApiService.post(
        ApiConfig.tareasEndpoint,
        data,
        token: token,
      );

      if (response['success'] == true) {
        return response['data']['id'] as int;
      }

      throw Exception(response['message'] ?? 'Error creando tarea');
    } catch (e) {
      if (e.toString().contains('auxiliar')) {
        throw Exception('El auxiliar seleccionado no es válido');
      }
      if (e.toString().contains('laboratorio')) {
        throw Exception('El laboratorio seleccionado no es válido');
      }
      throw Exception('Error creando tarea: $e');
    }
  }

  // Actualizar tarea (admin o auxiliar asignado)
  static Future<void> update({
    required int id,
    String? titulo,
    String? descripcion,
    String? prioridad,
    String? estado,
    String? fechaLimite,
    List<String>? tags,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      // Validar que al menos un campo se va a actualizar
      if (titulo == null &&
          descripcion == null &&
          prioridad == null &&
          estado == null &&
          fechaLimite == null &&
          tags == null) {
        throw Exception('Debes proporcionar al menos un campo para actualizar');
      }

      // Preparar datos
      final data = <String, dynamic>{};

      if (titulo != null && titulo.trim().isNotEmpty) {
        data['titulo'] = titulo.trim();
      }
      if (descripcion != null) {
        data['descripcion'] = descripcion.trim();
      }
      if (prioridad != null && ['baja', 'media', 'alta'].contains(prioridad)) {
        data['prioridad'] = prioridad;
      }
      if (estado != null &&
          ['pendiente', 'en_proceso', 'completada'].contains(estado)) {
        data['estado'] = estado;
      }
      if (fechaLimite != null) {
        data['fecha_limite'] = fechaLimite;
      }
      if (tags != null) {
        data['tags'] = tags;
      }

      final response = await ApiService.put(
        '${ApiConfig.tareasEndpoint}/$id',
        data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando tarea');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La tarea no existe');
      }
      if (e.toString().contains('permiso')) {
        throw Exception('No tienes permiso para actualizar esta tarea');
      }
      throw Exception('Error actualizando tarea: $e');
    }
  }

  // Marcar como completada
  static Future<void> marcarCompletada(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.tareasEndpoint}/$id/completar',
        {},
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(
            response['message'] ?? 'Error marcando tarea como completada');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La tarea no existe');
      }
      if (e.toString().contains('permiso')) {
        throw Exception('No tienes permiso para completar esta tarea');
      }
      throw Exception('Error completando tarea: $e');
    }
  }

  // Actualizar estado (método conveniente)
  static Future<void> updateEstado(int id, String estado) async {
    try {
      if (!['pendiente', 'en_proceso', 'completada'].contains(estado)) {
        throw Exception('Estado inválido');
      }

      await update(id: id, estado: estado);
    } catch (e) {
      throw Exception('Error actualizando estado: $e');
    }
  }

  // Actualizar prioridad (método conveniente)
  static Future<void> updatePrioridad(int id, String prioridad) async {
    try {
      if (!['baja', 'media', 'alta'].contains(prioridad)) {
        throw Exception('Prioridad inválida');
      }

      await update(id: id, prioridad: prioridad);
    } catch (e) {
      throw Exception('Error actualizando prioridad: $e');
    }
  }

  // Eliminar tarea (solo admin)
  static Future<void> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.tareasEndpoint}/$id',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error eliminando tarea');
      }
    } catch (e) {
      if (e.toString().contains('no encontrada')) {
        throw Exception('La tarea no existe');
      }
      throw Exception('Error eliminando tarea: $e');
    }
  }

  // Obtener tareas por estado
  static Future<List<TareaModel>> getByEstado(String estado) async {
    try {
      final tareas = await getAll();
      return tareas.where((tarea) => tarea.estado == estado).toList();
    } catch (e) {
      throw Exception('Error obteniendo tareas por estado: $e');
    }
  }

  // Obtener tareas por prioridad
  static Future<List<TareaModel>> getByPrioridad(String prioridad) async {
    try {
      final tareas = await getAll();
      return tareas.where((tarea) => tarea.prioridad == prioridad).toList();
    } catch (e) {
      throw Exception('Error obteniendo tareas por prioridad: $e');
    }
  }

  // Obtener tareas pendientes
  static Future<List<TareaModel>> getPendientes() async {
    return getByEstado('pendiente');
  }

  // Obtener tareas en proceso
  static Future<List<TareaModel>> getEnProceso() async {
    return getByEstado('en_proceso');
  }

  // Obtener tareas completadas
  static Future<List<TareaModel>> getCompletadas() async {
    return getByEstado('completada');
  }

  // Buscar tareas por título o descripción
  static Future<List<TareaModel>> buscar(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAll();
      }

      final tareas = await getAll();
      final queryLower = query.toLowerCase();

      return tareas.where((tarea) {
        return tarea.titulo.toLowerCase().contains(queryLower) ||
            (tarea.descripcion?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error buscando tareas: $e');
    }
  }

  // Validar datos de tarea
  static String? validarDatos({
    String? titulo,
    String? prioridad,
    String? estado,
  }) {
    if (titulo != null) {
      if (titulo.trim().isEmpty) {
        return 'El título no puede estar vacío';
      }
      if (titulo.length < 3) {
        return 'El título debe tener al menos 3 caracteres';
      }
      if (titulo.length > 200) {
        return 'El título no puede exceder 200 caracteres';
      }
    }

    if (prioridad != null) {
      if (!['baja', 'media', 'alta'].contains(prioridad)) {
        return 'Prioridad inválida';
      }
    }

    if (estado != null) {
      if (!['pendiente', 'en_proceso', 'completada'].contains(estado)) {
        return 'Estado inválido';
      }
    }

    return null;
  }

  // Obtener estadísticas de tareas
  static Future<Map<String, int>> getEstadisticas() async {
    try {
      final tareas = await getAll();

      return {
        'total': tareas.length,
        'pendientes': tareas.where((t) => t.estado == 'pendiente').length,
        'en_proceso': tareas.where((t) => t.estado == 'en_proceso').length,
        'completadas': tareas.where((t) => t.estado == 'completada').length,
        'alta_prioridad': tareas.where((t) => t.prioridad == 'alta').length,
        'media_prioridad': tareas.where((t) => t.prioridad == 'media').length,
        'baja_prioridad': tareas.where((t) => t.prioridad == 'baja').length,
      };
    } catch (e) {
      throw Exception('Error obteniendo estadísticas: $e');
    }
  }

  // Obtener tareas vencidas
  static Future<List<TareaModel>> getTareasVencidas() async {
    try {
      final tareas = await getAll();
      final ahora = DateTime.now();

      return tareas.where((tarea) {
        if (tarea.fechaLimite == null || tarea.estado == 'completada') {
          return false;
        }

        final fechaLimite = DateTime.parse(tarea.fechaLimite!);
        return fechaLimite.isBefore(ahora);
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo tareas vencidas: $e');
    }
  }

  // Obtener tareas próximas a vencer (dentro de 3 días)
  static Future<List<TareaModel>> getTareasProximasVencer() async {
    try {
      final tareas = await getAll();
      final ahora = DateTime.now();
      final tresDiasDespues = ahora.add(const Duration(days: 3));

      return tareas.where((tarea) {
        if (tarea.fechaLimite == null || tarea.estado == 'completada') {
          return false;
        }

        final fechaLimite = DateTime.parse(tarea.fechaLimite!);
        return fechaLimite.isAfter(ahora) &&
            fechaLimite.isBefore(tresDiasDespues);
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo tareas próximas a vencer: $e');
    }
  }
}