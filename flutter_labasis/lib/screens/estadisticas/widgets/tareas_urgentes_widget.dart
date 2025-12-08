// lib/screens/estadisticas/widgets/tareas_urgentes_widget.dart

import 'package:flutter/material.dart';
import '../../../models/estadisticas_model.dart';

class TareasUrgentesWidget extends StatelessWidget {
  final List<TareaUrgenteModel> tareas;

  const TareasUrgentesWidget({
    Key? key,
    required this.tareas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tareas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
              SizedBox(height: 12),
              Text(
                '¡Todo al día!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'No hay tareas próximas a vencer',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: tareas.map((tarea) {
        final urgenciaColor = _getColorForUrgencia(tarea.urgencia);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: urgenciaColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: urgenciaColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y urgencia
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tarea.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgenciaColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIconForUrgencia(tarea.urgencia),
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tarea.urgenciaTexto,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (tarea.descripcion != null && tarea.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    tarea.descripcion!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Detalles
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (tarea.auxiliar != null)
                      _buildDetailChip(
                        Icons.person,
                        tarea.auxiliar!,
                        const Color(0xFF2196F3),
                      ),
                    if (tarea.laboratorio != null)
                      _buildDetailChip(
                        Icons.science,
                        tarea.laboratorio!,
                        const Color(0xFF4CAF50),
                      ),
                    _buildDetailChip(
                      Icons.flag,
                      tarea.prioridad.toUpperCase(),
                      _getColorForPrioridad(tarea.prioridad),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForUrgencia(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'alta':
        return const Color(0xFFF44336); // Rojo
      case 'media':
        return const Color(0xFFFFC107); // Amarillo
      case 'baja':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  IconData _getIconForUrgencia(String urgencia) {
    switch (urgencia.toLowerCase()) {
      case 'alta':
        return Icons.warning;
      case 'media':
        return Icons.info;
      case 'baja':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  Color _getColorForPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return const Color(0xFFF44336);
      case 'media':
        return const Color(0xFFFF9800);
      case 'baja':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}