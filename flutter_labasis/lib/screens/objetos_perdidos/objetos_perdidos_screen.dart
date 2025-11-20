// lib/screens/objetos_perdidos/objetos_perdidos_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/objeto_perdido_model.dart';
import '../../services/objeto_perdido_service.dart';

class ObjetosPerdidosScreen extends StatefulWidget {
  const ObjetosPerdidosScreen({super.key});

  @override
  State<ObjetosPerdidosScreen> createState() => _ObjetosPerdidosScreenState();
}

class _ObjetosPerdidosScreenState extends State<ObjetosPerdidosScreen> {
  List<ObjetoPerdidoModel> _objetos = [];
  List<ObjetoPerdidoModel> _objetosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _filtroEstado = 'Todos';
  String _filtroCategoria = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadObjetos();
  }

  Future<void> _loadObjetos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final objetos = await ObjetoPerdidoService.getAll();

      setState(() {
        _objetos = objetos;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _objetosFiltrados = _objetos.where((obj) {
        bool cumpleEstado = true;
        bool cumpleCategoria = true;

        if (_filtroEstado != 'Todos') {
          cumpleEstado = obj.estado ==
              (_filtroEstado == 'Encontrados' ? 'encontrado' : 'entregado');
        }

        if (_filtroCategoria != 'Todas') {
          cumpleCategoria = obj.categoria.toLowerCase() ==
              _filtroCategoria.toLowerCase();
        }

        return cumpleEstado && cumpleCategoria;
      }).toList();
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
                      'Objetos Perdidos',
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
                    onPressed: _loadObjetos,
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
                    // Filtros de Estado
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _FiltroChip(
                                label: 'Todos',
                                isSelected: _filtroEstado == 'Todos',
                                color: const Color(0xFF9C27B0),
                                onTap: () {
                                  setState(() {
                                    _filtroEstado = 'Todos';
                                    _aplicarFiltros();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _FiltroChip(
                                label: 'Encontrados',
                                isSelected: _filtroEstado == 'Encontrados',
                                color: const Color(0xFF9C27B0),
                                onTap: () {
                                  setState(() {
                                    _filtroEstado = 'Encontrados';
                                    _aplicarFiltros();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              _FiltroChip(
                                label: 'Entregados',
                                isSelected: _filtroEstado == 'Entregados',
                                color: const Color(0xFF9C27B0),
                                onTap: () {
                                  setState(() {
                                    _filtroEstado = 'Entregados';
                                    _aplicarFiltros();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Filtros de Categoría
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categoría:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FiltroChip(
                                  label: 'Todas',
                                  isSelected: _filtroCategoria == 'Todas',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() {
                                      _filtroCategoria = 'Todas';
                                      _aplicarFiltros();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: '📱 Electrónica',
                                  isSelected: _filtroCategoria == 'electronica',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() {
                                      _filtroCategoria = 'electronica';
                                      _aplicarFiltros();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: '👕 Ropa',
                                  isSelected: _filtroCategoria == 'ropa',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() {
                                      _filtroCategoria = 'ropa';
                                      _aplicarFiltros();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: '📄 Documentos',
                                  isSelected: _filtroCategoria == 'documentos',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() {
                                      _filtroCategoria = 'documentos';
                                      _aplicarFiltros();
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: '🎒 Accesorios',
                                  isSelected: _filtroCategoria == 'accesorios',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() {
                                      _filtroCategoria = 'accesorios';
                                      _aplicarFiltros();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de objetos
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
                                          onPressed: _loadObjetos,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _objetosFiltrados.isEmpty
                                  ? const Center(
                                      child: Text('No hay objetos perdidos'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: _objetosFiltrados.length,
                                      itemBuilder: (context, index) {
                                        final objeto = _objetosFiltrados[index];
                                        return _ObjetoCard(objeto: objeto);
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
          // TODO: Implementar registrar objeto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función en desarrollo'),
            ),
          );
        },
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ObjetoCard extends StatelessWidget {
  final ObjetoPerdidoModel objeto;

  const _ObjetoCard({required this.objeto});

  Color get _estadoColor {
    return objeto.estado == 'entregado' ? Colors.green : Colors.orange;
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    objeto.categoriaEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        objeto.descripcion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        objeto.categoriaTexto,
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
                    objeto.estadoTexto,
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
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Lab ID: ${objeto.laboratorioId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(objeto.fechaEncontrado)),
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
