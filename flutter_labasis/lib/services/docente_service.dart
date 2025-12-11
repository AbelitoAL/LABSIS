// lib/services/docente_service.dart

import '../config/api_config.dart';
import '../models/docente_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DocenteService {
  // ==========================================
  // OBTENER TODOS LOS DOCENTES
  // ==========================================
  static Future<List<DocenteModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('👨‍🏫 Obteniendo lista de docentes...');

      final response = await ApiService.get(
        ApiConfig.docentesEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        print('✅ ${data.length} docentes obtenidos');
        return data.map((json) => DocenteModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo docentes');
    } catch (e) {
      print('❌ Error obteniendo docentes: $e');
      throw Exception('Error obteniendo docentes: $e');
    }
  }

  // ==========================================
  // OBTENER DOCENTE POR ID
  // ==========================================
  static Future<DocenteDetalleModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('👤 Obteniendo docente $id...');

      final response = await ApiService.get(
        '${ApiConfig.docentesEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        final detalle = DocenteDetalleModel.fromJson(response['data']);
        print('✅ Docente obtenido con detalle completo');
        return detalle;
      }

      throw Exception(response['message'] ?? 'Error obteniendo docente');
    } catch (e) {
      print('❌ Error obteniendo docente: $e');
      throw Exception('Error obteniendo docente: $e');
    }
  }

  // ==========================================
  // CREAR DOCENTE
  // ==========================================
  static Future<bool> create(DocenteFormModel form) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('➕ Creando docente ${form.nombre}...');

      // Validar
      final error = validarDatos(form, esCreacion: true);
      if (error != null) throw Exception(error);

      // Crear docente
      final response = await ApiService.post(
        ApiConfig.docentesEndpoint,
        form.toJson(),
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error creando docente');
      }

      final docenteId = response['data']['id'];
      print('✅ Docente creado con ID: $docenteId');
      return true;
    } catch (e) {
      print('❌ Error creando docente: $e');
      throw Exception('Error creando docente: $e');
    }
  }

  // ==========================================
  // ACTUALIZAR DOCENTE
  // ==========================================
  static Future<bool> update(int id, DocenteFormModel form) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('✏️ Actualizando docente $id...');

      // Validar
      final error = validarDatos(form, esCreacion: false);
      if (error != null) throw Exception(error);

      // Actualizar datos
      final response = await ApiService.put(
        '${ApiConfig.docentesEndpoint}/$id',
        form.toJson(),
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando docente');
      }

      print('✅ Docente actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando docente: $e');
      throw Exception('Error actualizando docente: $e');
    }
  }

  // ==========================================
  // ELIMINAR DOCENTE
  // ==========================================
  static Future<bool> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('🗑️ Eliminando docente $id...');

      final response = await ApiService.delete(
        '${ApiConfig.docentesEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Docente eliminado exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error eliminando docente');
    } catch (e) {
      print('❌ Error eliminando docente: $e');
      
      // Manejar error específico de reservas activas
      if (e.toString().contains('reserva(s) activa(s)')) {
        throw Exception('No se puede eliminar: el docente tiene reservas activas');
      }
      
      throw Exception('Error eliminando docente: $e');
    }
  }

  // ==========================================
  // CAMBIAR ESTADO
  // ==========================================
  static Future<bool> cambiarEstado(int docenteId, String estado) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('🔄 Cambiando estado a $estado...');

      final response = await ApiService.put(
        '${ApiConfig.docentesEndpoint}/$docenteId/estado',
        {'estado': estado},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Estado cambiado exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error cambiando estado');
    } catch (e) {
      print('❌ Error cambiando estado: $e');
      throw Exception('Error cambiando estado: $e');
    }
  }

  // ==========================================
  // VALIDACIONES
  // ==========================================
  static String? validarDatos(DocenteFormModel form, {required bool esCreacion}) {
    // Validar email
    if (form.email.trim().isEmpty) {
      return 'El email es requerido';
    }

    if (!_esEmailValido(form.email)) {
      return 'El formato del email no es válido';
    }

    // Validar nombre
    if (form.nombre.trim().isEmpty) {
      return 'El nombre es requerido';
    }

    if (form.nombre.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    // Validar código
    if (form.codigo.trim().isEmpty) {
      return 'El código es requerido';
    }

    if (!_esCodigoValido(form.codigo)) {
      return 'El código solo puede contener letras, números y guiones';
    }

    if (form.codigo.length < 3) {
      return 'El código debe tener al menos 3 caracteres';
    }

    // Validar contraseña (solo si se proporciona)
    if (esCreacion) {
      // En creación es obligatoria
      if (form.password == null || form.password!.isEmpty) {
        return 'La contraseña es requerida';
      }
      if (form.password!.length < 6) {
        return 'La contraseña debe tener al menos 6 caracteres';
      }
    } else {
      // En edición es opcional
      if (form.password != null && form.password!.isNotEmpty) {
        if (form.password!.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
      }
    }

    // Validar teléfono
    if (form.telefono.trim().isEmpty) {
      return 'El teléfono es requerido';
    }

    if (form.telefono.length < 8) {
      return 'El teléfono debe tener al menos 8 dígitos';
    }

    // Validar estado
    final estadosValidos = ['activo', 'inactivo'];
    if (!estadosValidos.contains(form.estado)) {
      return 'Estado inválido';
    }

    return null; // Sin errores
  }

  static bool _esEmailValido(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  static bool _esCodigoValido(String codigo) {
    final regex = RegExp(r'^[A-Z0-9-]+$', caseSensitive: false);
    return regex.hasMatch(codigo);
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  // Obtener lista de estados
  static List<Map<String, String>> get estados => [
        {'valor': 'activo', 'texto': 'Activo', 'emoji': '✅'},
        {'valor': 'inactivo', 'texto': 'Inactivo', 'emoji': '❌'},
      ];

  // Formatear fecha
  static String formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return 'Sin fecha';

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

  // Formatear código (convertir a mayúsculas)
  static String formatearCodigo(String codigo) {
    return codigo.toUpperCase().trim();
  }

  // Validar formato de código sugerido
  static String? sugerirFormatoCodigo(String codigo) {
    if (codigo.isEmpty) return null;
    
    // Sugerir formato DOC-XXX si no tiene guión
    if (!codigo.contains('-') && codigo.length >= 3) {
      return 'DOC-${codigo.toUpperCase()}';
    }
    
    return codigo.toUpperCase();
  }
}