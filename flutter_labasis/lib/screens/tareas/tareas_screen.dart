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
        return const Color(0xFFF44336); // Rojo
      case 'media':
        return const Color(0xFFFF9800); // Naranja
      case 'baja':
        return const Color(0xFF4CAF50); // Verde
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFFFC107); // Amarillo
      case 'en_proceso':
        return const Color(0xFF2196F3); // Azul
      case 'completada':
        return const Color(0xFF4CAF50); // Verde
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
                    // Filtros horizontales
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
                                        onPressed: _loadTareas,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : _tareasFiltradas.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.assignment_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay tareas',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _loadTareas,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        itemCount: _tareasFiltradas.length,
                                        itemBuilder: (context, index) {
                                          final tarea = _tareasFiltradas[index];
                                          return _TareaCard(
                                            tarea: tarea,
                                            prioridadColor: _getPrioridadColor(
                                                tarea.prioridad),
                                            estadoColor:
                                                _getEstadoColor(tarea.estado),
                                            onTap: () {
                                              _showTareaDetail(tarea);
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
    );
  }

  void _showTareaDetail(TareaModel tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              tarea.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Descripción
            if (tarea.descripcion != null && tarea.descripcion!.isNotEmpty) ...[
              const Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tarea.descripcion!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],

            // Info en fila
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Estado:',
                    value: tarea.estadoTexto,
                    valueColor: _getEstadoColor(tarea.estado),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Prioridad:',
                    value: tarea.prioridadTexto,
                    valueColor: _getPrioridadColor(tarea.prioridad),
                  ),
                ),
              ],
            ),

            if (tarea.fechaLimite != null) ...[
              const SizedBox(height: 16),
              _DetailItem(
                label: 'Fecha límite:',
                value: DateFormat('dd/MM/yyyy').format(
                  DateTime.parse(tarea.fechaLimite!),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CERRAR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (tarea.estado != 'completada') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _completarTarea(tarea.id);
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'COMPLETAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completarTarea(int tareaId) async {
    try {
      await TareaService.marcarCompletada(tareaId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tarea completada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Recargar tareas
      _loadTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Widget para los filtros
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
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200],
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

// Widget para las tarjetas de tareas
class _TareaCard extends StatelessWidget {
  final TareaModel tarea;
  final Color prioridadColor;
  final Color estadoColor;
  final VoidCallback onTap;

  const _TareaCard({
    required this.tarea,
    required this.prioridadColor,
    required this.estadoColor,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y badge de prioridad
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: prioridadColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: prioridadColor, width: 1.5),
                    ),
                    child: Text(
                      tarea.prioridadTexto,
                      style: TextStyle(
                        color: prioridadColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Descripción
              if (tarea.descripcion != null && tarea.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  tarea.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Badge de estado y fecha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tarea.estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (tarea.fechaLimite != null)
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
                            DateTime.parse(tarea.fechaLimite!),
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
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para items de detalle
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}