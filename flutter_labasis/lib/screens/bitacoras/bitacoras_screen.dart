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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'borrador':
        return const Color(0xFFFF9800); // Naranja
      case 'completada':
        return const Color(0xFF4CAF50); // Verde
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'borrador':
        return 'BORRADOR';
      case 'completada':
        return 'COMPLETADA';
      default:
        return estado.toUpperCase();
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ),

                    // Lista de bitácoras
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _loadBitacoras,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : _bitacorasFiltradas.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay bitácoras',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _loadBitacoras,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        itemCount: _bitacorasFiltradas.length,
                                        itemBuilder: (context, index) {
                                          final bitacora =
                                              _bitacorasFiltradas[index];
                                          return _BitacoraCard(
                                            bitacora: bitacora,
                                            estadoColor:
                                                _getEstadoColor(bitacora.estado),
                                            estadoTexto:
                                                _getEstadoTexto(bitacora.estado),
                                            onTap: () {
                                              _showBitacoraDetail(bitacora);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNuevaBitacoraDialog();
        },
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva Bitácora',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showBitacoraDetail(BitacoraModel bitacora) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bitacora.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(bitacora.estado).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEstadoColor(bitacora.estado),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _getEstadoTexto(bitacora.estado),
                    style: TextStyle(
                      color: _getEstadoColor(bitacora.estado),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItem(
                      icon: Icons.science,
                      label: 'Laboratorio ID',
                      value: bitacora.laboratorioId.toString(),
                    ),
                    const SizedBox(height: 16),
                    _DetailItem(
                      icon: Icons.calendar_today,
                      label: 'Fecha',
                      value: DateFormat('dd/MM/yyyy').format(
                        DateTime.parse(bitacora.fecha),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailItem(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Turno',
                      value: bitacora.turno.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CERRAR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNuevaBitacoraDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de crear bitácora - Próximamente'),
        backgroundColor: Color(0xFF2196F3),
        duration: Duration(seconds: 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _BitacoraCard extends StatelessWidget {
  final BitacoraModel bitacora;
  final Color estadoColor;
  final String estadoTexto;
  final VoidCallback onTap;

  const _BitacoraCard({
    required this.bitacora,
    required this.estadoColor,
    required this.estadoTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Información
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
                    const SizedBox(height: 4),
                    Text(
                      'Lab ID: ${bitacora.laboratorioId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(bitacora.fecha),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: estadoColor, width: 1.5),
                ),
                child: Text(
                  estadoTexto,
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}