// lib/screens/reservas/reservas_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reserva_model.dart';
import '../../services/reserva_service.dart';
import '../../providers/auth_provider.dart';
import 'reserva_form_screen.dart';
import 'reserva_detalle_screen.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  List<ReservaModel> _reservas = [];
  List<ReservaModel> _reservasFiltradas = [];
  bool _isLoading = true;
  String _filtroEstado = 'todas';
  String _filtroFecha = 'todas';
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() => _isLoading = true);

    try {
      final reservas = await ReservaService.getAll();

      setState(() {
        _reservas = reservas;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando reservas: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _aplicarFiltros() {
    var resultado = List<ReservaModel>.from(_reservas);

    // Filtrar por estado
    if (_filtroEstado != 'todas') {
      resultado = ReservaService.filtrarPorEstado(resultado, _filtroEstado);
    }

    // Filtrar por fecha (solo para auxiliares)
    if (_filtroFecha != 'todas') {
      resultado = ReservaService.filtrarPorFecha(resultado, _filtroFecha);
    }

    // Búsqueda por texto
    if (_busqueda.isNotEmpty) {
      final busquedaLower = _busqueda.toLowerCase();
      resultado = resultado.where((r) {
        return r.materia.toLowerCase().contains(busquedaLower) ||
            (r.docenteNombre?.toLowerCase().contains(busquedaLower) ?? false) ||
            (r.laboratorioNombre?.toLowerCase().contains(busquedaLower) ?? false);
      }).toList();
    }

    // Ordenar por fecha descendente
    resultado.sort((a, b) => b.fecha.compareTo(a.fecha));

    setState(() {
      _reservasFiltradas = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final esAdmin = user?.rol == 'admin';
    final esDocente = user?.rol == 'docente';
    final esAuxiliar = user?.rol == 'auxiliar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '📅 Reservas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarReservas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Búsqueda
                TextField(
                  onChanged: (valor) {
                    setState(() {
                      _busqueda = valor;
                      _aplicarFiltros();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por materia, docente o laboratorio...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filtros
                Row(
                  children: [
                    // Filtro de estado
                    Expanded(
                      child: _buildFiltroEstado(),
                    ),
                    
                    // Filtro de fecha (solo para auxiliares)
                    if (esAuxiliar) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFiltroFecha(),
                      ),
                    ],
                  ],
                ),

                // Contador
                const SizedBox(height: 8),
                Text(
                  '${_reservasFiltradas.length} reserva(s) encontrada(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Lista de reservas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reservasFiltradas.isEmpty
                    ? _buildEstadoVacio(esDocente)
                    : RefreshIndicator(
                        onRefresh: _cargarReservas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reservasFiltradas.length,
                          itemBuilder: (context, index) {
                            final reserva = _reservasFiltradas[index];
                            return _buildReservaCard(
                              reserva,
                              esAdmin,
                              esDocente,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: esDocente
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReservaFormScreen(),
                  ),
                ).then((creada) {
                  if (creada == true) {
                    _cargarReservas();
                  }
                });
              },
              backgroundColor: const Color(0xFF1976D2),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Reserva'),
            )
          : null,
    );
  }

  Widget _buildFiltroEstado() {
    return DropdownButtonFormField<String>(
      value: _filtroEstado,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        isDense: true,
      ),
      items: ReservaService.estados.map((estado) {
        return DropdownMenuItem<String>(
          value: estado['valor'],
          child: Text(
            '${estado['emoji']} ${estado['texto']}',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (valor) {
        setState(() {
          _filtroEstado = valor!;
          _aplicarFiltros();
        });
      },
    );
  }

  Widget _buildFiltroFecha() {
    return DropdownButtonFormField<String>(
      value: _filtroFecha,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        isDense: true,
      ),
      items: ReservaService.filtrosFecha.map((filtro) {
        return DropdownMenuItem<String>(
          value: filtro['valor'],
          child: Text(
            '${filtro['emoji']} ${filtro['texto']}',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (valor) {
        setState(() {
          _filtroFecha = valor!;
          _aplicarFiltros();
        });
      },
    );
  }

  Widget _buildReservaCard(
    ReservaModel reserva,
    bool esAdmin,
    bool esDocente,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReservaDetalleScreen(reservaId: reserva.id),
            ),
          ).then((actualizado) {
            if (actualizado == true) {
              _cargarReservas();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Materia y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reserva.materia,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(reserva.colorEstado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${reserva.emojiEstado} ${reserva.textoEstado}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(reserva.colorEstado),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información
              _buildInfoRow(
                Icons.science,
                reserva.laboratorioNombre ?? 'N/A',
                const Color(0xFF7B1FA2),
              ),
              const SizedBox(height: 6),
              
              if (reserva.docenteNombre != null)
                _buildInfoRow(
                  Icons.person,
                  reserva.docenteNombre!,
                  const Color(0xFF1976D2),
                ),
              
              if (reserva.docenteNombre != null)
                const SizedBox(height: 6),
              
              _buildInfoRow(
                Icons.calendar_today,
                reserva.fechaFormateada,
                const Color(0xFF388E3C),
              ),
              const SizedBox(height: 6),
              
              _buildInfoRow(
                Icons.schedule,
                '${reserva.horarioFormateado} (${reserva.duracionFormateada})',
                const Color(0xFFFF9800),
              ),

              // Botones de acción (solo admin)
              if (esAdmin && reserva.puedeAprobarRechazar) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _aprobarReserva(reserva.id),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F5E9),
                          foregroundColor: const Color(0xFF388E3C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rechazarReserva(reserva.id),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Rechazar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEBEE),
                          foregroundColor: const Color(0xFFD32F2F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Botón cancelar (solo docente y pendientes)
              if (esDocente && reserva.puedeCancelar) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelarReserva(reserva.id),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancelar Reserva'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9E9E9E),
                      side: const BorderSide(color: Color(0xFF9E9E9E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String texto, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVacio(bool esDocente) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📅',
            style: TextStyle(fontSize: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          Text(
            esDocente
                ? 'No tienes reservas'
                : 'No hay reservas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (esDocente)
            Text(
              'Crea tu primera reserva usando el botón (+)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Future<void> _aprobarReserva(int reservaId) async {
    try {
      await ReservaService.aprobar(reservaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva aprobada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarReservas();
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

  Future<void> _rechazarReserva(int reservaId) async {
    final motivo = await _mostrarDialogoRechazo();
    if (motivo == null || motivo.trim().isEmpty) return;

    try {
      await ReservaService.rechazar(reservaId, motivo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
        _cargarReservas();
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

  Future<void> _cancelarReserva(int reservaId) async {
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
      await ReservaService.cancelar(reservaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva cancelada'),
            backgroundColor: Colors.grey,
          ),
        );
        _cargarReservas();
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