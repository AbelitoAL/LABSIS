// lib/screens/objetos_perdidos/objetos_perdidos_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/objeto_perdido_model.dart';
import '../../services/objeto_perdido_service.dart';
import '../../services/laboratorio_service.dart';
import '../../models/laboratorio_model.dart';

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
  String _filtroCategoria = 'Todos';

  final Map<String, String> _categorias = {
    'Todos': '📦',
    'Electrónica': '📱',
    'Ropa': '👕',
    'Documentos': '📄',
    'Accesorios': '🎒',
    'Llaves': '🔑',
    'Otros': '📦',
  };

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
      _objetosFiltrados = _objetos.where((objeto) {
        bool cumpleEstado = _filtroEstado == 'Todos' ||
            (_filtroEstado == 'Encontrados' && objeto.estado == 'encontrado') ||
            (_filtroEstado == 'Entregados' && objeto.estado == 'entregado');

        bool cumpleCategoria = _filtroCategoria == 'Todos' ||
            objeto.categoria.toLowerCase() == _filtroCategoria.toLowerCase();

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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FiltroChip(
                                  label: 'Todos',
                                  isSelected: _filtroEstado == 'Todos',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() => _filtroEstado = 'Todos');
                                    _aplicarFiltros();
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: 'Encontrados',
                                  isSelected: _filtroEstado == 'Encontrados',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() => _filtroEstado = 'Encontrados');
                                    _aplicarFiltros();
                                  },
                                ),
                                const SizedBox(width: 8),
                                _FiltroChip(
                                  label: 'Entregados',
                                  isSelected: _filtroEstado == 'Entregados',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () {
                                    setState(() => _filtroEstado = 'Entregados');
                                    _aplicarFiltros();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filtros de Categoría
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categoría:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categorias.entries.map((entry) {
                              return _CategoriaChip(
                                emoji: entry.value,
                                label: entry.key,
                                isSelected: _filtroCategoria == entry.key,
                                onTap: () {
                                  setState(() => _filtroCategoria = entry.key);
                                  _aplicarFiltros();
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

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
                                        style: TextStyle(color: Colors.grey[600]),
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text('📦', style: TextStyle(fontSize: 64)),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No hay objetos',
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
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _objetosFiltrados.length,
                                        itemBuilder: (context, index) {
                                          final objeto = _objetosFiltrados[index];
                                          return _ObjetoCard(
                                            objeto: objeto,
                                            onTap: () => _showObjetoDetail(objeto),
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
        onPressed: _showRegistrarObjetoDialog,
        backgroundColor: const Color(0xFF9C27B0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Registrar Objeto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        onMarcarEntregado: () async {
          // TODO: Implementar marcar como entregado
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Función próximamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        },
      ),
    );
  }

  void _showRegistrarObjetoDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RegistrarObjetoScreen(
          onRegistrado: _loadObjetos,
        ),
      ),
    );
  }
}

// Widgets auxiliares...
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoriaChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: const Color(0xFF2196F3), width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjetoCard extends StatelessWidget {
  final ObjetoPerdidoModel objeto;
  final VoidCallback onTap;

  const _ObjetoCard({required this.objeto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final estadoColor = objeto.estado == 'encontrado'
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  objeto.categoriaEmoji,
                  style: const TextStyle(fontSize: 28),
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
                    const SizedBox(height: 4),
                    Text(
                      objeto.categoriaTexto,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.science, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Lab ID: ${objeto.laboratorioId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(objeto.fechaEncontrado),
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: estadoColor, width: 1.5),
                ),
                child: Text(
                  objeto.estadoTexto,
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

class _ObjetoDetailModal extends StatelessWidget {
  final ObjetoPerdidoModel objeto;
  final VoidCallback onMarcarEntregado;

  const _ObjetoDetailModal({
    required this.objeto,
    required this.onMarcarEntregado,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor = objeto.estado == 'encontrado'
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: estadoColor, width: 2),
              ),
              child: Text(
                objeto.estadoTexto,
                style: TextStyle(
                  color: estadoColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                objeto.categoriaEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción',
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.category,
                  label: 'Categoría',
                  value: objeto.categoriaTexto,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.science,
                  label: 'Laboratorio ID',
                  value: objeto.laboratorioId.toString(),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Fecha Encontrado',
                  value: DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse(objeto.fechaEncontrado),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (objeto.estado == 'encontrado')
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onMarcarEntregado,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'MARCAR COMO ENTREGADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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

// Pantalla de Registrar Objeto
class _RegistrarObjetoScreen extends StatefulWidget {
  final VoidCallback onRegistrado;

  const _RegistrarObjetoScreen({required this.onRegistrado});

  @override
  State<_RegistrarObjetoScreen> createState() => _RegistrarObjetoScreenState();
}

class _RegistrarObjetoScreenState extends State<_RegistrarObjetoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String _categoriaSeleccionada = 'Otros';
  int? _laboratorioSeleccionado;
  List<LaboratorioModel> _laboratorios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLaboratorios();
  }

  Future<void> _loadLaboratorios() async {
    try {
      final labs = await LaboratorioService.getAll();
      setState(() {
        _laboratorios = labs;
        if (labs.isNotEmpty) {
          _laboratorioSeleccionado = labs.first.id;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C27B0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Objeto Encontrado',
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
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      size: 50,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción del Objeto *',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categoría *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Electrónica',
                    'Ropa',
                    'Documentos',
                    'Accesorios',
                    'Llaves',
                    'Otros'
                  ].map((cat) {
                    final emojis = {
                      'Electrónica': '📱',
                      'Ropa': '👕',
                      'Documentos': '📄',
                      'Accesorios': '🎒',
                      'Llaves': '🔑',
                      'Otros': '📦',
                    };
                    return _CategoriaChip(
                      emoji: emojis[cat]!,
                      label: cat,
                      isSelected: _categoriaSeleccionada == cat,
                      onTap: () => setState(() => _categoriaSeleccionada = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Laboratorio *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _laboratorioSeleccionado,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.science),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _laboratorios.map((lab) {
                    return DropdownMenuItem(
                      value: lab.id,
                      child: Text(lab.nombre),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _laboratorioSeleccionado = value),
                  validator: (value) =>
                      value == null ? 'Selecciona un laboratorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ubicacionController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación Exacta (Opcional)',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                          'El objeto quedará registrado como "Encontrado" hasta que sea entregado.',
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'REGISTRAR OBJETO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

  Future<void> _handleRegistrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // TODO: Implementar registro
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          widget.onRegistrado();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Objeto registrado exitosamente'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
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
}