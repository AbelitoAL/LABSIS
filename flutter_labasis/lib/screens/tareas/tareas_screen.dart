// lib/screens/tareas/tareas_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tarea_model.dart';
import '../../services/tarea_service.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  List<TareaModel> _tareas = [];
  List<TareaModel> _tareasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  String _filtroActual = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadTareas();
  }

  Future<void> _loadTareas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final tareas = await TareaService.getMisTareas();

      setState(() {
        _tareas = tareas;
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
        _tareasFiltradas = _tareas;
      } else if (filtro == 'Pendientes') {
        _tareasFiltradas =
            _tareas.where((t) => t.estado == 'pendiente').toList();
      } else if (filtro == 'En Proceso') {
        _tareasFiltradas =
            _tareas.where((t) => t.estado == 'en_proceso').toList();
      } else if (filtro == 'Completadas') {
        _tareasFiltradas =
            _tareas.where((t) => t.estado == 'completada').toList();
      }
    });
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
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
                    'Tareas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                    onPressed: _loadTareas,
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FiltroChip(
                              label: 'Todas',
                              isSelected: _filtroActual == 'Todas',
                              onTap: () => _aplicarFiltro('Todas'),
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'Pendientes',
                              isSelected: _filtroActual == 'Pendientes',
                              onTap: () => _aplicarFiltro('Pendientes'),
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'En Proceso',
                              isSelected: _filtroActual == 'En Proceso',
                              onTap: () => _aplicarFiltro('En Proceso'),
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

                    // Lista de tareas
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
                                          onPressed: _loadTareas,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _tareasFiltradas.isEmpty
                                  ? const Center(
                                      child: Text('No hay tareas'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: _tareasFiltradas.length,
                                      itemBuilder: (context, index) {
                                        final tarea = _tareasFiltradas[index];
                                        return _TareaCard(
                                          tarea: tarea,
                                          prioridadColor:
                                              _getPrioridadColor(tarea.prioridad),
                                          onTap: () {
                                            _showTareaDetail(tarea);
                                          },
                                        );
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
    );
  }

  void _showTareaDetail(TareaModel tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (tarea.descripcion != null) ...[
                  const Text(
                    'Descripción:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tarea.descripcion!),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(tarea.estadoTexto),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Prioridad:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(tarea.prioridadTexto),
                  ],
                ),
                if (tarea.fechaLimite != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Fecha límite:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(tarea.fechaLimite!)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                if (tarea.estado != 'completada')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await TareaService.marcarCompletada(tarea.id);
                          Navigator.pop(context);
                          _loadTareas();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tarea completada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'COMPLETAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CERRAR'),
                  ),
                ),
              ],
            ),
          );
        },
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
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200],
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

class _TareaCard extends StatelessWidget {
  final TareaModel tarea;
  final Color prioridadColor;
  final VoidCallback onTap;

  const _TareaCard({
    required this.tarea,
    required this.prioridadColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tarea.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: prioridadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: prioridadColor),
                    ),
                    child: Text(
                      tarea.prioridadTexto,
                      style: TextStyle(
                        color: prioridadColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (tarea.descripcion != null) ...[
                const SizedBox(height: 8),
                Text(
                  tarea.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tarea.estadoTexto,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (tarea.fechaLimite != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(tarea.fechaLimite!)),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
