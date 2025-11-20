// lib/services/asistente_service.dart

import '../config/api_config.dart';
import '../models/mensaje_chat_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AsistenteService {
  // Enviar mensaje al asistente
  static Future<Map<String, dynamic>> enviarMensaje({
    required String mensaje,
    List<Map<String, String>>? historial,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      if (mensaje.trim().isEmpty) {
        throw Exception('El mensaje no puede estar vacío');
      }

      final data = {
        'mensaje': mensaje.trim(),
        if (historial != null && historial.isNotEmpty) 'historial': historial,
      };

      final response = await ApiService.post(
        '${ApiConfig.asistenteEndpoint}/chat',
        data,
        token: token,
      );

      if (response['success'] == true) {
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Error enviando mensaje');
    } catch (e) {
      throw Exception('Error enviando mensaje: $e');
    }
  }

  // Obtener historial de conversación
  static Future<List<MensajeChatModel>> getHistorial({int limit = 50}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.asistenteEndpoint}/historial?limit=$limit',
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => MensajeChatModel.fromJson(json)).toList();
      }

      throw Exception(response['message'] ?? 'Error obteniendo historial');
    } catch (e) {
      throw Exception('Error obteniendo historial: $e');
    }
  }

  // Limpiar historial
  static Future<void> clearHistorial() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.delete(
        '${ApiConfig.asistenteEndpoint}/historial',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Error limpiando historial');
      }
    } catch (e) {
      throw Exception('Error limpiando historial: $e');
    }
  }

  // Obtener sugerencias inteligentes
  static Future<List<Map<String, dynamic>>> getSugerencias() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No hay sesión activa');

      final response = await ApiService.get(
        '${ApiConfig.asistenteEndpoint}/sugerencias',
        token: token,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      // No lanzar excepción, solo retornar lista vacía
      return [];
    }
  }

  // Mensajes de ejemplo/sugerencias rápidas
  static List<String> getMensajesSugeridos() {
    return [
      '¿Cuántas tareas tengo pendientes?',
      '¿Qué objetos perdidos hay?',
      'Resumen de mis bitácoras',
      '¿Cuántos laboratorios hay?',
      'Dame consejos para organizar mi trabajo',
    ];
  }
}