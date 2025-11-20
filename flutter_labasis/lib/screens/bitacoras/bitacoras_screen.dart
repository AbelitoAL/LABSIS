// lib/screens/bitacoras/bitacoras_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bitacora_model.dart';
import '../../models/laboratorio_model.dart';
import '../../services/bitacora_service.dart';
import '../../services/laboratorio_service.dart';

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
        return const Color(0xFFFF9800);
      case 'completada':
        return const Color(0xFF4CAF50);
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
                                            onEdit: bitacora.estado == 'borrador'
                                                ? () => _showEditDialog(bitacora)
                                                : null,
                                            onDelete: () =>
                                                _confirmDelete(bitacora),
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
        backgroundColor: const Color(0xFF4CAF50),
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
      builder: (context) => _BitacoraDetailModal(
        bitacora: bitacora,
        estadoColor: _getEstadoColor(bitacora.estado),
        estadoTexto: _getEstadoTexto(bitacora.estado),
        onCompletar: bitacora.estado == 'borrador'
            ? () async {
                Navigator.pop(context);
                await _completarBitacora(bitacora.id);
              }
            : null,
      ),
    );
  }

  void _showCreateDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioBitacora(
          onSuccess: _loadBitacoras,
        ),
      ),
    );
  }

  void _showEditDialog(BitacoraModel bitacora) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FormularioBitacora(
          bitacora: bitacora,
          onSuccess: _loadBitacoras,
        ),
      ),
    );
  }

  void _confirmDelete(BitacoraModel bitacora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Bitácora'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${bitacora.nombre}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBitacora(bitacora.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBitacora(int id) async {
    try {
      await BitacoraService.delete(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Bitácora eliminada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadBitacoras();
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

  Future<void> _completarBitacora(int id) async {
    try {
      await BitacoraService.completar(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Bitácora completada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadBitacoras();
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

// Widget de tarjeta de bitácora
class _BitacoraCard extends StatelessWidget {
  final BitacoraModel bitacora;
  final Color estadoColor;
  final String estadoTexto;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _BitacoraCard({
    required this.bitacora,
    required this.estadoColor,
    required this.estadoTexto,
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
                      'Lab ID: ${bitacora.laboratorioId} • ${bitacora.turnoTexto}',
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

              // Badge de estado y menú
              Column(
                children: [
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
                  if (onEdit != null || onDelete != null)
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
class _BitacoraDetailModal extends StatelessWidget {
  final BitacoraModel bitacora;
  final Color estadoColor;
  final String estadoTexto;
  final VoidCallback? onCompletar;

  const _BitacoraDetailModal({
    required this.bitacora,
    required this.estadoColor,
    required this.estadoTexto,
    this.onCompletar,
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
                    value: bitacora.turnoTexto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
              if (onCompletar != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCompletar,
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

// Widget de detalle item
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

// Pantalla de formulario (Crear/Editar)
class _FormularioBitacora extends StatefulWidget {
  final BitacoraModel? bitacora;
  final VoidCallback onSuccess;

  const _FormularioBitacora({
    this.bitacora,
    required this.onSuccess,
  });

  @override
  State<_FormularioBitacora> createState() => _FormularioBitacoraState();
}

class _FormularioBitacoraState extends State<_FormularioBitacora> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  List<LaboratorioModel> _laboratorios = [];

  int? _laboratorioSeleccionado;
  String _turnoSeleccionado = 'mañana';
  DateTime _fechaSeleccionada = DateTime.now();

  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get isEditing => widget.bitacora != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (isEditing) {
      _loadBitacoraData();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
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

  void _loadBitacoraData() {
    _nombreController.text = widget.bitacora!.nombre;
    _laboratorioSeleccionado = widget.bitacora!.laboratorioId;
    _turnoSeleccionado = widget.bitacora!.turno;
    _fechaSeleccionada = DateTime.parse(widget.bitacora!.fecha);
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
        title: Text(
          isEditing ? 'Editar Bitácora' : 'Nueva Bitácora',
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description,
                            size: 50,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Bitácora *',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          return BitacoraService.validarDatos(nombre: value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Laboratorio
                      DropdownButtonFormField<int>(
                        value: _laboratorioSeleccionado,
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
                            child: Text(lab.nombre),
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

                      // Turno
                      const Text(
                        'Turno *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TurnoChip(
                              label: 'Mañana',
                              icon: Icons.wb_sunny,
                              color: const Color(0xFFFF9800),
                              isSelected: _turnoSeleccionado == 'mañana',
                              onTap: () =>
                                  setState(() => _turnoSeleccionado = 'mañana'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TurnoChip(
                              label: 'Tarde',
                              icon: Icons.wb_twilight,
                              color: const Color(0xFFFF5722),
                              isSelected: _turnoSeleccionado == 'tarde',
                              onTap: () =>
                                  setState(() => _turnoSeleccionado = 'tarde'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TurnoChip(
                              label: 'Noche',
                              icon: Icons.nights_stay,
                              color: const Color(0xFF3F51B5),
                              isSelected: _turnoSeleccionado == 'noche',
                              onTap: () =>
                                  setState(() => _turnoSeleccionado = 'noche'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Fecha
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaSeleccionada,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (fecha != null) {
                              setState(() => _fechaSeleccionada = fecha);
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
                                    ? 'Solo puedes editar el nombre mientras esté en borrador.'
                                    : 'La bitácora se creará como borrador.',
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
                              : Text(
                                  isEditing
                                      ? 'GUARDAR CAMBIOS'
                                      : 'CREAR BITÁCORA',
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
        // Actualizar solo nombre
        await BitacoraService.update(
          id: widget.bitacora!.id,
          nombre: _nombreController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Bitácora actualizada exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        // Crear
        await BitacoraService.create(
          nombre: _nombreController.text.trim(),
          laboratorioId: _laboratorioSeleccionado!,
          turno: _turnoSeleccionado,
          fecha: _fechaSeleccionada.toIso8601String(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Bitácora creada exitosamente'),
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

// Widget de chip de turno
class _TurnoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TurnoChip({
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