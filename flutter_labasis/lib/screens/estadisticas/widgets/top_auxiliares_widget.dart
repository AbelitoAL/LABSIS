// lib/screens/estadisticas/widgets/top_auxiliares_widget.dart

import 'package:flutter/material.dart';
import '../../../models/estadisticas_model.dart';

class TopAuxiliaresWidget extends StatelessWidget {
  final List<TopAuxiliarModel> topAuxiliares;

  const TopAuxiliaresWidget({
    Key? key,
    required this.topAuxiliares,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topAuxiliares.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay auxiliares registrados',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: topAuxiliares.map((auxiliar) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getColorForPosicion(auxiliar.posicion).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getColorForPosicion(auxiliar.posicion).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Medalla/Posición
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForPosicion(auxiliar.posicion),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    auxiliar.medallaEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Información del auxiliar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auxiliar.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auxiliar.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Estadísticas
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildStatChip(
                          '📋 ${auxiliar.tareas}',
                          'tareas',
                          const Color(0xFF2196F3),
                        ),
                        _buildStatChip(
                          '📝 ${auxiliar.bitacoras}',
                          'bitácoras',
                          const Color(0xFF4CAF50),
                        ),
                        _buildStatChip(
                          '📦 ${auxiliar.objetos}',
                          'objetos',
                          const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorForPosicion(auxiliar.posicion),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      auxiliar.total.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'total',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatChip(String text, String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getColorForPosicion(int posicion) {
    switch (posicion) {
      case 1:
        return const Color(0xFFFFD700); // Oro
      case 2:
        return const Color(0xFFC0C0C0); // Plata
      case 3:
        return const Color(0xFFCD7F32); // Bronce
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }
}