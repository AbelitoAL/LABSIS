// lib/services/reserva_service.dart

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/reserva_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ReservaService {
  // ==========================================
  // OBTENER TODAS LAS RESERVAS
  // ==========================================
  static Future<List<ReservaModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📅 Obteniendo reservas...');

      final response = await ApiService.get(
        ApiConfig.reservasEndpoint,
        token: token,
      );

      print('📦 Respuesta del backend:');
      print('  - success: ${response['success']}');
      print('  - data type: ${response['data'].runtimeType}');
      print('  - data length: ${response['data'] is List ? (response['data'] as List).length : 'N/A'}');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        print('✅ ${data.length} reservas obtenidas');
        
        if (data.isEmpty) {
          print('⚠️ La lista está vacía - verificar backend');
        } else {
          print('📋 Primera reserva:');
          print(data[0]);
        }
        
        return data.map((json) => ReservaModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo reservas');
    } catch (e) {
      print('❌ Error obteniendo reservas: $e');
      throw Exception('Error obteniendo reservas: $e');
    }
  }

  // ==========================================
  // OBTENER RESERVA POR ID
  // ==========================================
  static Future<ReservaModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('📋 Obteniendo reserva $id...');

      final response = await ApiService.get(
        '${ApiConfig.reservasEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva obtenida');
        return ReservaModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Error obteniendo reserva');
    } catch (e) {
      print('❌ Error obteniendo reserva: $e');
      throw Exception('Error obteniendo reserva: $e');
    }
  }

  // ==========================================
  // CREAR RESERVA (SOLO DOCENTES)
  // ==========================================
  static Future<bool> create(ReservaFormModel form) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('➕ Creando reserva...');

      // Validar
      final error = validarDatos(form);
      if (error != null) throw Exception(error);

      final response = await ApiService.post(
        ApiConfig.reservasEndpoint,
        form.toJson(),
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva creada exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error creando reserva');
    } catch (e) {
      print('❌ Error creando reserva: $e');
      throw Exception('Error creando reserva: $e');
    }
  }

  // ==========================================
  // APROBAR RESERVA (SOLO ADMIN)
  // ==========================================
  static Future<bool> aprobar(int reservaId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('✅ Aprobando reserva $reservaId...');

      final response = await ApiService.patch(
        '${ApiConfig.reservasEndpoint}/$reservaId/aprobar',
        {},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva aprobada');
        return true;
      }

      throw Exception(response['message'] ?? 'Error aprobando reserva');
    } catch (e) {
      print('❌ Error aprobando reserva: $e');
      throw Exception('Error aprobando reserva: $e');
    }
  }

  // ==========================================
  // RECHAZAR RESERVA (SOLO ADMIN)
  // ==========================================
  static Future<bool> rechazar(int reservaId, String motivo) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      if (motivo.trim().isEmpty) {
        throw Exception('El motivo de rechazo es requerido');
      }

      print('❌ Rechazando reserva $reservaId...');

      final response = await ApiService.patch(
        '${ApiConfig.reservasEndpoint}/$reservaId/rechazar',
        {'motivo_rechazo': motivo.trim()},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva rechazada');
        return true;
      }

      throw Exception(response['message'] ?? 'Error rechazando reserva');
    } catch (e) {
      print('❌ Error rechazando reserva: $e');
      throw Exception('Error rechazando reserva: $e');
    }
  }

  // ==========================================
  // CANCELAR RESERVA (DOCENTE)
  // ==========================================
  static Future<bool> cancelar(int reservaId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('⚫ Cancelando reserva $reservaId...');

      final response = await ApiService.patch(
        '${ApiConfig.reservasEndpoint}/$reservaId/cancelar',
        {},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva cancelada');
        return true;
      }

      throw Exception(response['message'] ?? 'Error cancelando reserva');
    } catch (e) {
      print('❌ Error cancelando reserva: $e');
      throw Exception('Error cancelando reserva: $e');
    }
  }

  // ==========================================
  // ELIMINAR RESERVA (SOLO ADMIN)
  // ==========================================
  static Future<bool> delete(int reservaId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('🗑️ Eliminando reserva $reservaId...');

      final response = await ApiService.delete(
        '${ApiConfig.reservasEndpoint}/$reservaId',
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Reserva eliminada');
        return true;
      }

      throw Exception(response['message'] ?? 'Error eliminando reserva');
    } catch (e) {
      print('❌ Error eliminando reserva: $e');
      throw Exception('Error eliminando reserva: $e');
    }
  }

  // ==========================================
  // VALIDACIONES
  // ==========================================
  static String? validarDatos(ReservaFormModel form) {
    // Validar laboratorio
    if (form.laboratorioId <= 0) {
      return 'Debe seleccionar un laboratorio';
    }

    // Validar fecha
    if (form.fecha.trim().isEmpty) {
      return 'La fecha es requerida';
    }

    // Validar formato de fecha (YYYY-MM-DD)
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(form.fecha)) {
      return 'Formato de fecha inválido';
    }

    // Validar que la fecha no sea pasada
    try {
      final fechaReserva = DateTime.parse(form.fecha);
      final hoy = DateTime.now();
      hoy.setHours(0, 0, 0, 0);

      if (fechaReserva.isBefore(hoy)) {
        return 'No se pueden hacer reservas en fechas pasadas';
      }
    } catch (e) {
      return 'Fecha inválida';
    }

    // Validar horas
    if (form.horaInicio.trim().isEmpty || form.horaFin.trim().isEmpty) {
      return 'Las horas son requeridas';
    }

    // Validar formato de hora (HH:MM)
    final regexHora = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!regexHora.hasMatch(form.horaInicio)) {
      return 'Formato de hora de inicio inválido (usar HH:MM)';
    }

    if (!regexHora.hasMatch(form.horaFin)) {
      return 'Formato de hora de fin inválido (usar HH:MM)';
    }

    // Validar que hora_inicio < hora_fin
    final inicioMinutos = _convertirAMinutos(form.horaInicio);
    final finMinutos = _convertirAMinutos(form.horaFin);

    if (inicioMinutos >= finMinutos) {
      return 'La hora de inicio debe ser menor a la hora de fin';
    }

    // Validar duración (mínimo 30 min, máximo 8 horas)
    final duracionMinutos = finMinutos - inicioMinutos;

    if (duracionMinutos < 30) {
      return 'La duración mínima es de 30 minutos';
    }

    if (duracionMinutos > 480) {
      return 'La duración máxima es de 8 horas';
    }

    // Validar materia
    if (form.materia.trim().isEmpty) {
      return 'La materia es requerida';
    }

    if (form.materia.length < 3) {
      return 'La materia debe tener al menos 3 caracteres';
    }

    // Validar anticipación mínima (24 horas)
    try {
      final fechaHoraReserva = DateTime.parse('${form.fecha}T${form.horaInicio}:00');
      final ahora = DateTime.now();
      final diferenciaHoras = fechaHoraReserva.difference(ahora).inHours;

      if (diferenciaHoras < 24) {
        return 'Debes reservar con al menos 24 horas de anticipación';
      }
    } catch (e) {
      return 'Error validando anticipación';
    }

    return null; // Sin errores
  }

  static int _convertirAMinutos(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }

  // ==========================================
  // FILTROS
  // ==========================================

  // Filtrar por estado
  static List<ReservaModel> filtrarPorEstado(
    List<ReservaModel> reservas,
    String estado,
  ) {
    if (estado.toLowerCase() == 'todas') return reservas;
    return reservas.where((r) => r.estado == estado).toList();
  }

  // Filtrar por fecha
  static List<ReservaModel> filtrarPorFecha(
    List<ReservaModel> reservas,
    String filtro, // 'hoy', 'semana', 'mes', 'todas'
  ) {
    final ahora = DateTime.now();

    switch (filtro.toLowerCase()) {
      case 'hoy':
        return reservas.where((r) {
          final fecha = DateTime.parse(r.fecha);
          return fecha.year == ahora.year &&
              fecha.month == ahora.month &&
              fecha.day == ahora.day;
        }).toList();

      case 'semana':
        final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
        final finSemana = inicioSemana.add(const Duration(days: 6));

        return reservas.where((r) {
          final fecha = DateTime.parse(r.fecha);
          return fecha.isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
              fecha.isBefore(finSemana.add(const Duration(days: 1)));
        }).toList();

      case 'mes':
        return reservas.where((r) {
          final fecha = DateTime.parse(r.fecha);
          return fecha.year == ahora.year && fecha.month == ahora.month;
        }).toList();

      default:
        return reservas;
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  // Formatear fecha para la API (YYYY-MM-DD)
  static String formatearFechaParaAPI(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  // Formatear hora para la API (HH:MM)
  static String formatearHoraParaAPI(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  // Parsear hora de String a TimeOfDay
  static TimeOfDay parsearHora(String hora) {
    final partes = hora.split(':');
    return TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  // Obtener lista de estados
  static List<Map<String, String>> get estados => [
        {'valor': 'todas', 'texto': 'Todas', 'emoji': '📅'},
        {'valor': 'pendiente', 'texto': 'Pendientes', 'emoji': '🟡'},
        {'valor': 'aprobada', 'texto': 'Aprobadas', 'emoji': '🟢'},
        {'valor': 'rechazada', 'texto': 'Rechazadas', 'emoji': '🔴'},
        {'valor': 'cancelada', 'texto': 'Canceladas', 'emoji': '⚫'},
      ];

  // Obtener filtros de fecha (para auxiliares)
  static List<Map<String, String>> get filtrosFecha => [
        {'valor': 'hoy', 'texto': 'Hoy', 'emoji': '📍'},
        {'valor': 'semana', 'texto': 'Esta Semana', 'emoji': '📆'},
        {'valor': 'mes', 'texto': 'Este Mes', 'emoji': '📅'},
        {'valor': 'todas', 'texto': 'Todas', 'emoji': '🗓️'},
      ];
}

// Extensión para DateTime
extension DateTimeExtension on DateTime {
  void setHours(int hours, int minutes, int seconds, int milliseconds) {
    // Esta función se usa para resetear la hora a 00:00:00
    // En realidad no modifica el DateTime, solo es para referencia
  }
}