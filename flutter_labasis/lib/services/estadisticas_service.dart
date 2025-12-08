// lib/services/estadisticas_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/estadisticas_model.dart';
import '../models/auxiliar_model.dart';

class EstadisticasService {
  // ==========================================
  // OBTENER DASHBOARD
  // ==========================================
  
  /// Obtiene el dashboard completo
  /// Si [auxiliarId] es null, retorna vista general
  /// Si [auxiliarId] tiene valor, retorna vista de ese auxiliar
  static Future<EstadisticasModel> getDashboard({
    required String token,
    int? auxiliarId,
  }) async {
    try {
      // Construir URL según si hay filtro de auxiliar o no
      String url = auxiliarId != null 
          ? ApiConfig.dashboardUrlConAuxiliar(auxiliarId)
          : ApiConfig.dashboardUrl;

      print('📊 Obteniendo dashboard: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          print('✅ Dashboard obtenido exitosamente');
          return EstadisticasModel.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Error al obtener dashboard');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado. Solo administradores pueden ver el panel.');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo dashboard: $e');
      rethrow;
    }
  }

  // ==========================================
  // OBTENER LISTA DE AUXILIARES
  // ==========================================
  
  /// Obtiene la lista de auxiliares para el dropdown
  static Future<List<AuxiliarModel>> getAuxiliares({
    required String token,
  }) async {
    try {
      print('👥 Obteniendo lista de auxiliares...');

      final response = await http.get(
        Uri.parse(ApiConfig.auxiliaresUrl),
        headers: ApiConfig.headersWithAuth(token),
      );

      print('👥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> auxiliaresJson = jsonData['data'];
          print('✅ ${auxiliaresJson.length} auxiliares obtenidos');
          
          return auxiliaresJson
              .map((json) => AuxiliarModel.fromJson(json))
              .toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Error al obtener auxiliares');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo auxiliares: $e');
      rethrow;
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================
  
  /// Formatea una fecha ISO a texto legible
  static String formatearFecha(String isoDate) {
    try {
      final fecha = DateTime.parse(isoDate);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      
      return '${fecha.day} ${meses[fecha.month - 1]}, ${fecha.year}';
    } catch (e) {
      return isoDate;
    }
  }

  /// Formatea una fecha ISO a hora legible
  static String formatearHora(String isoDate) {
    try {
      final fecha = DateTime.parse(isoDate);
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      
      return '$hora:$minuto';
    } catch (e) {
      return '';
    }
  }

  /// Calcula el porcentaje de un valor sobre un total
  static int calcularPorcentaje(int valor, int total) {
    if (total == 0) return 0;
    return ((valor / total) * 100).round();
  }

  /// Obtiene el color según el estado de una tarea
  static String getColorPorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return '#FFC107'; // Amarillo
      case 'en_proceso':
        return '#2196F3'; // Azul
      case 'completada':
        return '#4CAF50'; // Verde
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Obtiene el color según la urgencia
  static String getColorPorUrgencia(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'alta':
        return '#F44336'; // Rojo
      case 'media':
        return '#FFC107'; // Amarillo
      case 'baja':
        return '#4CAF50'; // Verde
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Obtiene el color según la categoría de objeto
  static String getColorPorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'electronica':
        return '#FF9800'; // Naranja
      case 'ropa':
        return '#9C27B0'; // Púrpura
      case 'documentos':
        return '#F44336'; // Rojo
      case 'otros':
        return '#607D8B'; // Gris
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Formatea un número grande (ejemplo: 1000 -> 1K)
  static String formatearNumero(int numero) {
    if (numero >= 1000000) {
      return '${(numero / 1000000).toStringAsFixed(1)}M';
    } else if (numero >= 1000) {
      return '${(numero / 1000).toStringAsFixed(1)}K';
    } else {
      return numero.toString();
    }
  }

  /// Obtiene el emoji según la posición en el ranking
  static String getMedallaEmoji(int posicion) {
    switch (posicion) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  /// Verifica si una diferencia es positiva (verde) o negativa (roja)
  static bool esDiferenciaPositiva(int diferencia) {
    return diferencia > 0;
  }

  /// Formatea la diferencia porcentual con símbolo
  static String formatearDiferencia(int diferencia) {
    if (diferencia > 0) {
      return '+$diferencia%';
    } else if (diferencia < 0) {
      return '$diferencia%';
    } else {
      return '0%';
    }
  }
}