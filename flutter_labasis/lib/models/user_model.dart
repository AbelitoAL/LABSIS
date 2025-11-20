// lib/models/user_model.dart

class UserModel {
  final int id;
  final String email;
  final String nombre;
  final String rol; // 'admin' o 'auxiliar'
  final bool activo;
  final List<int> laboratoriosAsignados;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.activo,
    required this.laboratoriosAsignados,
    this.createdAt,
  });

  // Crear desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] == 1 || json['activo'] == true,
      laboratoriosAsignados: json['laboratorios_asignados'] != null
          ? List<int>.from(json['laboratorios_asignados'])
          : [],
      createdAt: json['created_at'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'activo': activo,
      'laboratorios_asignados': laboratoriosAsignados,
      'created_at': createdAt,
    };
  }

  // Verificar si es admin
  bool get isAdmin => rol == 'admin';

  // Verificar si es auxiliar
  bool get isAuxiliar => rol == 'auxiliar';

  // Copiar con cambios
  UserModel copyWith({
    int? id,
    String? email,
    String? nombre,
    String? rol,
    bool? activo,
    List<int>? laboratoriosAsignados,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      laboratoriosAsignados: laboratoriosAsignados ?? this.laboratoriosAsignados,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
