// lib/screens/tareas/tareas_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tarea_model.dart';
import '../../models/laboratorio_model.dart';
import '../../services/tarea_service.dart';
import '../../services/user_service.dart';
import '../../services/laboratorio_service.dart';
import '../../providers/auth_provider.dart';

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
        return const Color(0xFFF44336);
      case 'media':
        return const Color(0xFFFF9800);
      case 'baja':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFFFC107);
      case 'en_proceso':
        return const Color(0xFF2196F3);
      case 'completada':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.rol == 'admin';

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
                                            isAdmin: isAdmin,
                                            onTap: () {
                                              _showTareaDetail(tarea);
                                            },
                                            onEdit: isAdmin
                                                ? () => _showEditDialog(tarea)
                                                : null,
                                            onDelete: isAdmin
                                                ? () => _confirmDelete(tarea)
                                                : null,
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
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(),
              backgroundColor: const Color(0xFF2196F3),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nueva Tarea',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  void _showTareaDetail(TareaModel tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TareaDetailModal(
        tarea: tarea,
        prioridadColor: _getPrioridadColor(tarea.prioridad),
        estadoColor: _getEstadoColor(tarea.estado),
        onMarcarCompletada: tarea.estado != 'completada'
            ? () async {
                Navigator.pop(context);
                await _completarTarea(tarea.id);
              }
            : null,
      ),
    );
  }

  void _showCreateDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioTarea(
          onSuccess: _loadTareas,
        ),
      ),
    );
  }

  void _showEditDialog(TareaModel tarea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioTarea(
          tarea: tarea,
          onSuccess: _loadTareas,
        ),
      ),
    );
  }

  void _confirmDelete(TareaModel tarea) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${tarea.titulo}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTarea(tarea.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTarea(int id) async {
    try {
      await TareaService.delete(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tarea eliminada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadTareas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completarTarea(int id) async {
    try {
      await TareaService.marcarCompletada(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tarea completada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadTareas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Widget de chip de filtro
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

// Widget de tarjeta de tarea
class _TareaCard extends StatelessWidget {
  final TareaModel tarea;
  final Color prioridadColor;
  final Color estadoColor;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TareaCard({
    required this.tarea,
    required this.prioridadColor,
    required this.estadoColor,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
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
              // Título y badges
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
                  if (isAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
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

              // Estado y fecha
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

// Modal de detalle
class _TareaDetailModal extends StatelessWidget {
  final TareaModel tarea;
  final Color prioridadColor;
  final Color estadoColor;
  final VoidCallback? onMarcarCompletada;

  const _TareaDetailModal({
    required this.tarea,
    required this.prioridadColor,
    required this.estadoColor,
    this.onMarcarCompletada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
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

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (tarea.descripcion != null &&
                      tarea.descripcion!.isNotEmpty) ...[
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

                  // Estado y Prioridad
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tarea.estadoTexto,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: estadoColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prioridad:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tarea.prioridadTexto,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: prioridadColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (tarea.fechaLimite != null) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha límite:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(tarea.fechaLimite!),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

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
              if (onMarcarCompletada != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onMarcarCompletada,
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
    );
  }
}

// Pantalla de formulario (Crear/Editar)
class _FormularioTarea extends StatefulWidget {
  final TareaModel? tarea;
  final VoidCallback onSuccess;

  const _FormularioTarea({
    this.tarea,
    required this.onSuccess,
  });

  @override
  State<_FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<_FormularioTarea> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  List<Map<String, dynamic>> _auxiliares = [];
  List<LaboratorioModel> _laboratorios = [];

  int? _auxiliarSeleccionado;
  int? _laboratorioSeleccionado;
  String _prioridadSeleccionada = 'media';
  String _estadoSeleccionado = 'pendiente';
  DateTime? _fechaLimite;

  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get isEditing => widget.tarea != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (isEditing) {
      _loadTareaData();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final auxiliares = await UserService.getAuxiliares();
      final laboratorios = await LaboratorioService.getAll();

      setState(() {
        _auxiliares = auxiliares;
        _laboratorios = laboratorios;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadTareaData() {
    _tituloController.text = widget.tarea!.titulo;
    _descripcionController.text = widget.tarea!.descripcion ?? '';
    _auxiliarSeleccionado = widget.tarea!.auxiliarId;
    _laboratorioSeleccionado = widget.tarea!.laboratorioId;
    _prioridadSeleccionada = widget.tarea!.prioridad;
    _estadoSeleccionado = widget.tarea!.estado;

    if (widget.tarea!.fechaLimite != null) {
      _fechaLimite = DateTime.parse(widget.tarea!.fechaLimite!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editar Tarea' : 'Nueva Tarea',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono central
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment,
                            size: 50,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título de la Tarea *',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          return TareaService.validarDatos(titulo: value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText: 'Máximo 500 caracteres',
                        ),
                        maxLength: 500,
                      ),

                      const SizedBox(height: 16),

                      // Auxiliar
                      DropdownButtonFormField<int>(
                        value: _auxiliarSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Auxiliar Asignado *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _auxiliares.map<DropdownMenuItem<int>>((aux) {
                          return DropdownMenuItem<int>(
                              value: aux['id'] as int,
                              child: Text(aux['nombre'] as String),
                            );
                        }).toList(),
                        onChanged: isEditing
                            ? null
                            : (value) {
                                setState(() => _auxiliarSeleccionado = value);
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona un auxiliar';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Laboratorio
                      DropdownButtonFormField<int>(
                        value: _laboratorioSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Laboratorio (Opcional)',
                          prefixIcon: const Icon(Icons.science),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sin laboratorio'),
                          ),
                          ..._laboratorios.map((lab) {
                            return DropdownMenuItem(
                              value: lab.id,
                              child: Text(lab.nombre),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _laboratorioSeleccionado = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Prioridad
                      const Text(
                        'Prioridad *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _PrioridadChip(
                              label: 'Alta',
                              color: const Color(0xFFF44336),
                              isSelected: _prioridadSeleccionada == 'alta',
                              onTap: () => setState(
                                  () => _prioridadSeleccionada = 'alta'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PrioridadChip(
                              label: 'Media',
                              color: const Color(0xFFFF9800),
                              isSelected: _prioridadSeleccionada == 'media',
                              onTap: () => setState(
                                  () => _prioridadSeleccionada = 'media'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PrioridadChip(
                              label: 'Baja',
                              color: const Color(0xFF4CAF50),
                              isSelected: _prioridadSeleccionada == 'baja',
                              onTap: () => setState(
                                  () => _prioridadSeleccionada = 'baja'),
                            ),
                          ),
                        ],
                      ),

                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Estado *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _EstadoChip(
                                label: 'Pendiente',
                                icon: Icons.schedule,
                                color: const Color(0xFFFFC107),
                                isSelected: _estadoSeleccionado == 'pendiente',
                                onTap: () => setState(
                                    () => _estadoSeleccionado = 'pendiente'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _EstadoChip(
                                label: 'En Proceso',
                                icon: Icons.play_circle,
                                color: const Color(0xFF2196F3),
                                isSelected: _estadoSeleccionado == 'en_proceso',
                                onTap: () => setState(
                                    () => _estadoSeleccionado = 'en_proceso'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _EstadoChip(
                                label: 'Completada',
                                icon: Icons.check_circle,
                                color: const Color(0xFF4CAF50),
                                isSelected: _estadoSeleccionado == 'completada',
                                onTap: () => setState(
                                    () => _estadoSeleccionado = 'completada'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Fecha límite
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _fechaLimite == null
                                ? 'Fecha Límite (Opcional)'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_fechaLimite!),
                            style: TextStyle(
                              color: _fechaLimite == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                          trailing: _fechaLimite != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => _fechaLimite = null);
                                  },
                                )
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaLimite ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (fecha != null) {
                              setState(() => _fechaLimite = fecha);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'GUARDAR CAMBIOS'
                                      : 'CREAR TAREA',
                                  style: const TextStyle(
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
              ),
            ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        // Actualizar
        await TareaService.update(
          id: widget.tarea!.id,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim().isNotEmpty
              ? _descripcionController.text.trim()
              : null,
          prioridad: _prioridadSeleccionada,
          estado: _estadoSeleccionado,
          fechaLimite: _fechaLimite?.toIso8601String(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Tarea actualizada exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Crear
        await TareaService.create(
          titulo: _tituloController.text.trim(),
          auxiliarId: _auxiliarSeleccionado!,
          descripcion: _descripcionController.text.trim().isNotEmpty
              ? _descripcionController.text.trim()
              : null,
          laboratorioId: _laboratorioSeleccionado,
          prioridad: _prioridadSeleccionada,
          fechaLimite: _fechaLimite?.toIso8601String(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Tarea creada exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }

      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Widget de chip de prioridad
class _PrioridadChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrioridadChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de chip de estado
class _EstadoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _EstadoChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}