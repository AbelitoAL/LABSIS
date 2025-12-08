// lib/services/manual_service.dart

import '../config/api_config.dart';
import '../models/manual_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ManualService {
  // ==========================================
  // OBTENER TODOS LOS MANUALES
  // ==========================================
  static Future<List<ManualModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📖 Obteniendo todos los manuales...');

      final response = await ApiService.get(
        ApiConfig.manualesEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        print('✅ ${data.length} manuales obtenidos');
        return data.map((json) => ManualModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo manuales');
    } catch (e) {
      print('❌ Error obteniendo manuales: $e');
      throw Exception('Error obteniendo manuales: $e');
    }
  }

  // ==========================================
  // OBTENER LABORATORIOS CON INFO DE MANUALES
  // ==========================================
  static Future<List<LaboratorioConManualModel>> getLaboratoriosConManuales() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📖 Obteniendo laboratorios con manuales...');

      final response = await ApiService.get(
        '${ApiConfig.manualesEndpoint}/laboratorios',
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        print('✅ ${data.length} laboratorios obtenidos');
        return data
            .map((json) => LaboratorioConManualModel.fromJson(json))
            .toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo laboratorios');
    } catch (e) {
      print('❌ Error obteniendo laboratorios: $e');
      throw Exception('Error obteniendo laboratorios: $e');
    }
  }

  // ==========================================
  // OBTENER MANUAL POR LABORATORIO
  // ==========================================
  static Future<ManualDetalleModel> getByLaboratorioId(int laboratorioId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📖 Obteniendo manual del laboratorio $laboratorioId...');

      final response = await ApiService.get(
        '${ApiConfig.manualesEndpoint}/laboratorio/$laboratorioId',
        token: token,
      );

      if (response['success'] == true) {
        final detalle = ManualDetalleModel.fromJson(response['data']);
        print('✅ Manual obtenido con ${detalle.items.length} items');
        return detalle;
      }

      throw Exception(response['message'] ?? 'Error obteniendo manual');
    } catch (e) {
      print('❌ Error obteniendo manual: $e');
      throw Exception('Error obteniendo manual: $e');
    }
  }

  // ==========================================
  // CREAR O ACTUALIZAR MANUAL
  // ==========================================
  static Future<bool> createOrUpdate({
    required int laboratorioId,
    required List<ManualItemModel> items,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📖 Guardando manual del laboratorio $laboratorioId...');

      // Convertir items a JSON
      final itemsJson = items.map((item) => item.toJson()).toList();

      final response = await ApiService.post(
        '${ApiConfig.manualesEndpoint}/laboratorio/$laboratorioId',
        {'items': itemsJson}, // ← SIN 'body:'
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Manual guardado exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error guardando manual');
    } catch (e) {
      print('❌ Error guardando manual: $e');
      throw Exception('Error guardando manual: $e');
    }
  }

  // ==========================================
  // ELIMINAR MANUAL
  // ==========================================
  static Future<bool> delete(int laboratorioId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📖 Eliminando manual del laboratorio $laboratorioId...');

      final response = await ApiService.delete(
        '${ApiConfig.manualesEndpoint}/laboratorio/$laboratorioId',
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Manual eliminado exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error eliminando manual');
    } catch (e) {
      print('❌ Error eliminando manual: $e');
      throw Exception('Error eliminando manual: $e');
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  // Validar items antes de guardar
  static String? validarItems(List<ManualItemModel> items) {
    if (items.isEmpty) {
      return 'Debes agregar al menos un item';
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item.titulo.trim().isEmpty) {
        return 'El título del item ${i + 1} no puede estar vacío';
      }
      
      if (item.descripcion.trim().isEmpty) {
        return 'La descripción del item ${i + 1} no puede estar vacía';
      }

      if (item.titulo.length > 100) {
        return 'El título del item ${i + 1} es muy largo (máx. 100 caracteres)';
      }

      if (item.descripcion.length > 500) {
        return 'La descripción del item ${i + 1} es muy larga (máx. 500 caracteres)';
      }
    }

    return null; // Sin errores
  }

  // Formatear fecha de actualización
  static String formatearFecha(String? fecha) {
    if (fecha == null) return 'Sin actualizar';

    try {
      final dateTime = DateTime.parse(fecha);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Hace un momento';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} hrs';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Sin fecha';
    }
  }

  // Obtener icono para el título de un item
  static String getIconoParaTitulo(String titulo) {
    final tituloLower = titulo.toLowerCase();

    if (tituloLower.contains('contraseña') || tituloLower.contains('password')) {
      return '🔑';
    } else if (tituloLower.contains('wifi') || tituloLower.contains('red')) {
      return '🌐';
    } else if (tituloLower.contains('software') || tituloLower.contains('programa')) {
      return '💾';
    } else if (tituloLower.contains('equipo') || tituloLower.contains('hardware')) {
      return '🔌';
    } else if (tituloLower.contains('contacto') || tituloLower.contains('teléfono')) {
      return '📞';
    } else if (tituloLower.contains('horario')) {
      return '🕐';
    } else if (tituloLower.contains('regla') || tituloLower.contains('norma')) {
      return '📋';
    } else if (tituloLower.contains('emergencia')) {
      return '🚨';
    } else {
      return '📝';
    }
  }
}