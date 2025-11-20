// lib/screens/laboratorios/laboratorios_screen.dart

import 'package:flutter/material.dart';
import '../../models/laboratorio_model.dart';
import '../../services/laboratorio_service.dart';

class LaboratoriosScreen extends StatefulWidget {
  const LaboratoriosScreen({super.key});

  @override
  State<LaboratoriosScreen> createState() => _LaboratoriosScreenState();
}

class _LaboratoriosScreenState extends State<LaboratoriosScreen> {
  List<LaboratorioModel> _laboratorios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLaboratorios();
  }

  Future<void> _loadLaboratorios() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final laboratorios = await LaboratorioService.getAll();

      setState(() {
        _laboratorios = laboratorios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'mantenimiento':
        return Colors.orange;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laboratorios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                    onPressed: _loadLaboratorios,
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadLaboratorios,
                                    child: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _laboratorios.isEmpty
                            ? const Center(
                                child: Text('No hay laboratorios disponibles'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _laboratorios.length,
                                itemBuilder: (context, index) {
                                  final lab = _laboratorios[index];
                                  return _LaboratorioCard(
                                    laboratorio: lab,
                                    estadoColor: _getEstadoColor(lab.estado),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaboratorioCard extends StatelessWidget {
  final LaboratorioModel laboratorio;
  final Color estadoColor;

  const _LaboratorioCard({
    required this.laboratorio,
    required this.estadoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laboratorio.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        laboratorio.codigo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: estadoColor),
                  ),
                  child: Text(
                    laboratorio.estado.toUpperCase(),
                    style: TextStyle(
                      color: estadoColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (laboratorio.ubicacion != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    laboratorio.ubicacion!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (laboratorio.capacidad != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Capacidad: ${laboratorio.capacidad} personas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
