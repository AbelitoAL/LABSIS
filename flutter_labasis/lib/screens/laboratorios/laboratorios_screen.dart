// lib/screens/laboratorios/laboratorios_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/laboratorio_model.dart';
import '../../services/laboratorio_service.dart';
import '../../providers/auth_provider.dart';

class LaboratoriosScreen extends StatefulWidget {
  const LaboratoriosScreen({super.key});

  @override
  State<LaboratoriosScreen> createState() => _LaboratoriosScreenState();
}

class _LaboratoriosScreenState extends State<LaboratoriosScreen> {
  List<LaboratorioModel> _laboratorios = [];
  List<LaboratorioModel> _laboratoriosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  String _filtroEstado = 'Todos';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLaboratorios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    List<LaboratorioModel> resultado = _laboratorios;

    // Filtro por estado
    if (_filtroEstado != 'Todos') {
      resultado = resultado
          .where((lab) =>
              lab.estado.toLowerCase() == _filtroEstado.toLowerCase())
          .toList();
    }

    // Filtro por búsqueda
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((lab) {
        return lab.nombre.toLowerCase().contains(query) ||
            lab.codigo.toLowerCase().contains(query) ||
            (lab.ubicacion?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() {
      _laboratoriosFiltrados = resultado;
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return const Color(0xFF4CAF50);
      case 'mantenimiento':
        return const Color(0xFFFF9800);
      case 'inactivo':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return 'ACTIVO';
      case 'mantenimiento':
        return 'MANTENIMIENTO';
      case 'inactivo':
        return 'INACTIVO';
      default:
        return estado.toUpperCase();
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
                    'Laboratorios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Botón de búsqueda
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Colors.white,
                        onPressed: () {
                          _showSearchDialog();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.white,
                        onPressed: _loadLaboratorios,
                      ),
                    ],
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
                    // Filtros de estado
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _FiltroChip(
                              label: 'Todos',
                              isSelected: _filtroEstado == 'Todos',
                              color: const Color(0xFF2196F3),
                              onTap: () {
                                setState(() => _filtroEstado = 'Todos');
                                _aplicarFiltros();
                              },
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'Activo',
                              isSelected: _filtroEstado == 'Activo',
                              color: const Color(0xFF4CAF50),
                              onTap: () {
                                setState(() => _filtroEstado = 'Activo');
                                _aplicarFiltros();
                              },
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'Mantenimiento',
                              isSelected: _filtroEstado == 'Mantenimiento',
                              color: const Color(0xFFFF9800),
                              onTap: () {
                                setState(() => _filtroEstado = 'Mantenimiento');
                                _aplicarFiltros();
                              },
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'Inactivo',
                              isSelected: _filtroEstado == 'Inactivo',
                              color: const Color(0xFFF44336),
                              onTap: () {
                                setState(() => _filtroEstado = 'Inactivo');
                                _aplicarFiltros();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de laboratorios
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
                                        onPressed: _loadLaboratorios,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : _laboratoriosFiltrados.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.science_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay laboratorios',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _loadLaboratorios,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount:
                                            _laboratoriosFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final lab =
                                              _laboratoriosFiltrados[index];
                                          return _LaboratorioCard(
                                            laboratorio: lab,
                                            estadoColor:
                                                _getEstadoColor(lab.estado),
                                            estadoTexto:
                                                _getEstadoTexto(lab.estado),
                                            isAdmin: isAdmin,
                                            onTap: () {
                                              _showLaboratorioDetail(lab);
                                            },
                                            onEdit: isAdmin
                                                ? () => _showEditDialog(lab)
                                                : null,
                                            onDelete: isAdmin
                                                ? () => _confirmDelete(lab)
                                                : null,
                                            onChangeStatus: isAdmin
                                                ? () =>
                                                    _showChangeStatusDialog(lab)
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
      // FAB solo para administradores
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(),
              backgroundColor: const Color(0xFF2196F3),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nuevo Laboratorio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // Diálogo de búsqueda
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Laboratorio'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nombre, código o ubicación...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _aplicarFiltros();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              _aplicarFiltros();
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Mostrar detalle del laboratorio
  void _showLaboratorioDetail(LaboratorioModel lab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LaboratorioDetailModal(
        laboratorio: lab,
        estadoColor: _getEstadoColor(lab.estado),
        estadoTexto: _getEstadoTexto(lab.estado),
      ),
    );
  }

  // Diálogo de crear laboratorio
  void _showCreateDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioLaboratorio(
          onSuccess: _loadLaboratorios,
        ),
      ),
    );
  }

  // Diálogo de editar laboratorio
  void _showEditDialog(LaboratorioModel lab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioLaboratorio(
          laboratorio: lab,
          onSuccess: _loadLaboratorios,
        ),
      ),
    );
  }

  // Confirmar eliminación
  void _confirmDelete(LaboratorioModel lab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Laboratorio'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${lab.nombre}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLaboratorio(lab.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Eliminar laboratorio
  Future<void> _deleteLaboratorio(int id) async {
    try {
      await LaboratorioService.delete(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Laboratorio eliminado exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadLaboratorios();
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

  // Diálogo de cambiar estado
  void _showChangeStatusDialog(LaboratorioModel lab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EstadoOption(
              label: 'Activo',
              icon: Icons.check_circle,
              color: const Color(0xFF4CAF50),
              isSelected: lab.estado == 'activo',
              onTap: () {
                Navigator.pop(context);
                _updateEstado(lab.id, 'activo');
              },
            ),
            _EstadoOption(
              label: 'Mantenimiento',
              icon: Icons.build,
              color: const Color(0xFFFF9800),
              isSelected: lab.estado == 'mantenimiento',
              onTap: () {
                Navigator.pop(context);
                _updateEstado(lab.id, 'mantenimiento');
              },
            ),
            _EstadoOption(
              label: 'Inactivo',
              icon: Icons.cancel,
              color: const Color(0xFFF44336),
              isSelected: lab.estado == 'inactivo',
              onTap: () {
                Navigator.pop(context);
                _updateEstado(lab.id, 'inactivo');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Actualizar estado
  Future<void> _updateEstado(int id, String estado) async {
    try {
      await LaboratorioService.updateEstado(id, estado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Estado actualizado exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadLaboratorios();
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
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

// Widget de tarjeta de laboratorio
class _LaboratorioCard extends StatelessWidget {
  final LaboratorioModel laboratorio;
  final Color estadoColor;
  final String estadoTexto;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeStatus;

  const _LaboratorioCard({
    required this.laboratorio,
    required this.estadoColor,
    required this.estadoTexto,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onChangeStatus,
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
              // Fila superior: Icono, nombre y menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 4),
                        Text(
                          laboratorio.codigo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  // Menú de opciones para admin
                  if (isAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'status') {
                          onChangeStatus?.call();
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
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 20),
                              SizedBox(width: 8),
                              Text('Cambiar Estado'),
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

              // Ubicación
              if (laboratorio.ubicacion != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        laboratorio.ubicacion!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Capacidad
              if (laboratorio.capacidad != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Capacidad: ${laboratorio.capacidad} personas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Modal de detalle
class _LaboratorioDetailModal extends StatelessWidget {
  final LaboratorioModel laboratorio;
  final Color estadoColor;
  final String estadoTexto;

  const _LaboratorioDetailModal({
    required this.laboratorio,
    required this.estadoColor,
    required this.estadoTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre y estado
          Row(
            children: [
              Expanded(
                child: Text(
                  laboratorio.nombre,
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
                  color: estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: estadoColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  estadoTexto,
                  style: TextStyle(
                    color: estadoColor,
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
                  // Código
                  _DetailRow(
                    icon: Icons.qr_code,
                    label: 'Código',
                    value: laboratorio.codigo,
                  ),

                  // Ubicación
                  if (laboratorio.ubicacion != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Ubicación',
                      value: laboratorio.ubicacion!,
                    ),
                  ],

                  // Capacidad
                  if (laboratorio.capacidad != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.people_outline,
                      label: 'Capacidad',
                      value: '${laboratorio.capacidad} personas',
                    ),
                  ],

                  // Equipamiento
                  if (laboratorio.equipamiento.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Equipamiento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...laboratorio.equipamiento.map(
                      (equipo) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                equipo,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botón cerrar
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
    );
  }
}

// Widget de fila de detalle
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

// Widget de opción de estado
class _EstadoOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _EstadoOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

// Pantalla de formulario (Crear/Editar)
class _FormularioLaboratorio extends StatefulWidget {
  final LaboratorioModel? laboratorio;
  final VoidCallback onSuccess;

  const _FormularioLaboratorio({
    this.laboratorio,
    required this.onSuccess,
  });

  @override
  State<_FormularioLaboratorio> createState() => _FormularioLaboratorioState();
}

class _FormularioLaboratorioState extends State<_FormularioLaboratorio> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _equipamientoController = TextEditingController();
  String _estadoSeleccionado = 'activo';
  bool _isLoading = false;

  bool get isEditing => widget.laboratorio != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nombreController.text = widget.laboratorio!.nombre;
      _codigoController.text = widget.laboratorio!.codigo;
      _ubicacionController.text = widget.laboratorio!.ubicacion ?? '';
      _capacidadController.text =
          widget.laboratorio!.capacidad?.toString() ?? '';
      _equipamientoController.text =
          widget.laboratorio!.equipamiento.join(', ');
      _estadoSeleccionado = widget.laboratorio!.estado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _ubicacionController.dispose();
    _capacidadController.dispose();
    _equipamientoController.dispose();
    super.dispose();
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
          isEditing ? 'Editar Laboratorio' : 'Nuevo Laboratorio',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
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
                      Icons.science,
                      size: 50,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Laboratorio *',
                    prefixIcon: const Icon(Icons.science_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final error = LaboratorioService.validarDatos(
                      nombre: value,
                    );
                    return error;
                  },
                ),

                const SizedBox(height: 16),

                // Código
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código *',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Solo letras, números y guiones',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    final error = LaboratorioService.validarDatos(
                      codigo: value,
                    );
                    return error;
                  },
                ),

                const SizedBox(height: 16),

                // Ubicación
                TextFormField(
                  controller: _ubicacionController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación (Opcional)',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Capacidad
                TextFormField(
                  controller: _capacidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Capacidad (Opcional)',
                    prefixIcon: const Icon(Icons.people_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: 'personas',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final capacidad = int.tryParse(value);
                      final error = LaboratorioService.validarDatos(
                        capacidad: capacidad,
                      );
                      return error;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Equipamiento
                TextFormField(
                  controller: _equipamientoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Equipamiento (Opcional)',
                    prefixIcon: const Icon(Icons.build_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Separa los items con comas',
                  ),
                ),

                const SizedBox(height: 16),

                // Estado
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
                        label: 'Activo',
                        icon: Icons.check_circle,
                        color: const Color(0xFF4CAF50),
                        isSelected: _estadoSeleccionado == 'activo',
                        onTap: () =>
                            setState(() => _estadoSeleccionado = 'activo'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EstadoChip(
                        label: 'Mantenimiento',
                        icon: Icons.build,
                        color: const Color(0xFFFF9800),
                        isSelected: _estadoSeleccionado == 'mantenimiento',
                        onTap: () => setState(
                            () => _estadoSeleccionado = 'mantenimiento'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EstadoChip(
                        label: 'Inactivo',
                        icon: Icons.cancel,
                        color: const Color(0xFFF44336),
                        isSelected: _estadoSeleccionado == 'inactivo',
                        onTap: () =>
                            setState(() => _estadoSeleccionado = 'inactivo'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón de guardar
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
                                : 'CREAR LABORATORIO',
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
      // Preparar equipamiento
      List<String>? equipamiento;
      if (_equipamientoController.text.isNotEmpty) {
        equipamiento = _equipamientoController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // Preparar capacidad
      int? capacidad;
      if (_capacidadController.text.isNotEmpty) {
        capacidad = int.tryParse(_capacidadController.text);
      }

      if (isEditing) {
        // Actualizar
        await LaboratorioService.update(
          id: widget.laboratorio!.id,
          nombre: _nombreController.text.trim(),
          codigo: _codigoController.text.trim().toUpperCase(),
          ubicacion: _ubicacionController.text.trim().isNotEmpty
              ? _ubicacionController.text.trim()
              : null,
          capacidad: capacidad,
          equipamiento: equipamiento,
          estado: _estadoSeleccionado,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Laboratorio actualizado exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Crear
        await LaboratorioService.create(
          nombre: _nombreController.text.trim(),
          codigo: _codigoController.text.trim().toUpperCase(),
          ubicacion: _ubicacionController.text.trim().isNotEmpty
              ? _ubicacionController.text.trim()
              : null,
          capacidad: capacidad,
          equipamiento: equipamiento,
          estado: _estadoSeleccionado,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Laboratorio creado exitosamente'),
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

// Widget de chip de estado para el formulario
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