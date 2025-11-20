// lib/models/tarea_model.dart

class TareaModel {
  final int id;
  final String titulo;
  final String? descripcion;
  final int? laboratorioId;
  final int auxiliarId;
  final String prioridad; // 'baja', 'media', 'alta'
  final String estado; // 'pendiente', 'en_proceso', 'completada'
  final String? fechaLimite;
  final String? fechaCompletada;
  final int creadoPor;
  final List<dynamic> evidencias;
  final List<dynamic> tags;
  final String? createdAt;
  final String? updatedAt;

  TareaModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.laboratorioId,
    required this.auxiliarId,
    required this.prioridad,
    required this.estado,
    this.fechaLimite,
    this.fechaCompletada,
    required this.creadoPor,
    required this.evidencias,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON
  factory TareaModel.fromJson(Map<String, dynamic> json) {
    return TareaModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      laboratorioId: json['laboratorio_id'] as int?,
      auxiliarId: json['auxiliar_id'] as int,
      prioridad: json['prioridad'] as String? ?? 'media',
      estado: json['estado'] as String? ?? 'pendiente',
      fechaLimite: json['fecha_limite'] as String?,
      fechaCompletada: json['fecha_completada'] as String?,
      creadoPor: json['creado_por'] as int,
      evidencias: json['evidencias'] ?? [],
      tags: json['tags'] ?? [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'laboratorio_id': laboratorioId,
      'auxiliar_id': auxiliarId,
      'prioridad': prioridad,
      'estado': estado,
      'fecha_limite': fechaLimite,
      'fecha_completada': fechaCompletada,
      'creado_por': creadoPor,
      'evidencias': evidencias,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Obtener color según prioridad
  String get prioridadColor {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return '#F44336'; // Rojo
      case 'media':
        return '#FF9800'; // Naranja
      case 'baja':
        return '#4CAF50'; // Verde
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Obtener texto de prioridad
  String get prioridadTexto {
    return prioridad.toUpperCase();
  }

  // Obtener color según estado
  String get estadoColor {
    switch (estado.toLowerCase()) {
      case 'completada':
        return '#4CAF50'; // Verde
      case 'en_proceso':
        return '#2196F3'; // Azul
      case 'pendiente':
        return '#FFC107'; // Amarillo
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Obtener texto del estado
  String get estadoTexto {
    return estado.replaceAll('_', ' ').toUpperCase();
  }

  // Verificar si está vencida
  bool get isVencida {
    if (fechaLimite == null || estado == 'completada') return false;
    final limite = DateTime.parse(fechaLimite!);
    return limite.isBefore(DateTime.now());
  }
}
