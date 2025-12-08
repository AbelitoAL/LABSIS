// lib/screens/estadisticas/widgets/pie_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/estadisticas_model.dart';

class PieChartWidget extends StatelessWidget {
  final List<GraficaItemModel> data;

  const PieChartWidget({
    Key? key,
    required this.data,
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
      children: [
        // Gráfica
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Leyenda
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.map((item) {
            final color = _getColorForEstado(item.nombre);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatEstado(item.nombre)}: ${item.cantidad} (${item.porcentaje}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return data.map((item) {
      final color = _getColorForEstado(item.nombre);
      return PieChartSectionData(
        value: item.cantidad.toDouble(),
        title: '${item.porcentaje}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFFFC107); // Amarillo
      case 'en_proceso':
        return const Color(0xFF2196F3); // Azul
      case 'completada':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  String _formatEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendientes';
      case 'en_proceso':
        return 'En Proceso';
      case 'completada':
        return 'Completadas';
      default:
        return estado;
    }
  }
}