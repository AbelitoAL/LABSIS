// lib/models/reserva_model.dart

class ReservaModel {
  final int id;
  final int docenteId;
  final int laboratorioId;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String materia;
  final String? descripcion;
  final String estado; // 'pendiente', 'aprobada', 'rechazada', 'cancelada'
  final String? motivoRechazo;
  final int? aprobadaPor;
  final String? aprobadaEn;
  final String createdAt;
  final String updatedAt;
  
  // Datos adicionales del JOIN
  final String? docenteNombre;
  final String? docenteEmail;
  final String? docenteCodigo;
  final String? docenteTelefono;
  final String? laboratorioNombre;
  final String? laboratorioCodigo;
  final String? laboratorioUbicacion;
  final int? laboratorioCapacidad;
  final String? aprobadaPorNombre;

  ReservaModel({
    required this.id,
    required this.docenteId,
    required this.laboratorioId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.materia,
    this.descripcion,
    required this.estado,
    this.motivoRechazo,
    this.aprobadaPor,
    this.aprobadaEn,
    required this.createdAt,
    required this.updatedAt,
    this.docenteNombre,
    this.docenteEmail,
    this.docenteCodigo,
    this.docenteTelefono,
    this.laboratorioNombre,
    this.laboratorioCodigo,
    this.laboratorioUbicacion,
    this.laboratorioCapacidad,
    this.aprobadaPorNombre,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] as int,
      docenteId: json['docente_id'] as int,
      laboratorioId: json['laboratorio_id'] as int,
      fecha: json['fecha'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      materia: json['materia'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String,
      motivoRechazo: json['motivo_rechazo'] as String?,
      aprobadaPor: json['aprobada_por'] as int?,
      aprobadaEn: json['aprobada_en'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      docenteNombre: json['docente_nombre'] as String?,
      docenteEmail: json['docente_email'] as String?,
      docenteCodigo: json['docente_codigo'] as String?,
      docenteTelefono: json['docente_telefono'] as String?,
      laboratorioNombre: json['laboratorio_nombre'] as String?,
      laboratorioCodigo: json['laboratorio_codigo'] as String?,
      laboratorioUbicacion: json['laboratorio_ubicacion'] as String?,
      laboratorioCapacidad: json['laboratorio_capacidad'] as int?,
      aprobadaPorNombre: json['aprobada_por_nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docente_id': docenteId,
      'laboratorio_id': laboratorioId,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'materia': materia,
      'descripcion': descripcion,
      'estado': estado,
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

  // Formatear duración
  String get duracionFormateada {
    final horas = duracionHoras.floor();
    final minutos = ((duracionHoras - horas) * 60).round();
    
    if (horas > 0 && minutos > 0) {
      return '${horas}h ${minutos}min';
    } else if (horas > 0) {
      return '${horas}h';
    } else {
      return '${minutos}min';
    }
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

  // Texto del estado
  String get textoEstado {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  // Verificar si puede ser cancelada
  bool get puedeCancelar {
    return estado == 'pendiente';
  }

  // Verificar si puede ser aprobada/rechazada
  bool get puedeAprobarRechazar {
    return estado == 'pendiente';
  }

  // Formatear fecha para mostrar
  String get fechaFormateada {
    try {
      final date = DateTime.parse(fecha);
      final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      
      return '${dias[date.weekday - 1]}, ${date.day} ${meses[date.month - 1]}';
    } catch (e) {
      return fecha;
    }
  }

  // Formatear horario
  String get horarioFormateado {
    return '$horaInicio - $horaFin';
  }
}

// Modelo para crear/editar reserva
class ReservaFormModel {
  final int laboratorioId;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String materia;
  final String? descripcion;

  ReservaFormModel({
    required this.laboratorioId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.materia,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'laboratorio_id': laboratorioId,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'materia': materia,
      if (descripcion != null && descripcion!.isNotEmpty)
        'descripcion': descripcion,
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
