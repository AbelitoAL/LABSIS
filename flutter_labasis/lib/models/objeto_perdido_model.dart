// lib/models/objeto_perdido_model.dart

class ObjetoPerdidoModel {
  final int id;
  final String? fotoObjeto;
  final String descripcion;
  final String categoria; // 'electronica', 'ropa', 'documentos', 'accesorios', 'llaves', 'otros'
  final int laboratorioId;
  final int auxiliarEncontroId;
  final String fechaEncontrado;
  final String estado; // 'encontrado', 'entregado'
  final Map<String, dynamic>? entrega;
  final String? createdAt;
  final String? updatedAt;

  ObjetoPerdidoModel({
    required this.id,
    this.fotoObjeto,
    required this.descripcion,
    required this.categoria,
    required this.laboratorioId,
    required this.auxiliarEncontroId,
    required this.fechaEncontrado,
    required this.estado,
    this.entrega,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON
  factory ObjetoPerdidoModel.fromJson(Map<String, dynamic> json) {
    return ObjetoPerdidoModel(
      id: json['id'] as int,
      fotoObjeto: json['foto_objeto'] as String?,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String? ?? 'otros',
      laboratorioId: json['laboratorio_id'] as int,
      auxiliarEncontroId: json['auxiliar_encontro_id'] as int,
      fechaEncontrado: json['fecha_encontrado'] as String,
      estado: json['estado'] as String? ?? 'encontrado',
      entrega: json['entrega'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto_objeto': fotoObjeto,
      'descripcion': descripcion,
      'categoria': categoria,
      'laboratorio_id': laboratorioId,
      'auxiliar_encontro_id': auxiliarEncontroId,
      'fecha_encontrado': fechaEncontrado,
      'estado': estado,
      'entrega': entrega,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Obtener color según estado
  String get estadoColor {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return '#4CAF50'; // Verde
      case 'encontrado':
        return '#FF9800'; // Naranja
      default:
        return '#9E9E9E'; // Gris
    }
  }

  // Obtener texto del estado
  String get estadoTexto {
    return estado.toUpperCase();
  }

  // Obtener texto de la categoría
  String get categoriaTexto {
    switch (categoria.toLowerCase()) {
      case 'electronica':
        return 'ELECTRÓNICA';
      case 'ropa':
        return 'ROPA';
      case 'documentos':
        return 'DOCUMENTOS';
      case 'accesorios':
        return 'ACCESORIOS';
      case 'llaves':
        return 'LLAVES';
      case 'otros':
        return 'OTROS';
      default:
        return categoria.toUpperCase();
    }
  }

  // Obtener emoji de la categoría
  String get categoriaEmoji {
    switch (categoria.toLowerCase()) {
      case 'electronica':
        return '📱';
      case 'ropa':
        return '👕';
      case 'documentos':
        return '📄';
      case 'accesorios':
        return '🎒';
      case 'llaves':
        return '🔑';
      case 'otros':
        return '📦';
      default:
        return '📦';
    }
  }
}
