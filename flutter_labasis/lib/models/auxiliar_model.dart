// lib/models/auxiliar_model.dart

class AuxiliarModel {
  final int id;
  final String nombre;
  final String email;

  AuxiliarModel({
    required this.id,
    required this.nombre,
    required this.email,
  });

  factory AuxiliarModel.fromJson(Map<String, dynamic> json) {
    return AuxiliarModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
    };
  }

  @override
  String toString() => nombre;
}