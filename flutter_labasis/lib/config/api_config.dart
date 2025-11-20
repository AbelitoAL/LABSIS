// lib/config/api_config.dart

class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'http://localhost:3000';
  
  // Endpoints de autenticación
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register-public';
  static const String meEndpoint = '/api/auth/me';
  
  // Endpoints de usuarios
  static const String usersEndpoint = '/api/users';
  
  // Endpoints de laboratorios
  static const String laboratoriosEndpoint = '/api/laboratorios';
  
  // Endpoints de tareas
  static const String tareasEndpoint = '/api/tareas';
  static const String misTareasEndpoint = '/api/tareas/mis-tareas';
  
  // Endpoints de bitácoras
  static const String bitacorasEndpoint = '/api/bitacoras';
  
  // Endpoints de objetos perdidos
  static const String objetosPerdidosEndpoint = '/api/objetos-perdidos';
  
  // Endpoints de iconos y plantillas
  static const String iconosEndpoint = '/api/iconos';
  static const String plantillasEndpoint = '/api/plantillas';
  
  // Endpoints de estadísticas
  static const String statsEndpoint = '/api/stats';
  
  // Endpoint de upload
  static const String uploadEndpoint = '/api/upload';
  
  // Headers comunes
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  // Headers con autenticación
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Construir URL completa
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
