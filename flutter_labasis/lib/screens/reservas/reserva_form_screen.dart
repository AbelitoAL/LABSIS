// lib/screens/reservas/reserva_form_screen.dart

import 'package:flutter/material.dart';
import '../../models/reserva_model.dart';
import '../../models/laboratorio_model.dart';
import '../../services/reserva_service.dart';
import '../../services/laboratorio_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class ReservaFormScreen extends StatefulWidget {
  const ReservaFormScreen({Key? key}) : super(key: key);

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _cargandoLabs = true;

  List<LaboratorioModel> _laboratorios = [];
  int? _laboratorioSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  final _materiaController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarLaboratorios();
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarLaboratorios() async {
    try {
      print('🔍 Cargando laboratorios...');
      
      // Debug: obtener token
      final token = await AuthService.getToken();
      print('🔑 Token presente: ${token != null}');
      
      // Debug: hacer la petición directamente
      final response = await ApiService.get(
        ApiConfig.laboratoriosEndpoint,
        token: token!,
      );
      print('📦 Respuesta del backend:');
      print('  - success: ${response['success']}');
      print('  - data type: ${response['data'].runtimeType}');
      print('  - data length: ${response['data'] is List ? (response['data'] as List).length : 'N/A'}');
      
      if (response['data'] is List && (response['data'] as List).isNotEmpty) {
        print('📋 Primer laboratorio:');
        print(response['data'][0]);
      }
      
      // Ahora usar el servicio normal
      final labs = await LaboratorioService.getAll();
      print('✅ Laboratorios cargados: ${labs.length}');
      
      for (var lab in labs) {
        print('  - ${lab.nombre} (ID: ${lab.id}, Estado: ${lab.estado})');
      }

      // Filtrar solo activos en el cliente
      final labsActivos = labs.where((lab) => lab.estado.toLowerCase() == 'activo').toList();
      print('✅ Laboratorios activos: ${labsActivos.length}');

      setState(() {
        _laboratorios = labsActivos;
        _cargandoLabs = false;
      });

      if (labsActivos.isEmpty) {
        print('⚠️ No se encontraron laboratorios activos');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                labs.isEmpty
                    ? 'No hay laboratorios creados'
                    : 'No hay laboratorios activos (${labs.length} en otros estados)',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error cargando laboratorios: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      setState(() => _cargandoLabs = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando laboratorios: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final manana = ahora.add(const Duration(days: 1));

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? manana,
      firstDate: manana,
      lastDate: ahora.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaInicio = hora;
        // Si hay hora fin y es menor, resetearla
        if (_horaFin != null) {
          final inicioMinutos = hora.hour * 60 + hora.minute;
          final finMinutos = _horaFin!.hour * 60 + _horaFin!.minute;
          if (finMinutos <= inicioMinutos) {
            _horaFin = null;
          }
        }
      });
    }
  }

  Future<void> _seleccionarHoraFin() async {
    if (_horaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona la hora de inicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: _horaFin ?? TimeOfDay(
        hour: (_horaInicio!.hour + 1) % 24,
        minute: _horaInicio!.minute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      // Validar que sea mayor a hora inicio
      final inicioMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute;
      final finMinutos = hora.hour * 60 + hora.minute;

      if (finMinutos <= inicioMinutos) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La hora de fin debe ser mayor a la hora de inicio'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _horaFin = hora;
      });
    }
  }

  String? _calcularDuracion() {
    if (_horaInicio == null || _horaFin == null) return null;

    final inicioMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute;
    final finMinutos = _horaFin!.hour * 60 + _horaFin!.minute;
    final duracionMinutos = finMinutos - inicioMinutos;

    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;

    if (horas > 0 && minutos > 0) {
      return '$horas h $minutos min';
    } else if (horas > 0) {
      return '$horas h';
    } else {
      return '$minutos min';
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    return '${dias[fecha.weekday - 1]}, ${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Nueva Reserva',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _cargandoLabs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header decorativo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '📅',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Reserva de Laboratorio',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completa los datos para reservar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Formulario
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Laboratorio
                          _buildSeccionTitulo('Laboratorio'),
                          _buildCampoDropdown(),
                          const SizedBox(height: 20),

                          // Fecha
                          _buildSeccionTitulo('Fecha'),
                          _buildCampoFecha(),
                          const SizedBox(height: 20),

                          // Horario
                          _buildSeccionTitulo('Horario'),
                          Row(
                            children: [
                              Expanded(child: _buildCampoHoraInicio()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCampoHoraFin()),
                            ],
                          ),
                          if (_calcularDuracion() != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF1976D2),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Duración: ${_calcularDuracion()}',
                                    style: const TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Materia
                          _buildSeccionTitulo('Materia'),
                          _buildCampoMateria(),
                          const SizedBox(height: 20),

                          // Descripción
                          _buildSeccionTitulo('Descripción (opcional)'),
                          _buildCampoDescripcion(),
                          const SizedBox(height: 24),

                          // Nota informativa
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFF57C00),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tu reserva será revisada por un administrador antes de ser aprobada.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botones
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _guardar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Crear Reserva',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildCampoDropdown() {
    if (_laboratorios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFC107)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Color(0xFFF57C00),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay laboratorios activos disponibles. Contacta al administrador.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: _laboratorioSeleccionado,
      decoration: InputDecoration(
        hintText: 'Selecciona un laboratorio',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: _laboratorios.map((lab) {
        return DropdownMenuItem<int>(
          value: lab.id,
          child: Text(
            '🧪 ${lab.nombre}',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (valor) {
        setState(() {
          _laboratorioSeleccionado = valor;
        });
      },
      validator: (valor) {
        if (valor == null) {
          return 'Debes seleccionar un laboratorio';
        }
        return null;
      },
    );
  }

  Widget _buildCampoFecha() {
    return InkWell(
      onTap: _seleccionarFecha,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fechaSeleccionada != null
                    ? _formatearFecha(_fechaSeleccionada!)
                    : 'Selecciona una fecha',
                style: TextStyle(
                  fontSize: 14,
                  color: _fechaSeleccionada != null
                      ? Colors.black87
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoHoraInicio() {
    return InkWell(
      onTap: _seleccionarHoraInicio,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1976D2), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _horaInicio != null
                    ? _horaInicio!.format(context)
                    : 'Inicio',
                style: TextStyle(
                  fontSize: 14,
                  color: _horaInicio != null ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoHoraFin() {
    return InkWell(
      onTap: _seleccionarHoraFin,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1976D2), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _horaFin != null ? _horaFin!.format(context) : 'Fin',
                style: TextStyle(
                  fontSize: 14,
                  color: _horaFin != null ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoMateria() {
    return TextFormField(
      controller: _materiaController,
      decoration: InputDecoration(
        hintText: 'Ej: Programación I',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'La materia es requerida';
        }
        if (valor.length < 3) {
          return 'La materia debe tener al menos 3 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCampoDescripcion() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        hintText: 'Agrega detalles sobre la reserva (opcional)',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      maxLines: 3,
    );
  }

  Future<void> _guardar() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    // Validar campos adicionales
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una fecha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_horaInicio == null || _horaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar el horario completo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final form = ReservaFormModel(
        laboratorioId: _laboratorioSeleccionado!,
        fecha: ReservaService.formatearFechaParaAPI(_fechaSeleccionada!),
        horaInicio: ReservaService.formatearHoraParaAPI(_horaInicio!),
        horaFin: ReservaService.formatearHoraParaAPI(_horaFin!),
        materia: _materiaController.text.trim(),
        descripcion: _descripcionController.text.trim().isNotEmpty
            ? _descripcionController.text.trim()
            : null,
      );

      await ReservaService.create(form);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva creada exitosamente. Espera la aprobación.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
