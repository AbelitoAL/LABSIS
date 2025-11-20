// lib/screens/bitacoras/bitacoras_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bitacora_model.dart';
import '../../services/bitacora_service.dart';

class BitacorasScreen extends StatefulWidget {
  const BitacorasScreen({super.key});

  @override
  State<BitacorasScreen> createState() => _BitacorasScreenState();
}

class _BitacorasScreenState extends State<BitacorasScreen> {
  List<BitacoraModel> _bitacoras = [];
  List<BitacoraModel> _bitacorasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  String _filtroActual = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadBitacoras();
  }

  Future<void> _loadBitacoras() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bitacoras = await BitacoraService.getAll();

      setState(() {
        _bitacoras = bitacoras;
        _aplicarFiltro(_filtroActual);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltro(String filtro) {
    setState(() {
      _filtroActual = filtro;
      if (filtro == 'Todas') {
        _bitacorasFiltradas = _bitacoras;
      } else if (filtro == 'Borradores') {
        _bitacorasFiltradas =
            _bitacoras.where((b) => b.estado == 'borrador').toList();
      } else if (filtro == 'Completadas') {
        _bitacorasFiltradas =
            _bitacoras.where((b) => b.estado == 'completada').toList();
      }
    });
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Bitácoras',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                    onPressed: _loadBitacoras,
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
                child: Column(
                  children: [
                    // Filtros
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _FiltroChip(
                            label: 'Todas',
                            isSelected: _filtroActual == 'Todas',
                            onTap: () => _aplicarFiltro('Todas'),
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Borradores',
                            isSelected: _filtroActual == 'Borradores',
                            onTap: () => _aplicarFiltro('Borradores'),
                          ),
                          const SizedBox(width: 8),
                          _FiltroChip(
                            label: 'Completadas',
                            isSelected: _filtroActual == 'Completadas',
                            onTap: () => _aplicarFiltro('Completadas'),
                          ),
                        ],
                      ),
                    ),

                    // Lista de bitácoras
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          onPressed: _loadBitacoras,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _bitacorasFiltradas.isEmpty
                                  ? const Center(
                                      child: Text('No hay bitácoras'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: _bitacorasFiltradas.length,
                                      itemBuilder: (context, index) {
                                        final bitacora =
                                            _bitacorasFiltradas[index];
                                        return _BitacoraCard(
                                            bitacora: bitacora);
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar nueva bitácora
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función en desarrollo'),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BitacoraCard extends StatelessWidget {
  final BitacoraModel bitacora;

  const _BitacoraCard({required this.bitacora});

  Color get _estadoColor {
    return bitacora.estado == 'completada' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bitacora.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Lab ID: ${bitacora.laboratorioId}',
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _estadoColor),
                  ),
                  child: Text(
                    bitacora.estadoTexto,
                    style: TextStyle(
                      color: _estadoColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(bitacora.fecha)),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  bitacora.turnoTexto,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}