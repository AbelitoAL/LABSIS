// lib/services/auxiliar_service.dart

import '../config/api_config.dart';
import '../models/auxiliar_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AuxiliarService {
  // ==========================================
  // OBTENER TODOS LOS AUXILIARES
  // ==========================================
  static Future<List<AuxiliarModel>> getAll() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('👥 Obteniendo lista de auxiliares...');

      final response = await ApiService.get(
        ApiConfig.auxiliaresEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        print('✅ ${data.length} auxiliares obtenidos');
        return data.map((json) => AuxiliarModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo auxiliares');
    } catch (e) {
      print('❌ Error obteniendo auxiliares: $e');
      throw Exception('Error obteniendo auxiliares: $e');
    }
  }

  // ==========================================
  // OBTENER AUXILIAR POR ID
  // ==========================================
  static Future<AuxiliarDetalleModel> getById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('👤 Obteniendo auxiliar $id...');

      final response = await ApiService.get(
        '${ApiConfig.auxiliaresEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        final detalle = AuxiliarDetalleModel.fromJson(response['data']);
        print('✅ Auxiliar obtenido con detalle completo');
        return detalle;
      }

      throw Exception(response['message'] ?? 'Error obteniendo auxiliar');
    } catch (e) {
      print('❌ Error obteniendo auxiliar: $e');
      throw Exception('Error obteniendo auxiliar: $e');
    }
  }

  // ==========================================
  // CREAR AUXILIAR
  // ==========================================
  static Future<bool> create(AuxiliarFormModel form) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('➕ Creando auxiliar ${form.nombre}...');

      // Validar
      final error = validarDatos(form);
      if (error != null) throw Exception(error);

      // Crear auxiliar
      final response = await ApiService.post(
        ApiConfig.auxiliaresEndpoint,
        form.toJson(),
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error creando auxiliar');
      }

      final auxiliarId = response['data']['id'];
      print('✅ Auxiliar creado con ID: $auxiliarId');

      // Asignar laboratorios
      if (form.laboratorios.isNotEmpty) {
        print('🧪 Asignando ${form.laboratorios.length} laboratorios...');
        await asignarLaboratorios(auxiliarId, form.laboratorios);
      }

      // Asignar horarios
      if (form.horarios.isNotEmpty) {
        print('📅 Asignando ${form.horarios.length} horarios...');
        await asignarHorarios(auxiliarId, form.horarios);
      }

      print('✅ Auxiliar creado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error creando auxiliar: $e');
      throw Exception('Error creando auxiliar: $e');
    }
  }

  // ==========================================
  // ACTUALIZAR AUXILIAR
  // ==========================================
  static Future<bool> update(int id, AuxiliarFormModel form) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('✏️ Actualizando auxiliar $id...');

      // Validar
      final error = validarDatos(form);
      if (error != null) throw Exception(error);

      // Actualizar datos básicos
      final response = await ApiService.put(
        '${ApiConfig.auxiliaresEndpoint}/$id',
        form.toJson(),
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error actualizando auxiliar');
      }

      // Asignar laboratorios
      print('🧪 Actualizando laboratorios...');
      await asignarLaboratorios(id, form.laboratorios);

      // Asignar horarios
      print('📅 Actualizando horarios...');
      await asignarHorarios(id, form.horarios);

      print('✅ Auxiliar actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando auxiliar: $e');
      throw Exception('Error actualizando auxiliar: $e');
    }
  }

  // ==========================================
  // ELIMINAR AUXILIAR
  // ==========================================
  static Future<bool> delete(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('🗑️ Eliminando auxiliar $id...');

      final response = await ApiService.delete(
        '${ApiConfig.auxiliaresEndpoint}/$id',
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Auxiliar eliminado exitosamente');
        return true;
      }

      throw Exception(response['message'] ?? 'Error eliminando auxiliar');
    } catch (e) {
      print('❌ Error eliminando auxiliar: $e');
      throw Exception('Error eliminando auxiliar: $e');
    }
  }

  // ==========================================
  // ASIGNAR LABORATORIOS
  // ==========================================
  static Future<bool> asignarLaboratorios(
    int auxiliarId,
    List<int> laboratoriosIds,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.post(
        '${ApiConfig.auxiliaresEndpoint}/$auxiliarId/laboratorios',
        {'laboratorios': laboratoriosIds},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Laboratorios asignados');
        return true;
      }

      throw Exception(response['message'] ?? 'Error asignando laboratorios');
    } catch (e) {
      print('❌ Error asignando laboratorios: $e');
      throw Exception('Error asignando laboratorios: $e');
    }
  }

  // ==========================================
  // ASIGNAR HORARIOS
  // ==========================================
  static Future<bool> asignarHorarios(
    int auxiliarId,
    List<HorarioFormModel> horarios,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final horariosJson = horarios.map((h) => h.toJson()).toList();

      final response = await ApiService.post(
        '${ApiConfig.auxiliaresEndpoint}/$auxiliarId/horarios',
        {'horarios': horariosJson},
        token: token,
      );

      if (response['success'] == true) {
        print('✅ Horarios asignados');
        return true;
      }

      throw Exception(response['message'] ?? 'Error asignando horarios');
    } catch (e) {
      print('❌ Error asignando horarios: $e');
      throw Exception('Error asignando horarios: $e');
    }
  }

  // ==========================================
  // CAMBIAR ESTADO
  // ==========================================
  static Future<bool> cambiarEstado(int auxiliarId, String estado) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      print('🔄 Cambiando estado a $estado...');

      final response = await ApiService.put(
        '${ApiConfig.auxiliaresEndpoint}/$auxiliarId/estado',
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
  static String? validarDatos(AuxiliarFormModel form) {
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

    // Validar contraseña (solo si se proporciona)
    if (form.password != null && form.password!.isNotEmpty) {
      if (form.password!.length < 6) {
        return 'La contraseña debe tener al menos 6 caracteres';
      }
    }

    // Validar teléfono (si se proporciona)
    if (form.telefono != null && form.telefono!.isNotEmpty) {
      if (form.telefono!.length < 8) {
        return 'El teléfono debe tener al menos 8 dígitos';
      }
    }

    // Validar estado
    final estadosValidos = ['activo', 'inactivo', 'vacaciones', 'licencia'];
    if (!estadosValidos.contains(form.estado)) {
      return 'Estado inválido';
    }

    // Validar laboratorios
    if (form.laboratorios.isEmpty) {
      return 'Debe asignar al menos un laboratorio';
    }

    // Validar horarios
    if (form.horarios.isEmpty) {
      return 'Debe agregar al menos un horario';
    }

    final errorHorarios = validarHorarios(form.horarios);
    if (errorHorarios != null) {
      return errorHorarios;
    }

    return null; // Sin errores
  }

  static bool _esEmailValido(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  // ==========================================
  // VALIDAR HORARIOS
  // ==========================================
  static String? validarHorarios(List<HorarioFormModel> horarios) {
    if (horarios.isEmpty) {
      return 'Debe agregar al menos un horario';
    }

    final diasValidos = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo'
    ];

    final diasUsados = <String>{};

    for (int i = 0; i < horarios.length; i++) {
      final horario = horarios[i];

      // Validar día
      if (!diasValidos.contains(horario.diaSemana)) {
        return 'El día "${horario.diaSemana}" no es válido';
      }

      // Verificar días duplicados
      if (diasUsados.contains(horario.diaSemana)) {
        return 'El día ${horario.diaSemana} está duplicado';
      }
      diasUsados.add(horario.diaSemana);

      // Validar formato de horas
      if (!_esHoraValida(horario.horaInicio)) {
        return 'Hora de inicio inválida en ${horario.diaSemana}';
      }

      if (!_esHoraValida(horario.horaFin)) {
        return 'Hora de fin inválida en ${horario.diaSemana}';
      }

      // Validar que hora inicio < hora fin
      if (!_horaInicioMenorQueFin(horario.horaInicio, horario.horaFin)) {
        return 'En ${horario.diaSemana}: la hora de inicio debe ser menor a la hora de fin';
      }

      // Validar duración mínima (al menos 1 hora)
      if (horario.duracion < 1) {
        return 'En ${horario.diaSemana}: la duración mínima es de 1 hora';
      }

      // Validar duración máxima (no más de 12 horas)
      if (horario.duracion > 12) {
        return 'En ${horario.diaSemana}: la duración máxima es de 12 horas';
      }
    }

    // Validar total de horas semanales
    double totalHoras = 0;
    for (var horario in horarios) {
      totalHoras += horario.duracion;
    }

    if (totalHoras > 48) {
      return 'El total de horas semanales no puede exceder 48 horas';
    }

    return null; // Sin errores
  }

  static bool _esHoraValida(String hora) {
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(hora);
  }

  static bool _horaInicioMenorQueFin(String inicio, String fin) {
    final inicioMinutos = _convertirAMinutos(inicio);
    final finMinutos = _convertirAMinutos(fin);
    return inicioMinutos < finMinutos;
  }

  static int _convertirAMinutos(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  // Obtener lista de días de la semana
  static List<String> get diasSemana => [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo',
      ];

  // Obtener lista de estados
  static List<Map<String, String>> get estados => [
        {'valor': 'activo', 'texto': 'Activo', 'emoji': '✅'},
        {'valor': 'inactivo', 'texto': 'Inactivo', 'emoji': '❌'},
        {'valor': 'vacaciones', 'texto': 'Vacaciones', 'emoji': '🏖️'},
        {'valor': 'licencia', 'texto': 'Licencia', 'emoji': '🏥'},
      ];

  // Formatear fecha
  static String formatearFecha(String? fecha) {
    if (fecha == null) return 'Sin fecha';

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

  // Calcular total de horas de horarios
  static double calcularTotalHoras(List<HorarioFormModel> horarios) {
    double total = 0;
    for (var horario in horarios) {
      total += horario.duracion;
    }
    return total;
  }
}