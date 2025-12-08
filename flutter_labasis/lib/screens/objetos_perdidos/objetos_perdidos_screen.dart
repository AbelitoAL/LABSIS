// lib/screens/objetos_perdidos/objetos_perdidos_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/objeto_perdido_model.dart';
import '../../models/laboratorio_model.dart';
import '../../services/objeto_perdido_service.dart';
import '../../services/laboratorio_service.dart';

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
  String _filtroActual = 'Todos';

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
      if (filtro == 'Todos') {
        _objetosFiltrados = _objetos;
      } else if (filtro == 'En Custodia') {
        _objetosFiltrados =
            _objetos.where((o) => o.estado == 'en_custodia').toList();
      } else if (filtro == 'Entregados') {
        _objetosFiltrados =
            _objetos.where((o) => o.estado == 'entregado').toList();
      }
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'en_custodia':
        return const Color(0xFF2196F3);
      case 'entregado':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'electronica':
        return const Color(0xFFFF9800);
      case 'ropa':
        return const Color(0xFF9C27B0);
      case 'documentos':
        return const Color(0xFFF44336);
      case 'otros':
        return const Color(0xFF607D8B);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'electronica':
        return Icons.phone_android;
      case 'ropa':
        return Icons.checkroom;
      case 'documentos':
        return Icons.description;
      case 'otros':
        return Icons.inbox;
      default:
        return Icons.help_outline;
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
                    // Filtros
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _FiltroChip(
                              label: 'Todos',
                              isSelected: _filtroActual == 'Todos',
                              onTap: () => _aplicarFiltro('Todos'),
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'En Custodia',
                              isSelected: _filtroActual == 'En Custodia',
                              onTap: () => _aplicarFiltro('En Custodia'),
                            ),
                            const SizedBox(width: 8),
                            _FiltroChip(
                              label: 'Entregados',
                              isSelected: _filtroActual == 'Entregados',
                              onTap: () => _aplicarFiltro('Entregados'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de objetos
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
                                        onPressed: _loadObjetos,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : _objetosFiltrados.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay objetos perdidos',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _loadObjetos,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        itemCount: _objetosFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final objeto =
                                              _objetosFiltrados[index];
                                          return _ObjetoCard(
                                            objeto: objeto,
                                            estadoColor:
                                                _getEstadoColor(objeto.estado),
                                            categoriaColor: _getCategoriaColor(
                                                objeto.categoria),
                                            categoriaIcon: _getCategoriaIcon(
                                                objeto.categoria),
                                            onTap: () {
                                              _showObjetoDetail(objeto);
                                            },
                                            onEdit: objeto.estado == 'en_custodia'
                                                ? () => _showEditDialog(objeto)
                                                : null,
                                            onDelete: () =>
                                                _confirmDelete(objeto),
                                            onEntregar:
                                                objeto.estado == 'en_custodia'
                                                    ? () =>
                                                        _showEntregaDialog(objeto)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Objeto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showObjetoDetail(ObjetoPerdidoModel objeto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ObjetoDetailModal(
        objeto: objeto,
        estadoColor: _getEstadoColor(objeto.estado),
        categoriaColor: _getCategoriaColor(objeto.categoria),
        categoriaIcon: _getCategoriaIcon(objeto.categoria),
      ),
    );
  }

  void _showCreateDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioObjeto(
          onSuccess: _loadObjetos,
        ),
      ),
    );
  }

  void _showEditDialog(ObjetoPerdidoModel objeto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioObjeto(
          objeto: objeto,
          onSuccess: _loadObjetos,
        ),
      ),
    );
  }

  void _showEntregaDialog(ObjetoPerdidoModel objeto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioEntrega(
          objeto: objeto,
          onSuccess: _loadObjetos,
        ),
      ),
    );
  }

  void _confirmDelete(ObjetoPerdidoModel objeto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Objeto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar este objeto?\n\n"${objeto.descripcion}"\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteObjeto(objeto.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteObjeto(int id) async {
    try {
      await ObjetoPerdidoService.delete(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Objeto eliminado exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadObjetos();
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

// Widget de tarjeta de objeto
class _ObjetoCard extends StatelessWidget {
  final ObjetoPerdidoModel objeto;
  final Color estadoColor;
  final Color categoriaColor;
  final IconData categoriaIcon;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onEntregar;

  const _ObjetoCard({
    required this.objeto,
    required this.estadoColor,
    required this.categoriaColor,
    required this.categoriaIcon,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onEntregar,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Foto o icono
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: categoriaColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: objeto.fotoObjeto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          objeto.fotoObjeto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              categoriaIcon,
                              color: categoriaColor,
                              size: 32,
                            );
                          },
                        ),
                      )
                    : Icon(
                        categoriaIcon,
                        color: categoriaColor,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      objeto.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          categoriaIcon,
                          size: 14,
                          color: categoriaColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          objeto.categoriaTexto,
                          style: TextStyle(
                            fontSize: 12,
                            color: categoriaColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(objeto.fechaEncontrado),
                          ),
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

              // Badge de estado y menú
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estadoColor, width: 1.5),
                    ),
                    child: Text(
                      objeto.estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      } else if (value == 'entregar') {
                        onEntregar?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEntregar != null)
                        const PopupMenuItem(
                          value: 'entregar',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 20, color: Color(0xFF4CAF50)),
                              SizedBox(width: 8),
                              Text('Registrar Entrega',
                                  style: TextStyle(color: Color(0xFF4CAF50))),
                            ],
                          ),
                        ),
                      if (onEdit != null)
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
                      if (onDelete != null)
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
            ],
          ),
        ),
      ),
    );
  }
}

// Modal de detalle
class _ObjetoDetailModal extends StatelessWidget {
  final ObjetoPerdidoModel objeto;
  final Color estadoColor;
  final Color categoriaColor;
  final IconData categoriaIcon;

  const _ObjetoDetailModal({
    required this.objeto,
    required this.estadoColor,
    required this.categoriaColor,
    required this.categoriaIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto grande si existe
                  if (objeto.fotoObjeto != null) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          objeto.fotoObjeto!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: categoriaColor.withOpacity(0.1),
                              child: Icon(
                                categoriaIcon,
                                size: 64,
                                color: categoriaColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Estado
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: estadoColor, width: 2),
                      ),
                      child: Text(
                        objeto.estadoTexto,
                        style: TextStyle(
                          color: estadoColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    'Descripción:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    objeto.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Categoría
                  Row(
                    children: [
                      Icon(categoriaIcon, color: categoriaColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        objeto.categoriaTexto,
                        style: TextStyle(
                          fontSize: 15,
                          color: categoriaColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Fecha encontrado
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Encontrado: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(objeto.fechaEncontrado))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  // Datos de entrega si fue entregado
                  if (objeto.estado == 'entregado' && objeto.entrega != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'DATOS DE ENTREGA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Foto persona si existe
                    if (objeto.entrega!['foto_persona'] != null) ...[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            objeto.entrega!['foto_persona'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _DetailRow(
                      label: 'Nombre',
                      value: objeto.entrega!['nombre_completo'] ?? '-',
                    ),
                    _DetailRow(
                      label: 'Documento',
                      value:
                          '${objeto.entrega!['tipo_documento'] ?? 'CI'}: ${objeto.entrega!['documento_identidad'] ?? '-'}',
                    ),
                    if (objeto.entrega!['telefono'] != null)
                      _DetailRow(
                        label: 'Teléfono',
                        value: objeto.entrega!['telefono'],
                      ),
                    if (objeto.entrega!['email'] != null)
                      _DetailRow(
                        label: 'Email',
                        value: objeto.entrega!['email'],
                      ),
                    if (objeto.entrega!['relacion_objeto'] != null)
                      _DetailRow(
                        label: 'Relación',
                        value: objeto.entrega!['relacion_objeto'],
                      ),
                    _DetailRow(
                      label: 'Fecha entrega',
                      value: DateFormat('dd/MM/yyyy HH:mm').format(
                        DateTime.parse(objeto.entrega!['fecha_entrega']),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Botón cerrar
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
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
          ),
        ],
      ),
    );
  }
}

// Widget de fila de detalle
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Formulario de Objeto (Crear/Editar)
class _FormularioObjeto extends StatefulWidget {
  final ObjetoPerdidoModel? objeto;
  final VoidCallback onSuccess;

  const _FormularioObjeto({
    this.objeto,
    required this.onSuccess,
  });

  @override
  State<_FormularioObjeto> createState() => _FormularioObjetoState();
}

class _FormularioObjetoState extends State<_FormularioObjeto> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  List<LaboratorioModel> _laboratorios = [];

  int? _laboratorioSeleccionado;
  String _categoriaSeleccionada = 'otros';
  DateTime _fechaEncontrado = DateTime.now();

  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get isEditing => widget.objeto != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (isEditing) {
      _loadObjetoData();
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final laboratorios = await LaboratorioService.getAll();

      setState(() {
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

  void _loadObjetoData() {
    _descripcionController.text = widget.objeto!.descripcion;
    _laboratorioSeleccionado = widget.objeto!.laboratorioId;
    _categoriaSeleccionada = widget.objeto!.categoria;
    _fechaEncontrado = DateTime.parse(widget.objeto!.fechaEncontrado);
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
          isEditing ? 'Editar Objeto' : 'Nuevo Objeto',
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
                            Icons.inventory_2,
                            size: 50,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción del Objeto *',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText: 'Describe el objeto encontrado',
                        ),
                        validator: (value) {
                          return ObjetoPerdidoService.validarDatos(
                              descripcion: value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Categoría
                      const Text(
                        'Categoría *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CategoriaChip(
                            label: 'Electrónica',
                            icon: Icons.phone_android,
                            color: const Color(0xFFFF9800),
                            isSelected: _categoriaSeleccionada == 'electronica',
                            onTap: () => setState(
                                () => _categoriaSeleccionada = 'electronica'),
                          ),
                          _CategoriaChip(
                            label: 'Ropa',
                            icon: Icons.checkroom,
                            color: const Color(0xFF9C27B0),
                            isSelected: _categoriaSeleccionada == 'ropa',
                            onTap: () =>
                                setState(() => _categoriaSeleccionada = 'ropa'),
                          ),
                          _CategoriaChip(
                            label: 'Documentos',
                            icon: Icons.description,
                            color: const Color(0xFFF44336),
                            isSelected: _categoriaSeleccionada == 'documentos',
                            onTap: () => setState(
                                () => _categoriaSeleccionada = 'documentos'),
                          ),
                          _CategoriaChip(
                            label: 'Otros',
                            icon: Icons.inbox,
                            color: const Color(0xFF607D8B),
                            isSelected: _categoriaSeleccionada == 'otros',
                            onTap: () =>
                                setState(() => _categoriaSeleccionada = 'otros'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Laboratorio
                      DropdownButtonFormField<int>(
                        value: _laboratorioSeleccionado,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Laboratorio *',
                          prefixIcon: const Icon(Icons.science),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _laboratorios.map<DropdownMenuItem<int>>((lab) {
                          return DropdownMenuItem<int>(
                            value: lab.id,
                            child: Text(lab.nombre, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: isEditing
                            ? null
                            : (value) {
                                setState(() => _laboratorioSeleccionado = value);
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona un laboratorio';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Fecha encontrado
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            'Fecha encontrado: ${DateFormat('dd/MM/yyyy').format(_fechaEncontrado)}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaEncontrado,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (fecha != null) {
                              setState(() => _fechaEncontrado = fecha);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEditing
                                    ? 'Solo puedes editar la descripción y categoría.'
                                    : 'El objeto se registrará en estado "En Custodia".',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
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
                                      : 'REGISTRAR OBJETO',
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
        await ObjetoPerdidoService.update(
          id: widget.objeto!.id,
          descripcion: _descripcionController.text.trim(),
          categoria: _categoriaSeleccionada,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Objeto actualizado exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Crear
        await ObjetoPerdidoService.create(
          descripcion: _descripcionController.text.trim(),
          laboratorioId: _laboratorioSeleccionado!,
          categoria: _categoriaSeleccionada,
          fechaEncontrado: _fechaEncontrado.toIso8601String(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Objeto registrado exitosamente'),
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

// Widget de chip de categoría
class _CategoriaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoriaChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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

// Formulario de Entrega
class _FormularioEntrega extends StatefulWidget {
  final ObjetoPerdidoModel objeto;
  final VoidCallback onSuccess;

  const _FormularioEntrega({
    required this.objeto,
    required this.onSuccess,
  });

  @override
  State<_FormularioEntrega> createState() => _FormularioEntregaState();
}

class _FormularioEntregaState extends State<_FormularioEntrega> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _relacionController = TextEditingController();

  String _tipoDocumento = 'CI';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _relacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Entrega',
          style: TextStyle(color: Colors.white),
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
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info del objeto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Objeto a entregar:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.objeto.descripcion,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'DATOS DE LA PERSONA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),

                const SizedBox(height: 16),

                // Nombre completo
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    return ObjetoPerdidoService.validarDatos(
                        nombreCompleto: value);
                  },
                ),

                const SizedBox(height: 16),

                // Tipo de documento
                DropdownButtonFormField<String>(
                  value: _tipoDocumento,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Documento *',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CI', child: Text('CI')),
                    DropdownMenuItem(
                        value: 'Pasaporte', child: Text('Pasaporte')),
                    DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    setState(() => _tipoDocumento = value!);
                  },
                ),

                const SizedBox(height: 16),

                // Número de documento
                TextFormField(
                  controller: _documentoController,
                  decoration: InputDecoration(
                    labelText: 'Número de Documento *',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    return ObjetoPerdidoService.validarDatos(
                        documentoIdentidad: value);
                  },
                ),

                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Opcional)',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Relación con el objeto
                TextFormField(
                  controller: _relacionController,
                  decoration: InputDecoration(
                    labelText: 'Relación con el objeto (Opcional)',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Ej: Dueño, Familiar, Amigo',
                  ),
                ),

                const SizedBox(height: 24),

                // Info importante
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Al registrar la entrega, el objeto cambiará a estado "Entregado" y no se podrá modificar.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón registrar entrega
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
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
                        : const Text(
                            'REGISTRAR ENTREGA',
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
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Entrega'),
        content: Text(
          '¿Estás seguro de registrar la entrega a ${_nombreController.text.trim()}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      await ObjetoPerdidoService.registrarEntrega(
        id: widget.objeto.id,
        nombreCompleto: _nombreController.text.trim(),
        documentoIdentidad: _documentoController.text.trim(),
        tipoDocumento: _tipoDocumento,
        telefono: _telefonoController.text.trim().isNotEmpty
            ? _telefonoController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        relacionObjeto: _relacionController.text.trim().isNotEmpty
            ? _relacionController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Entrega registrada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
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