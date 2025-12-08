// lib/config/api_config.dart

class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'http://10.0.2.2:3000';
  
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
  static const String dashboardEndpoint = '/api/stats/dashboard';
  static const String statsAuxiliaresEndpoint = '/api/stats/auxiliares'; // ← Renombrado para claridad
  
  // Endpoints de manuales
  static const String manualesEndpoint = '/api/manuales';
  
  // Endpoints de auxiliares (gestión) ← NUEVO
  static const String auxiliaresEndpoint = '/api/auxiliares';
  
  // Endpoint de upload
  static const String uploadEndpoint = '/api/upload';
  
  // Endpoint de asistente
  static const String asistenteEndpoint = '/api/asistente';
  
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
  
  // ==========================================
  // MÉTODOS ESPECÍFICOS PARA ESTADÍSTICAS
  // ==========================================
  
  // URL completa para el dashboard
  static String get dashboardUrl => buildUrl(dashboardEndpoint);
  
  // URL completa para obtener estadísticas de auxiliares
  static String get statsAuxiliaresUrl => buildUrl(statsAuxiliaresEndpoint);
  
  // URL del dashboard con filtro de auxiliar
  static String dashboardUrlConAuxiliar(int auxiliarId) {
    return '${buildUrl(dashboardEndpoint)}?auxiliar_id=$auxiliarId';
  }
}
















