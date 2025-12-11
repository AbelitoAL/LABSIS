// lib/screens/reservas/reserva_detalle_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reserva_model.dart';
import '../../services/reserva_service.dart';
import '../../providers/auth_provider.dart';

class ReservaDetalleScreen extends StatefulWidget {
  final int reservaId;

  const ReservaDetalleScreen({
    Key? key,
    required this.reservaId,
  }) : super(key: key);

  @override
  State<ReservaDetalleScreen> createState() => _ReservaDetalleScreenState();
}

class _ReservaDetalleScreenState extends State<ReservaDetalleScreen> {
  ReservaModel? _reserva;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);

    try {
      final reserva = await ReservaService.getById(widget.reservaId);

      setState(() {
        _reserva = reserva;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando detalle: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final esAdmin = user?.rol == 'admin';
    final esDocente = user?.rol == 'docente';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar
                _buildAppBar(),

                // Contenido
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estado
                        _buildEstadoCard(),
                        const SizedBox(height: 16),

                        // Información principal
                        _buildInfoCard(),
                        const SizedBox(height: 16),

                        // Docente
                        if (_reserva!.docenteNombre != null)
                          _buildDocenteCard(),
                        
                        if (_reserva!.docenteNombre != null)
                          const SizedBox(height: 16),

                        // Descripción
                        if (_reserva!.descripcion != null &&
                            _reserva!.descripcion!.isNotEmpty)
                          _buildDescripcionCard(),
                        
                        if (_reserva!.descripcion != null &&
                            _reserva!.descripcion!.isNotEmpty)
                          const SizedBox(height: 16),

                        // Motivo rechazo
                        if (_reserva!.estado == 'rechazada' &&
                            _reserva!.motivoRechazo != null)
                          _buildRechazoCard(),
                        
                        if (_reserva!.estado == 'rechazada' &&
                            _reserva!.motivoRechazo != null)
                          const SizedBox(height: 16),

                        // Información aprobación
                        if (_reserva!.aprobadaPorNombre != null)
                          _buildAprobacionCard(),

                        if (_reserva!.aprobadaPorNombre != null)
                          const SizedBox(height: 16),

                        // Acciones (Admin)
                        if (esAdmin && _reserva!.puedeAprobarRechazar)
                          _buildAccionesAdmin(),

                        // Acciones (Docente)
                        if (esDocente && _reserva!.puedeCancelar)
                          _buildAccionesDocente(),

                        // Botón eliminar (solo admin)
                        if (esAdmin) ...[
                          const SizedBox(height: 16),
                          _buildBotonEliminar(),
                        ],

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
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
      backgroundColor: const Color(0xFF1976D2),
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          'Detalle de Reserva',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(_reserva!.colorEstado),
            Color(_reserva!.colorEstado).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(_reserva!.colorEstado).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _reserva!.emojiEstado,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            _reserva!.textoEstado.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Materia
          Row(
            children: [
              const Icon(
                Icons.school,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reserva!.materia,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Laboratorio
          _buildInfoRow(
            Icons.science,
            'Laboratorio',
            _reserva!.laboratorioNombre ?? 'N/A',
            const Color(0xFF7B1FA2),
          ),
          const SizedBox(height: 16),

          // Ubicación
          if (_reserva!.laboratorioUbicacion != null)
            _buildInfoRow(
              Icons.location_on,
              'Ubicación',
              _reserva!.laboratorioUbicacion!,
              const Color(0xFFFF5722),
            ),
          
          if (_reserva!.laboratorioUbicacion != null)
            const SizedBox(height: 16),

          // Fecha
          _buildInfoRow(
            Icons.calendar_today,
            'Fecha',
            _reserva!.fechaFormateada,
            const Color(0xFF388E3C),
          ),
          const SizedBox(height: 16),

          // Horario
          _buildInfoRow(
            Icons.schedule,
            'Horario',
            _reserva!.horarioFormateado,
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16),

          // Duración
          _buildInfoRow(
            Icons.timelapse,
            'Duración',
            _reserva!.duracionFormateada,
            const Color(0xFF00BCD4),
          ),
        ],
      ),
    );
  }

  Widget _buildDocenteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Icons.person,
                color: Color(0xFF1976D2),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Docente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _reserva!.docenteNombre!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),

          if (_reserva!.docenteEmail != null)
            Text(
              '📧 ${_reserva!.docenteEmail}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

          if (_reserva!.docenteTelefono != null) ...[
            const SizedBox(height: 4),
            Text(
              '📞 ${_reserva!.docenteTelefono}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],

          if (_reserva!.docenteCodigo != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🆔 ${_reserva!.docenteCodigo}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescripcionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Icons.description,
                color: Color(0xFF00BCD4),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _reserva!.descripcion!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechazoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF5350)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel,
                color: Color(0xFFD32F2F),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Motivo del Rechazo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _reserva!.motivoRechazo!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFD32F2F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAprobacionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _reserva!.estado == 'aprobada'
                ? '✅ Aprobada por:'
                : '❌ Rechazada por:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _reserva!.aprobadaPorNombre!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccionesAdmin() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones de Administrador',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _aprobarReserva,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Aprobar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _rechazarReserva,
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Rechazar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesDocente() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _cancelarReserva,
          icon: const Icon(Icons.cancel, size: 20),
          label: const Text('Cancelar Reserva'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E9E9E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonEliminar() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _eliminarReserva,
        icon: const Icon(Icons.delete, size: 20),
        label: const Text('Eliminar Reserva'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD32F2F),
          side: const BorderSide(color: Color(0xFFD32F2F)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _aprobarReserva() async {
    try {
      await ReservaService.aprobar(widget.reservaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva aprobada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rechazarReserva() async {
    final motivo = await _mostrarDialogoRechazo();
    if (motivo == null || motivo.trim().isEmpty) return;

    try {
      await ReservaService.rechazar(widget.reservaId, motivo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _mostrarDialogoRechazo() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Reserva'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo *',
            hintText: 'Ej: El laboratorio no está disponible',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarReserva() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ReservaService.cancelar(widget.reservaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva cancelada'),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarReserva() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta reserva permanentemente?\n\n'
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
      await ReservaService.delete(widget.reservaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva eliminada'),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}