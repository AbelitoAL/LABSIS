// lib/models/auxiliar_model.dart

class AuxiliarModel {
  final int id;
  final String email;
  final String nombre;
  final String? telefono;
  final String estado;
  final String? notas;
  final int activo;
  final List<LaboratorioAsignadoModel> laboratorios;
  final List<HorarioModel> horarios;
  final int cantidadLaboratorios;
  final double horasSemanales;
  final String createdAt;
  final String updatedAt;

  AuxiliarModel({
    required this.id,
    required this.email,
    required this.nombre,
    this.telefono,
    required this.estado,
    this.notas,
    required this.activo,
    required this.laboratorios,
    required this.horarios,
    required this.cantidadLaboratorios,
    required this.horasSemanales,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuxiliarModel.fromJson(Map<String, dynamic> json) {
    List<LaboratorioAsignadoModel> laboratoriosList = [];
    if (json['laboratorios'] != null) {
      laboratoriosList = (json['laboratorios'] as List)
          .map((lab) => LaboratorioAsignadoModel.fromJson(lab))
          .toList();
    }

    List<HorarioModel> horariosList = [];
    if (json['horarios'] != null) {
      horariosList = (json['horarios'] as List)
          .map((hor) => HorarioModel.fromJson(hor))
          .toList();
    }

    return AuxiliarModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      estado: json['estado'] as String? ?? 'activo',
      notas: json['notas'] as String?,
      activo: json['activo'] as int? ?? 1,
      laboratorios: laboratoriosList,
      horarios: horariosList,
      cantidadLaboratorios: json['cantidad_laboratorios'] as int? ?? 0,
      horasSemanales: (json['horas_semanales'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'estado': estado,
      'notas': notas,
      'activo': activo,
    };
  }

  // Obtener iniciales para el avatar
  String get iniciales {
    final partes = nombre.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    } else if (partes.isNotEmpty) {
      return partes[0].substring(0, partes[0].length > 1 ? 2 : 1).toUpperCase();
    }
    return 'AU';
  }

  // Verificar si está activo
  bool get estaActivo => estado == 'activo' && activo == 1;

  // Obtener color según estado
  int get colorEstado {
    switch (estado) {
      case 'activo':
        return 0xFF4CAF50; // Verde
      case 'inactivo':
        return 0xFFE57373; // Rojo
      case 'vacaciones':
        return 0xFF64B5F6; // Azul
      case 'licencia':
        return 0xFFFFB74D; // Naranja
      default:
        return 0xFF9E9E9E; // Gris
    }
  }

  // Obtener emoji según estado
  String get emojiEstado {
    switch (estado) {
      case 'activo':
        return '✅';
      case 'inactivo':
        return '❌';
      case 'vacaciones':
        return '🏖️';
      case 'licencia':
        return '🏥';
      default:
        return '❓';
    }
  }

  // Obtener texto del estado
  String get textoEstado {
    switch (estado) {
      case 'activo':
        return 'Activo';
      case 'inactivo':
        return 'Inactivo';
      case 'vacaciones':
        return 'Vacaciones';
      case 'licencia':
        return 'Licencia';
      default:
        return 'Desconocido';
    }
  }
}

// Modelo de laboratorio asignado
class LaboratorioAsignadoModel {
  final int id;
  final String nombre;
  final String codigo;
  final String? ubicacion;
  final String? estado;
  final String? fechaAsignacion;
  final String? asignadoPor;

  LaboratorioAsignadoModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.ubicacion,
    this.estado,
    this.fechaAsignacion,
    this.asignadoPor,
  });

  factory LaboratorioAsignadoModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioAsignadoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      ubicacion: json['ubicacion'] as String?,
      estado: json['estado'] as String?,
      fechaAsignacion: json['fecha_asignacion'] as String?,
      asignadoPor: json['asignado_por'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'ubicacion': ubicacion,
      'estado': estado,
    };
  }

  // Obtener emoji según nombre del laboratorio
  String get emoji {
    final nombreLower = nombre.toLowerCase();
    
    if (nombreLower.contains('química') || nombreLower.contains('quimica')) {
      return '🧪';
    } else if (nombreLower.contains('computación') || nombreLower.contains('computacion') || nombreLower.contains('sistemas')) {
      return '💻';
    } else if (nombreLower.contains('física') || nombreLower.contains('fisica')) {
      return '⚡';
    } else if (nombreLower.contains('biología') || nombreLower.contains('biologia')) {
      return '🔬';
    } else if (nombreLower.contains('electrónica') || nombreLower.contains('electronica')) {
      return '🔌';
    } else if (nombreLower.contains('mecánica') || nombreLower.contains('mecanica')) {
      return '⚙️';
    } else if (nombreLower.contains('redes')) {
      return '🌐';
    } else {
      return '🏢';
    }
  }
}

// Modelo de horario
class HorarioModel {
  final int id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final String createdAt;
  final String updatedAt;

  HorarioModel({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HorarioModel.fromJson(Map<String, dynamic> json) {
    return HorarioModel(
      id: json['id'] as int,
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    };
  }

  // Calcular duración en horas
  double get duracionHoras {
    final inicio = _parsearHora(horaInicio);
    final fin = _parsearHora(horaFin);
    return (fin - inicio) / 60.0;
  }

  int _parsearHora(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }

  // Capitalizar día
  String get diaSemanaCapitalizado {
    if (diaSemana.isEmpty) return '';
    return diaSemana[0].toUpperCase() + diaSemana.substring(1);
  }

  // Formato de tiempo para mostrar
  String get tiempoFormateado {
    return '$horaInicio - $horaFin (${duracionHoras.toStringAsFixed(1)}h)';
  }
}

// Modelo para detalle completo del auxiliar
class AuxiliarDetalleModel {
  final AuxiliarModel auxiliar;
  final List<LaboratorioAsignadoModel> laboratorios;
  final List<HorarioModel> horarios;
  final EstadisticasAuxiliarModel estadisticas;

  AuxiliarDetalleModel({
    required this.auxiliar,
    required this.laboratorios,
    required this.horarios,
    required this.estadisticas,
  });

  factory AuxiliarDetalleModel.fromJson(Map<String, dynamic> json) {
    // Construir auxiliar básico
    final auxiliarData = {
      'id': json['auxiliar']['id'],
      'email': json['auxiliar']['email'],
      'nombre': json['auxiliar']['nombre'],
      'telefono': json['auxiliar']['telefono'],
      'estado': json['auxiliar']['estado'],
      'notas': json['auxiliar']['notas'],
      'activo': json['auxiliar']['activo'],
      'created_at': json['auxiliar']['created_at'],
      'updated_at': json['auxiliar']['updated_at'],
      'laboratorios': json['laboratorios'],
      'horarios': json['horarios'],
      'cantidad_laboratorios': json['estadisticas']['cantidad_laboratorios'],
      'horas_semanales': json['estadisticas']['horas_semanales'],
    };

    return AuxiliarDetalleModel(
      auxiliar: AuxiliarModel.fromJson(auxiliarData),
      laboratorios: (json['laboratorios'] as List)
          .map((lab) => LaboratorioAsignadoModel.fromJson(lab))
          .toList(),
      horarios: (json['horarios'] as List)
          .map((hor) => HorarioModel.fromJson(hor))
          .toList(),
      estadisticas: EstadisticasAuxiliarModel.fromJson(json['estadisticas']),
    );
  }
}

// Modelo de estadísticas del auxiliar
class EstadisticasAuxiliarModel {
  final int cantidadLaboratorios;
  final double horasSemanales;
  final Map<String, double> horasPorDia;
  final int cantidadDias;
  final int totalTareas;
  final int tareasCompletadas;
  final int tareasPendientes;

  EstadisticasAuxiliarModel({
    required this.cantidadLaboratorios,
    required this.horasSemanales,
    required this.horasPorDia,
    required this.cantidadDias,
    required this.totalTareas,
    required this.tareasCompletadas,
    required this.tareasPendientes,
  });

  factory EstadisticasAuxiliarModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> horasPorDiaMap = {};
    if (json['horas_por_dia'] != null) {
      (json['horas_por_dia'] as Map<String, dynamic>).forEach((key, value) {
        horasPorDiaMap[key] = (value as num).toDouble();
      });
    }

    return EstadisticasAuxiliarModel(
      cantidadLaboratorios: json['cantidad_laboratorios'] as int? ?? 0,
      horasSemanales: (json['horas_semanales'] as num?)?.toDouble() ?? 0.0,
      horasPorDia: horasPorDiaMap,
      cantidadDias: json['cantidad_dias'] as int? ?? 0,
      totalTareas: json['total_tareas'] as int? ?? 0,
      tareasCompletadas: json['tareas_completadas'] as int? ?? 0,
      tareasPendientes: json['tareas_pendientes'] as int? ?? 0,
    );
  }

  // Porcentaje de tareas completadas
  double get porcentajeCompletadas {
    if (totalTareas == 0) return 0;
    return (tareasCompletadas / totalTareas) * 100;
  }
}

// Modelo para crear/actualizar auxiliar
class AuxiliarFormModel {
  final String email;
  final String? password;
  final String nombre;
  final String? telefono;
  final String estado;
  final String? notas;
  final List<int> laboratorios;
  final List<HorarioFormModel> horarios;

  AuxiliarFormModel({
    required this.email,
    this.password,
    required this.nombre,
    this.telefono,
    required this.estado,
    this.notas,
    required this.laboratorios,
    required this.horarios,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'estado': estado,
      'notas': notas,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    return data;
  }

  Map<String, dynamic> laboratoriosToJson() {
    return {'laboratorios': laboratorios};
  }

  Map<String, dynamic> horariosToJson() {
    return {
      'horarios': horarios.map((h) => h.toJson()).toList(),
    };
  }
}

// Modelo para horarios en formulario
class HorarioFormModel {
  final String diaSemana;
  final String horaInicio;
  final String horaFin;

  HorarioFormModel({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    };
  }

  // Calcular duración
  double get duracion {
    final inicio = _parsearHora(horaInicio);
    final fin = _parsearHora(horaFin);
    return (fin - inicio) / 60.0;
  }

  int _parsearHora(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }
}