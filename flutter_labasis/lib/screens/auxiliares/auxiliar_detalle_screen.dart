// lib/screens/auxiliares/auxiliar_detalle_screen.dart

import 'package:flutter/material.dart';
import '../../models/auxiliar_model.dart';
import '../../services/auxiliar_service.dart';
import 'auxiliar_form_screen.dart';

class AuxiliarDetalleScreen extends StatefulWidget {
  final int auxiliarId;

  const AuxiliarDetalleScreen({
    Key? key,
    required this.auxiliarId,
  }) : super(key: key);

  @override
  State<AuxiliarDetalleScreen> createState() => _AuxiliarDetalleScreenState();
}

class _AuxiliarDetalleScreenState extends State<AuxiliarDetalleScreen> {
  AuxiliarDetalleModel? _detalle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);

    try {
      final detalle = await AuxiliarService.getById(widget.auxiliarId);
      
      setState(() {
        _detalle = detalle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando detalle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar
                _buildAppBar(),

                // Avatar y nombre
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Estadísticas
                SliverToBoxAdapter(
                  child: _buildEstadisticas(),
                ),

                // Laboratorios asignados
                SliverToBoxAdapter(
                  child: _buildLaboratorios(),
                ),

                // Horarios
                SliverToBoxAdapter(
                  child: _buildHorarios(),
                ),

                // Información adicional
                if (_detalle!.auxiliar.notas != null)
                  SliverToBoxAdapter(
                    child: _buildNotas(),
                  ),

                // Botones de acción
                SliverToBoxAdapter(
                  child: _buildAcciones(),
                ),

                // Espaciado inferior
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFFF6B6B),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Detalle del Auxiliar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final auxiliar = _detalle!.auxiliar;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFC92A2A)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                auxiliar.iniciales,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre
          Text(
            auxiliar.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            auxiliar.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Teléfono
          if (auxiliar.telefono != null)
            Text(
              '📞 ${auxiliar.telefono}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 12),

          // Badge de estado
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Color(auxiliar.colorEstado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${auxiliar.emojiEstado} ${auxiliar.textoEstado}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(auxiliar.colorEstado),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    final stats = _detalle!.estadisticas;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Laboratorios',
              '${stats.cantidadLaboratorios}',
              const Color(0xFF7B1FA2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Horas/Semana',
              '${stats.horasSemanales.toStringAsFixed(1)}',
              const Color(0xFF388E3C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLaboratorios() {
    final laboratorios = _detalle!.laboratorios;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              const Icon(
                Icons.science,
                color: Color(0xFF7B1FA2),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Laboratorios Asignados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Text(
                '${laboratorios.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (laboratorios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Sin laboratorios asignados',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: laboratorios.map((lab) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lab.emoji} ${lab.nombre}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7B1FA2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHorarios() {
    final horarios = _detalle!.horarios;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              const Icon(
                Icons.schedule,
                color: Color(0xFF388E3C),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Horarios de Trabajo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Text(
                '${horarios.length} días',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (horarios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Sin horarios asignados',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...horarios.map((horario) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        horario.diaSemanaCapitalizado,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        horario.tiempoFormateado,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildNotas() {
    final notas = _detalle!.auxiliar.notas!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              const Icon(
                Icons.notes,
                color: Color(0xFFFF9800),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Notas Adicionales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notas,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _editarAuxiliar,
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE3F2FD),
                foregroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _eliminarAuxiliar,
              icon: const Icon(Icons.delete, size: 20),
              label: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
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

  void _editarAuxiliar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuxiliarFormScreen(
          auxiliar: _detalle!.auxiliar,
        ),
      ),
    ).then((actualizado) {
      if (actualizado == true) {
        _cargarDetalle();
      }
    });
  }

  Future<void> _eliminarAuxiliar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Auxiliar'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${_detalle!.auxiliar.nombre}?\n\n'
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
      await AuxiliarService.delete(widget.auxiliarId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Auxiliar eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando auxiliar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}