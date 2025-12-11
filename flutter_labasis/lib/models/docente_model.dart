// lib/models/docente_model.dart

class DocenteModel {
  final int id;
  final String email;
  final String nombre;
  final String telefono;
  final String codigo;
  final String estado;
  final int activo;
  final int? docenteId;
  final EstadisticasDocenteModel estadisticas;
  final String createdAt;
  final String updatedAt;

  DocenteModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.telefono,
    required this.codigo,
    required this.estado,
    required this.activo,
    this.docenteId,
    required this.estadisticas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocenteModel.fromJson(Map<String, dynamic> json) {
    return DocenteModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String? ?? '',
      codigo: json['codigo'] as String,
      estado: json['estado'] as String? ?? 'activo',
      activo: json['activo'] as int? ?? 1,
      docenteId: json['docente_id'] as int?,
      estadisticas: json['estadisticas'] != null
          ? EstadisticasDocenteModel.fromJson(json['estadisticas'])
          : EstadisticasDocenteModel.empty(),
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
      'codigo': codigo,
      'estado': estado,
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
    return 'DO';
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
      default:
        return 'Desconocido';
    }
  }
}

// Modelo de estadísticas del docente
class EstadisticasDocenteModel {
  final int totalReservas;
  final int reservasPendientes;
  final int reservasAprobadas;
  final int reservasRechazadas;
  final int reservasCanceladas;

  EstadisticasDocenteModel({
    required this.totalReservas,
    required this.reservasPendientes,
    required this.reservasAprobadas,
    required this.reservasRechazadas,
    this.reservasCanceladas = 0,
  });

  factory EstadisticasDocenteModel.fromJson(Map<String, dynamic> json) {
    return EstadisticasDocenteModel(
      totalReservas: json['total_reservas'] as int? ?? 0,
      reservasPendientes: json['reservas_pendientes'] as int? ?? 0,
      reservasAprobadas: json['reservas_aprobadas'] as int? ?? 0,
      reservasRechazadas: json['reservas_rechazadas'] as int? ?? 0,
      reservasCanceladas: json['reservas_canceladas'] as int? ?? 0,
    );
  }

  factory EstadisticasDocenteModel.empty() {
    return EstadisticasDocenteModel(
      totalReservas: 0,
      reservasPendientes: 0,
      reservasAprobadas: 0,
      reservasRechazadas: 0,
      reservasCanceladas: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reservas': totalReservas,
      'reservas_pendientes': reservasPendientes,
      'reservas_aprobadas': reservasAprobadas,
      'reservas_rechazadas': reservasRechazadas,
      'reservas_canceladas': reservasCanceladas,
    };
  }

  // Porcentaje de reservas aprobadas
  double get porcentajeAprobadas {
    if (totalReservas == 0) return 0;
    return (reservasAprobadas / totalReservas) * 100;
  }

  // Tiene reservas activas (pendientes o aprobadas)
  bool get tieneReservasActivas {
    return reservasPendientes > 0 || reservasAprobadas > 0;
  }
}

// Modelo de reserva reciente (para detalle)
class ReservaRecenteModel {
  final int id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String materia;
  final String estado;
  final String laboratorioNombre;
  final String laboratorioCodigo;

  ReservaRecenteModel({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.materia,
    required this.estado,
    required this.laboratorioNombre,
    required this.laboratorioCodigo,
  });

  factory ReservaRecenteModel.fromJson(Map<String, dynamic> json) {
    return ReservaRecenteModel(
      id: json['id'] as int,
      fecha: json['fecha'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      materia: json['materia'] as String,
      estado: json['estado'] as String,
      laboratorioNombre: json['laboratorio_nombre'] as String,
      laboratorioCodigo: json['laboratorio_codigo'] as String,
    );
  }

  // Color según estado
  int get colorEstado {
    switch (estado) {
      case 'pendiente':
        return 0xFFFFA726; // Naranja
      case 'aprobada':
        return 0xFF66BB6A; // Verde
      case 'rechazada':
        return 0xFFEF5350; // Rojo
      case 'cancelada':
        return 0xFF9E9E9E; // Gris
      default:
        return 0xFF42A5F5; // Azul
    }
  }

  // Emoji según estado
  String get emojiEstado {
    switch (estado) {
      case 'pendiente':
        return '🟡';
      case 'aprobada':
        return '🟢';
      case 'rechazada':
        return '🔴';
      case 'cancelada':
        return '⚫';
      default:
        return '🔵';
    }
  }
}

// Modelo de laboratorio frecuente
class LaboratorioFrecuenteModel {
  final int id;
  final String nombre;
  final String codigo;
  final int cantidadReservas;

  LaboratorioFrecuenteModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.cantidadReservas,
  });

  factory LaboratorioFrecuenteModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioFrecuenteModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      cantidadReservas: json['cantidad_reservas'] as int,
    );
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

// Modelo para detalle completo del docente
class DocenteDetalleModel {
  final DocenteModel docente;
  final List<ReservaRecenteModel> reservasRecientes;
  final List<LaboratorioFrecuenteModel> laboratoriosFrecuentes;
  final EstadisticasDocenteModel estadisticas;

  DocenteDetalleModel({
    required this.docente,
    required this.reservasRecientes,
    required this.laboratoriosFrecuentes,
    required this.estadisticas,
  });

  factory DocenteDetalleModel.fromJson(Map<String, dynamic> json) {
    // Construir docente básico
    final docenteData = json['docente'] as Map<String, dynamic>;
    docenteData['estadisticas'] = json['estadisticas'];

    return DocenteDetalleModel(
      docente: DocenteModel.fromJson(docenteData),
      reservasRecientes: (json['reservas_recientes'] as List? ?? [])
          .map((r) => ReservaRecenteModel.fromJson(r))
          .toList(),
      laboratoriosFrecuentes: (json['laboratorios_frecuentes'] as List? ?? [])
          .map((l) => LaboratorioFrecuenteModel.fromJson(l))
          .toList(),
      estadisticas: EstadisticasDocenteModel.fromJson(json['estadisticas']),
    );
  }
}

// Modelo para crear/actualizar docente
class DocenteFormModel {
  final String email;
  final String? password;
  final String nombre;
  final String telefono;
  final String codigo;
  final String estado;

  DocenteFormModel({
    required this.email,
    this.password,
    required this.nombre,
    required this.telefono,
    required this.codigo,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'codigo': codigo,
      'estado': estado,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password!;
    }

    return data;
  }
}
