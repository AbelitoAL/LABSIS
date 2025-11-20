// lib/models/bitacora_model.dart

class BitacoraModel {
  final int id;
  final String nombre;
  final int? plantillaId;
  final int laboratorioId;
  final String fecha;
  final String turno; // 'mañana', 'tarde', 'noche'
  final int auxiliarId;
  final String estado; // 'borrador', 'completada'
  final List<dynamic> atributos;
  final Map<String, dynamic> grilla;
  final Map<String, dynamic> resumen;
  final String? createdAt;
  final String? updatedAt;

  BitacoraModel({
    required this.id,
    required this.nombre,
    this.plantillaId,
    required this.laboratorioId,
    required this.fecha,
    required this.turno,
    required this.auxiliarId,
    required this.estado,
    required this.atributos,
    required this.grilla,
    required this.resumen,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON
  factory BitacoraModel.fromJson(Map<String, dynamic> json) {
    return BitacoraModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      plantillaId: json['plantilla_id'] as int?,
      laboratorioId: json['laboratorio_id'] as int,
      fecha: json['fecha'] as String,
      turno: json['turno'] as String? ?? 'mañana',
      auxiliarId: json['auxiliar_id'] as int,
      estado: json['estado'] as String? ?? 'borrador',
      atributos: json['atributos'] ?? [],
      grilla: json['grilla'] ?? {},
      resumen: json['resumen'] ?? {},
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'plantilla_id': plantillaId,
      'laboratorio_id': laboratorioId,
      'fecha': fecha,
      'turno': turno,
      'auxiliar_id': auxiliarId,
      'estado': estado,
      'atributos': atributos,
      'grilla': grilla,
      'resumen': resumen,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Obtener color según estado
  String get estadoColor {
    switch (estado.toLowerCase()) {
      case 'completada':
        return '#4CAF50'; // Verde
      case 'borrador':
        return '#FFC107'; // Amarillo
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Obtener texto del estado
  String get estadoTexto {
    return estado.toUpperCase();
  }

  // Obtener texto del turno
  String get turnoTexto {
    switch (turno.toLowerCase()) {
      case 'mañana':
        return 'MAÑANA';
      case 'tarde':
        return 'TARDE';
      case 'noche':
        return 'NOCHE';
      default:
        return turno.toUpperCase();
    }
  }
}