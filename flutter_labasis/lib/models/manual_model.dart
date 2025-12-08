// lib/models/manual_model.dart

class ManualModel {
  final int id;
  final int laboratorioId;
  final List<ManualItemModel> items;
  final int? createdBy;
  final int? updatedBy;
  final String createdAt;
  final String updatedAt;
  final String? creadoPorNombre;
  final String? actualizadoPorNombre;

  ManualModel({
    required this.id,
    required this.laboratorioId,
    required this.items,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.creadoPorNombre,
    this.actualizadoPorNombre,
  });

  factory ManualModel.fromJson(Map<String, dynamic> json) {
    List<ManualItemModel> itemsList = [];
    
    if (json['items'] != null) {
      if (json['items'] is List) {
        itemsList = (json['items'] as List)
            .map((item) => ManualItemModel.fromJson(item))
            .toList();
      }
    }

    return ManualModel(
      id: json['id'] as int,
      laboratorioId: json['laboratorio_id'] as int,
      items: itemsList,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      creadoPorNombre: json['creado_por_nombre'] as String?,
      actualizadoPorNombre: json['actualizado_por_nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laboratorio_id': laboratorioId,
      'items': items.map((item) => item.toJson()).toList(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Modelo para cada item del manual
class ManualItemModel {
  final String titulo;
  final String descripcion;

  ManualItemModel({
    required this.titulo,
    required this.descripcion,
  });

  factory ManualItemModel.fromJson(Map<String, dynamic> json) {
    return ManualItemModel(
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
    };
  }

  // Copiar con modificaciones
  ManualItemModel copyWith({
    String? titulo,
    String? descripcion,
  }) {
    return ManualItemModel(
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

// Modelo para laboratorio con información de manual
class LaboratorioConManualModel {
  final int id;
  final String nombre;
  final String codigo;
  final String? ubicacion;
  final String estado;
  final bool tieneManual;
  final int? manualId;
  final int cantidadItems;
  final String? manualActualizado;

  LaboratorioConManualModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.ubicacion,
    required this.estado,
    required this.tieneManual,
    this.manualId,
    required this.cantidadItems,
    this.manualActualizado,
  });

  factory LaboratorioConManualModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioConManualModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      ubicacion: json['ubicacion'] as String?,
      estado: json['estado'] as String,
      tieneManual: (json['tiene_manual'] as int) == 1,
      manualId: json['manual_id'] as int?,
      cantidadItems: json['cantidad_items'] as int? ?? 0,
      manualActualizado: json['manual_actualizado'] as String?,
    );
  }

  // Obtener emoji según el nombre del laboratorio
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

// Modelo completo para la respuesta del detalle
class ManualDetalleModel {
  final LaboratorioInfoModel laboratorio;
  final ManualModel? manual;
  final List<ManualItemModel> items;

  ManualDetalleModel({
    required this.laboratorio,
    this.manual,
    required this.items,
  });

  factory ManualDetalleModel.fromJson(Map<String, dynamic> json) {
    return ManualDetalleModel(
      laboratorio: LaboratorioInfoModel.fromJson(json['laboratorio']),
      manual: json['manual'] != null 
          ? ManualModel.fromJson(json['manual'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => ManualItemModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

// Modelo simple de laboratorio para el detalle
class LaboratorioInfoModel {
  final int id;
  final String nombre;
  final String codigo;
  final String? ubicacion;

  LaboratorioInfoModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.ubicacion,
  });

  factory LaboratorioInfoModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioInfoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      ubicacion: json['ubicacion'] as String?,
    );
  }

  // Obtener emoji según el nombre del laboratorio
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