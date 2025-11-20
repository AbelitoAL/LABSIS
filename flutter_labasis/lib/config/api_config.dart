// lib/config/api_config.dart

class ApiConfig {
  // ✅ CORRECCIÓN: Remover /api del baseUrl
  // Como estás en emulador Android, usa 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Endpoints de autenticación (SIN /api/ porque ya está en baseUrl)
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register-public';
  static const String meEndpoint = '/auth/me';
  
  // Endpoints de usuarios
  static const String usersEndpoint = '/users';
  
  // Endpoints de laboratorios
  static const String laboratoriosEndpoint = '/laboratorios';
  
  // Endpoints de tareas
  static const String tareasEndpoint = '/tareas';
  static const String misTareasEndpoint = '/tareas/mis-tareas';
  
  // Endpoints de bitácoras
  static const String bitacorasEndpoint = '/bitacoras';
  
  // Endpoints de objetos perdidos
  static const String objetosPerdidosEndpoint = '/objetos-perdidos';
  
  // Endpoints de iconos y plantillas
  static const String iconosEndpoint = '/iconos';
  static const String plantillasEndpoint = '/plantillas';
  
  // Endpoints de estadísticas
  static const String statsEndpoint = '/stats';
  
  // Endpoint de upload
  static const String uploadEndpoint = '/upload';
  
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