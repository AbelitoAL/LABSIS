// lib/models/laboratorio_model.dart

class LaboratorioModel {
  final int id;
  final String nombre;
  final String codigo;
  final String? ubicacion;
  final int? capacidad;
  final String estado; // 'activo', 'mantenimiento', 'inactivo'
  final List<dynamic> equipamiento;
  final List<dynamic> manuales;
  final Map<String, dynamic> contraseñas;
  final Map<String, dynamic> horarios;
  final List<int> auxiliaresAsignados;
  final List<dynamic> imagenes;
  final int? modificadoPor;
  final String? createdAt;
  final String? updatedAt;

  LaboratorioModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.ubicacion,
    this.capacidad,
    required this.estado,
    required this.equipamiento,
    required this.manuales,
    required this.contraseñas,
    required this.horarios,
    required this.auxiliaresAsignados,
    required this.imagenes,
    this.modificadoPor,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON
  factory LaboratorioModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      ubicacion: json['ubicacion'] as String?,
      capacidad: json['capacidad'] as int?,
      estado: json['estado'] as String? ?? 'activo',
      equipamiento: json['equipamiento'] ?? [],
      manuales: json['manuales'] ?? [],
      contraseñas: json['contraseñas'] ?? {},
      horarios: json['horarios'] ?? {},
      auxiliaresAsignados: json['auxiliares_asignados'] != null
          ? List<int>.from(json['auxiliares_asignados'])
          : [],
      imagenes: json['imagenes'] ?? [],
      modificadoPor: json['modificado_por'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'ubicacion': ubicacion,
      'capacidad': capacidad,
      'estado': estado,
      'equipamiento': equipamiento,
      'manuales': manuales,
      'contraseñas': contraseñas,
      'horarios': horarios,
      'auxiliares_asignados': auxiliaresAsignados,
      'imagenes': imagenes,
      'modificado_por': modificadoPor,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Obtener color según estado
  String get estadoColor {
    switch (estado.toLowerCase()) {
      case 'activo':
        return '#4CAF50'; // Verde
      case 'mantenimiento':
        return '#FF9800'; // Naranja
      case 'inactivo':
        return '#F44336'; // Rojo
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Obtener texto del estado
  String get estadoTexto {
    return estado.toUpperCase();
  }
}