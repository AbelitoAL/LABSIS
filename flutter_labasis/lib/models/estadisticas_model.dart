// lib/models/estadisticas_model.dart

class EstadisticasModel {
  final String tipo; // 'general' o 'auxiliar'
  final DateTime ultimaActualizacion;
  final ResumenModel resumen;
  final GraficasModel graficas;
  final RankingsModel? rankings; // Solo en vista general
  final List<LaboratorioActividadModel> laboratorios;
  final List<TareaUrgenteModel> tareasUrgentes;
  final AuxiliarInfoModel? auxiliarInfo; // Solo en vista de auxiliar
  final List<TareaPendienteModel>? tareasPendientes; // Solo en vista de auxiliar
  final RankingAuxiliarModel? ranking; // Solo en vista de auxiliar

  EstadisticasModel({
    required this.tipo,
    required this.ultimaActualizacion,
    required this.resumen,
    required this.graficas,
    this.rankings,
    required this.laboratorios,
    required this.tareasUrgentes,
    this.auxiliarInfo,
    this.tareasPendientes,
    this.ranking,
  });

  bool get esVistaGeneral => tipo == 'general';
  bool get esVistaAuxiliar => tipo == 'auxiliar';

  factory EstadisticasModel.fromJson(Map<String, dynamic> json) {
    return EstadisticasModel(
      tipo: json['tipo'] as String,
      ultimaActualizacion: DateTime.parse(json['ultima_actualizacion'] as String),
      resumen: ResumenModel.fromJson(json['resumen'] as Map<String, dynamic>),
      graficas: GraficasModel.fromJson(json['graficas'] as Map<String, dynamic>),
      rankings: json['rankings'] != null
          ? RankingsModel.fromJson(json['rankings'] as Map<String, dynamic>)
          : null,
      laboratorios: (json['laboratorios'] as List<dynamic>)
          .map((item) => LaboratorioActividadModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      tareasUrgentes: json['tareas_urgentes'] != null
          ? (json['tareas_urgentes'] as List<dynamic>)
              .map((item) => TareaUrgenteModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      auxiliarInfo: json['auxiliar'] != null
          ? AuxiliarInfoModel.fromJson(json['auxiliar'] as Map<String, dynamic>)
          : null,
      tareasPendientes: json['tareas_pendientes'] != null
          ? (json['tareas_pendientes'] as List<dynamic>)
              .map((item) => TareaPendienteModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      ranking: json['ranking'] != null
          ? RankingAuxiliarModel.fromJson(json['ranking'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ==========================================
// RESUMEN
// ==========================================

class ResumenModel {
  final ResumenItemModel tareas;
  final ResumenItemModel bitacoras;
  final ResumenItemModel objetos;
  final ResumenUsuariosModel? usuarios; // Solo en vista general

  ResumenModel({
    required this.tareas,
    required this.bitacoras,
    required this.objetos,
    this.usuarios,
  });

  factory ResumenModel.fromJson(Map<String, dynamic> json) {
    return ResumenModel(
      tareas: ResumenItemModel.fromJson(json['tareas'] as Map<String, dynamic>),
      bitacoras: ResumenItemModel.fromJson(json['bitacoras'] as Map<String, dynamic>),
      objetos: ResumenItemModel.fromJson(json['objetos'] as Map<String, dynamic>),
      usuarios: json['usuarios'] != null
          ? ResumenUsuariosModel.fromJson(json['usuarios'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ResumenItemModel {
  final int total;
  final int? pendientes;
  final int? enProceso;
  final int? completadas;
  final int? borradores;
  final int? enCustodia;
  final int? entregados;

  ResumenItemModel({
    required this.total,
    this.pendientes,
    this.enProceso,
    this.completadas,
    this.borradores,
    this.enCustodia,
    this.entregados,
  });

  factory ResumenItemModel.fromJson(Map<String, dynamic> json) {
    return ResumenItemModel(
      total: json['total'] as int,
      pendientes: json['pendientes'] as int?,
      enProceso: json['en_proceso'] as int?,
      completadas: json['completadas'] as int?,
      borradores: json['borradores'] as int?,
      enCustodia: json['en_custodia'] as int?,
      entregados: json['entregados'] as int?,
    );
  }
}

class ResumenUsuariosModel {
  final int total;
  final int activos;
  final int inactivos;

  ResumenUsuariosModel({
    required this.total,
    required this.activos,
    required this.inactivos,
  });

  factory ResumenUsuariosModel.fromJson(Map<String, dynamic> json) {
    return ResumenUsuariosModel(
      total: json['total'] as int,
      activos: json['activos'] as int,
      inactivos: json['inactivos'] as int,
    );
  }
}

// ==========================================
// GRÁFICAS
// ==========================================

class GraficasModel {
  final List<GraficaItemModel> tareasPorEstado;
  final List<GraficaMesModel> bitacorasPorMes;
  final List<GraficaItemModel>? objetosPorCategoria; // Solo en vista general

  GraficasModel({
    required this.tareasPorEstado,
    required this.bitacorasPorMes,
    this.objetosPorCategoria,
  });

  factory GraficasModel.fromJson(Map<String, dynamic> json) {
    return GraficasModel(
      tareasPorEstado: (json['tareas_por_estado'] as List<dynamic>)
          .map((item) => GraficaItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      bitacorasPorMes: (json['bitacoras_por_mes'] as List<dynamic>)
          .map((item) => GraficaMesModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      objetosPorCategoria: json['objetos_por_categoria'] != null
          ? (json['objetos_por_categoria'] as List<dynamic>)
              .map((item) => GraficaItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class GraficaItemModel {
  final String nombre; // estado o categoria
  final int cantidad;
  final int porcentaje;

  GraficaItemModel({
    required this.nombre,
    required this.cantidad,
    required this.porcentaje,
  });

  factory GraficaItemModel.fromJson(Map<String, dynamic> json) {
    return GraficaItemModel(
      nombre: (json['estado'] ?? json['categoria']) as String,
      cantidad: json['cantidad'] as int,
      porcentaje: json['porcentaje'] as int,
    );
  }
}

class GraficaMesModel {
  final String mes;
  final int cantidad;
  final String fecha;

  GraficaMesModel({
    required this.mes,
    required this.cantidad,
    required this.fecha,
  });

  factory GraficaMesModel.fromJson(Map<String, dynamic> json) {
    return GraficaMesModel(
      mes: json['mes'] as String,
      cantidad: json['cantidad'] as int,
      fecha: json['fecha'] as String,
    );
  }
}

// ==========================================
// RANKINGS (Solo vista general)
// ==========================================

class RankingsModel {
  final List<TopAuxiliarModel> topAuxiliares;

  RankingsModel({
    required this.topAuxiliares,
  });

  factory RankingsModel.fromJson(Map<String, dynamic> json) {
    return RankingsModel(
      topAuxiliares: (json['top_auxiliares'] as List<dynamic>)
          .map((item) => TopAuxiliarModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopAuxiliarModel {
  final int posicion;
  final int id;
  final String nombre;
  final String email;
  final int tareas;
  final int bitacoras;
  final int objetos;
  final int total;

  TopAuxiliarModel({
    required this.posicion,
    required this.id,
    required this.nombre,
    required this.email,
    required this.tareas,
    required this.bitacoras,
    required this.objetos,
    required this.total,
  });

  factory TopAuxiliarModel.fromJson(Map<String, dynamic> json) {
    return TopAuxiliarModel(
      posicion: json['posicion'] as int,
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      tareas: json['tareas'] as int,
      bitacoras: json['bitacoras'] as int,
      objetos: json['objetos'] as int,
      total: json['total'] as int,
    );
  }

  String get medallaEmoji {
    switch (posicion) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '${posicion}.';
    }
  }
}

// ==========================================
// LABORATORIOS
// ==========================================

class LaboratorioActividadModel {
  final int id;
  final String nombre;
  final String? ubicacion;
  final int tareas;
  final int bitacoras;
  final int objetos;
  final int actividadTotal;
  final int porcentaje;
  final int? actividades; // Para vista de auxiliar

  LaboratorioActividadModel({
    required this.id,
    required this.nombre,
    this.ubicacion,
    required this.tareas,
    required this.bitacoras,
    required this.objetos,
    required this.actividadTotal,
    required this.porcentaje,
    this.actividades,
  });

  factory LaboratorioActividadModel.fromJson(Map<String, dynamic> json) {
    return LaboratorioActividadModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      ubicacion: json['ubicacion'] as String?,
      tareas: json['tareas'] as int? ?? 0,
      bitacoras: json['bitacoras'] as int? ?? 0,
      objetos: json['objetos'] as int? ?? 0,
      actividadTotal: json['actividad_total'] as int? ?? json['actividades'] as int? ?? 0,
      porcentaje: json['porcentaje'] as int? ?? 100,
      actividades: json['actividades'] as int?,
    );
  }
}

// ==========================================
// TAREAS URGENTES
// ==========================================

class TareaUrgenteModel {
  final int id;
  final String titulo;
  final String? descripcion;
  final String prioridad;
  final String fechaLimite;
  final int diasRestantes;
  final String? auxiliar;
  final String? laboratorio;
  final String urgencia;

  TareaUrgenteModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.prioridad,
    required this.fechaLimite,
    required this.diasRestantes,
    this.auxiliar,
    this.laboratorio,
    required this.urgencia,
  });

  factory TareaUrgenteModel.fromJson(Map<String, dynamic> json) {
    return TareaUrgenteModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      prioridad: json['prioridad'] as String,
      fechaLimite: json['fecha_limite'] as String,
      diasRestantes: json['dias_restantes'] as int,
      auxiliar: json['auxiliar'] as String?,
      laboratorio: json['laboratorio'] as String?,
      urgencia: json['urgencia'] as String,
    );
  }

  String get urgenciaTexto {
    switch (urgencia) {
      case 'alta':
        return diasRestantes == 0 ? 'Vence hoy' : 'Vence mañana';
      case 'media':
        return 'Vence en $diasRestantes días';
      default:
        return 'Vence en $diasRestantes días';
    }
  }
}

// ==========================================
// VISTA DE AUXILIAR ESPECÍFICO
// ==========================================

class AuxiliarInfoModel {
  final int id;
  final String nombre;
  final String email;
  final String activoDesde;

  AuxiliarInfoModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.activoDesde,
  });

  factory AuxiliarInfoModel.fromJson(Map<String, dynamic> json) {
    return AuxiliarInfoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      activoDesde: json['activo_desde'] as String,
    );
  }
}

class TareaPendienteModel {
  final int id;
  final String titulo;
  final String prioridad;
  final String fechaLimite;
  final int diasRestantes;
  final String? laboratorio;
  final String urgencia;

  TareaPendienteModel({
    required this.id,
    required this.titulo,
    required this.prioridad,
    required this.fechaLimite,
    required this.diasRestantes,
    this.laboratorio,
    required this.urgencia,
  });

  factory TareaPendienteModel.fromJson(Map<String, dynamic> json) {
    return TareaPendienteModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      prioridad: json['prioridad'] as String,
      fechaLimite: json['fecha_limite'] as String,
      diasRestantes: json['dias_restantes'] as int,
      laboratorio: json['laboratorio'] as String?,
      urgencia: json['urgencia'] as String,
    );
  }
}

class RankingAuxiliarModel {
  final int posicion;
  final int total;
  final ComparacionModel? comparacion;

  RankingAuxiliarModel({
    required this.posicion,
    required this.total,
    this.comparacion,
  });

  factory RankingAuxiliarModel.fromJson(Map<String, dynamic> json) {
    return RankingAuxiliarModel(
      posicion: json['posicion'] as int,
      total: json['total'] as int,
      comparacion: json['comparacion'] != null
          ? ComparacionModel.fromJson(json['comparacion'] as Map<String, dynamic>)
          : null,
    );
  }

  String get posicionTexto {
    if (posicion == 0) return 'Sin datos';
    if (posicion == 1) return '🥇 #1 de $total';
    if (posicion == 2) return '🥈 #2 de $total';
    if (posicion == 3) return '🥉 #3 de $total';
    return '#$posicion de $total';
  }
}

class ComparacionModel {
  final ComparacionItemModel tareas;
  final ComparacionItemModel bitacoras;
  final ComparacionItemModel objetos;

  ComparacionModel({
    required this.tareas,
    required this.bitacoras,
    required this.objetos,
  });

  factory ComparacionModel.fromJson(Map<String, dynamic> json) {
    return ComparacionModel(
      tareas: ComparacionItemModel.fromJson(json['tareas'] as Map<String, dynamic>),
      bitacoras: ComparacionItemModel.fromJson(json['bitacoras'] as Map<String, dynamic>),
      objetos: ComparacionItemModel.fromJson(json['objetos'] as Map<String, dynamic>),
    );
  }
}

class ComparacionItemModel {
  final int cantidad;
  final int promedio;
  final int diferencia; // Porcentaje de diferencia con el promedio

  ComparacionItemModel({
    required this.cantidad,
    required this.promedio,
    required this.diferencia,
  });

  factory ComparacionItemModel.fromJson(Map<String, dynamic> json) {
    return ComparacionItemModel(
      cantidad: json['cantidad'] as int,
      promedio: json['promedio'] as int,
      diferencia: json['diferencia'] as int,
    );
  }

  bool get estaSobreElPromedio => diferencia > 0;
  String get diferenciaTexto => '${diferencia > 0 ? '+' : ''}$diferencia%';
}