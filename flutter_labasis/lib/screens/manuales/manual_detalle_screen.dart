// lib/screens/manuales/manual_detalle_screen.dart

import 'package:flutter/material.dart';
import '../../models/manual_model.dart';
import '../../models/user_model.dart';
import '../../services/manual_service.dart';
import '../../services/auth_service.dart';
import 'manual_form_screen.dart';

class ManualDetalleScreen extends StatefulWidget {
  final int laboratorioId;

  const ManualDetalleScreen({
    Key? key,
    required this.laboratorioId,
  }) : super(key: key);

  @override
  State<ManualDetalleScreen> createState() => _ManualDetalleScreenState();
}

class _ManualDetalleScreenState extends State<ManualDetalleScreen> {
  ManualDetalleModel? _detalle;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Obtener usuario actual desde AuthService
      final user = await AuthService.getCurrentUser();
      
      // Obtener manual del laboratorio
      final detalle = await ManualService.getByLaboratorioId(widget.laboratorioId);
      
      setState(() {
        _currentUser = user;
        _detalle = detalle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando manual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarManual() async {
    // Confirmar eliminación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Manual'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este manual?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ManualService.delete(widget.laboratorioId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Manual eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando manual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentUser?.rol == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF667EEA),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      children: [
                        Text(
                          _detalle!.laboratorio.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _detalle!.laboratorio.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  ),
                  actions: [
                    // Badge de rol
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? Colors.white.withOpacity(0.2)
                            : Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAdmin ? '👑 ADMIN' : '👤 AUXILIAR',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Código del laboratorio
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF667EEA),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _detalle!.laboratorio.codigo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        if (_detalle!.laboratorio.ubicacion != null) ...[
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _detalle!.laboratorio.ubicacion!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667EEA),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Título de sección
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        const Text(
                          '📋 Información del Laboratorio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (_detalle!.items.isNotEmpty)
                          Text(
                            '${_detalle!.items.length} items',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Lista de items o estado vacío
                _detalle!.items.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyState(isAdmin),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _detalle!.items[index];
                            return _buildItemCard(item, index, isAdmin);
                          },
                          childCount: _detalle!.items.length,
                        ),
                      ),

                // Espaciado inferior
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),

      // FAB solo para admin
      floatingActionButton: !_isLoading && isAdmin
          ? _buildAdminFAB()
          : null,
    );
  }

  Widget _buildItemCard(ManualItemModel item, int index, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono según el título
              Text(
                ManualService.getIconoParaTitulo(item.titulo),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),

              // Título
              Expanded(
                child: Text(
                  item.titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),

              // Botones de admin
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón editar
                    InkWell(
                      onTap: () => _editarManual(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Botón eliminar
                    InkWell(
                      onTap: () => _eliminarManual(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Descripción
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '📝',
            style: TextStyle(
              fontSize: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAdmin
                ? 'No hay información agregada'
                : 'Este laboratorio aún no tiene manual',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (isAdmin) ...[
            const SizedBox(height: 8),
            Text(
              'Agrega información con el botón +',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminFAB() {
    return FloatingActionButton(
      onPressed: _detalle!.items.isEmpty ? _crearManual : _editarManual,
      backgroundColor: const Color(0xFF667EEA),
      child: Icon(
        _detalle!.items.isEmpty ? Icons.add : Icons.edit,
        color: Colors.white,
      ),
    );
  }

  void _crearManual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFormScreen(
          laboratorioId: widget.laboratorioId,
          laboratorioNombre: _detalle!.laboratorio.nombre,
          itemsExistentes: const [],
        ),
      ),
    ).then((actualizado) {
      if (actualizado == true) {
        _cargarDatos();
      }
    });
  }

  void _editarManual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFormScreen(
          laboratorioId: widget.laboratorioId,
          laboratorioNombre: _detalle!.laboratorio.nombre,
          itemsExistentes: _detalle!.items,
        ),
      ),
    ).then((actualizado) {
      if (actualizado == true) {
        _cargarDatos();
      }
    });
  }
}