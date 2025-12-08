// lib/screens/estadisticas/widgets/bar_chart_widget.dart

import 'package:flutter/material.dart';
import '../../../models/estadisticas_model.dart';

class BarChartWidget extends StatelessWidget {
  final List<GraficaItemModel> data;
  final String tipo; // 'categoria' o 'laboratorio'

  const BarChartWidget({
    Key? key,
    required this.data,
    required this.tipo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay datos disponibles',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: data.map((item) {
        final color = _getColorForItem(item.nombre);
        final maxCantidad = data.map((e) => e.cantidad).reduce((a, b) => a > b ? a : b);
        final porcentajeVisual = maxCantidad > 0 ? (item.cantidad / maxCantidad) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre y cantidad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatNombre(item.nombre),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.cantidad}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Barra de progreso
              Stack(
                children: [
                  // Fondo
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progreso
                  FractionallySizedBox(
                    widthFactor: porcentajeVisual,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Porcentaje
              Text(
                '${item.porcentaje}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForItem(String nombre) {
    if (tipo == 'categoria') {
      switch (nombre.toLowerCase()) {
        case 'electronica':
          return const Color(0xFFFF9800); // Naranja
        case 'ropa':
          return const Color(0xFF9C27B0); // Púrpura
        case 'documentos':
          return const Color(0xFFF44336); // Rojo
        case 'otros':
          return const Color(0xFF607D8B); // Gris
        default:
          return const Color(0xFF9E9E9E);
      }
    } else {
      // Laboratorios - usar paleta variada
      final colors = [
        const Color(0xFF2196F3),
        const Color(0xFF4CAF50),
        const Color(0xFFFF9800),
        const Color(0xFF9C27B0),
        const Color(0xFFF44336),
      ];
      return colors[data.indexWhere((d) => d.nombre == nombre) % colors.length];
    }
  }

  String _formatNombre(String nombre) {
    if (tipo == 'categoria') {
      switch (nombre.toLowerCase()) {
        case 'electronica':
          return '📱 Electrónica';
        case 'ropa':
          return '👕 Ropa';
        case 'documentos':
          return '📄 Documentos';
        case 'otros':
          return '🎒 Otros';
        default:
          return nombre;
      }
    } else {
      return '🔬 $nombre';
    }
  }
}