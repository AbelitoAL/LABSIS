// lib/models/mensaje_chat_model.dart

class MensajeChatModel {
  final String mensaje;
  final String respuesta;
  final String? createdAt;

  MensajeChatModel({
    required this.mensaje,
    required this.respuesta,
    this.createdAt,
  });

  factory MensajeChatModel.fromJson(Map<String, dynamic> json) {
    return MensajeChatModel(
      mensaje: json['mensaje'] as String,
      respuesta: json['respuesta'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'respuesta': respuesta,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  // Para pasar al historial del API
  Map<String, String> toHistorialFormat() {
    return {
      'mensaje': mensaje,
      'respuesta': respuesta,
    };
  }
}