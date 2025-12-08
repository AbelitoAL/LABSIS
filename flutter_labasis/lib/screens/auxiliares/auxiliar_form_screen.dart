// lib/screens/auxiliares/auxiliar_form_screen.dart

import 'package:flutter/material.dart';
import '../../models/auxiliar_model.dart';
import '../../models/laboratorio_model.dart';
import '../../services/auxiliar_service.dart';
import '../../services/laboratorio_service.dart';

class AuxiliarFormScreen extends StatefulWidget {
  final AuxiliarModel? auxiliar;

  const AuxiliarFormScreen({
    Key? key,
    this.auxiliar,
  }) : super(key: key);

  @override
  State<AuxiliarFormScreen> createState() => _AuxiliarFormScreenState();
}

class _AuxiliarFormScreenState extends State<AuxiliarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controladores
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notasController = TextEditingController();

  // Valores
  String _estado = 'activo';
  List<int> _laboratoriosSeleccionados = [];
  List<HorarioTemp> _horarios = [];

  // Datos
  List<LaboratorioModel> _laboratorios = [];
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _esEdicion => widget.auxiliar != null;

  @override
  void initState() {
    super.initState();
    _cargarLaboratorios();
    
    if (_esEdicion) {
      _cargarDatosExistentes();
    }
  }

  void _cargarDatosExistentes() {
    final aux = widget.auxiliar!;
    _nombreController.text = aux.nombre;
    _emailController.text = aux.email;
    _telefonoController.text = aux.telefono ?? '';
    _notasController.text = aux.notas ?? '';
    _estado = aux.estado;
    _laboratoriosSeleccionados = aux.laboratorios.map((l) => l.id).toList();
    _horarios = aux.horarios.map((h) => HorarioTemp(
      diaSemana: h.diaSemana,
      horaInicio: h.horaInicio,
      horaFin: h.horaFin,
    )).toList();
  }

  Future<void> _cargarLaboratorios() async {
    try {
      final labs = await LaboratorioService.getAll();
      setState(() => _laboratorios = labs);
    } catch (e) {
      print('Error cargando laboratorios: $e');
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Auxiliar' : 'Nuevo Auxiliar',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        actions: [
          if (_currentPage > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de pasos
          _buildStepIndicator(),

          // Contenido
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildPaginaDatosPersonales(),
                _buildPaginaLaboratorios(),
                _buildPaginaHorarios(),
              ],
            ),
          ),

          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B6B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          _buildStep(0, 'Datos', Icons.person),
          _buildStepConnector(0),
          _buildStep(1, 'Labs', Icons.science),
          _buildStepConnector(1),
          _buildStep(2, 'Horarios', Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, IconData icon) {
    final isActive = step == _currentPage;
    final isCompleted = step < _currentPage;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted
                  ? const Color(0xFFFF6B6B)
                  : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentPage;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? Colors.white
            : Colors.white.withOpacity(0.3),
      ),
    );
  }

  // ==========================================
  // PÁGINA 1: DATOS PERSONALES
  // ==========================================
  Widget _buildPaginaDatosPersonales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo *',
                hintText: 'Ej: María García López',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'auxiliar@labasis.com',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es requerido';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password (solo en creación o si se quiere cambiar)
            if (!_esEdicion || _passwordController.text.isNotEmpty)
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _esEdicion ? 'Nueva Contraseña (opcional)' : 'Contraseña *',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                  ),
                ),
                validator: (value) {
                  if (!_esEdicion && (value == null || value.isEmpty)) {
                    return 'La contraseña es requerida';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
            if (!_esEdicion || _passwordController.text.isNotEmpty)
              const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                hintText: '+591 70123456',
                prefixIcon: const Icon(Icons.phone),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estado
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: InputDecoration(
                labelText: 'Estado *',
                prefixIcon: const Icon(Icons.info),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
              ),
              items: AuxiliarService.estados.map((estado) {
                return DropdownMenuItem(
                  value: estado['valor'],
                  child: Text('${estado['emoji']} ${estado['texto']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _estado = value!);
              },
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notasController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas Adicionales',
                hintText: 'Información adicional sobre el auxiliar...',
                prefixIcon: const Icon(Icons.notes),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PÁGINA 2: LABORATORIOS
  // ==========================================
  Widget _buildPaginaLaboratorios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 Laboratorios Asignados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona los laboratorios que manejará este auxiliar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          if (_laboratorios.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ..._laboratorios.map((lab) {
              final isSelected = _laboratoriosSeleccionados.contains(lab.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _laboratoriosSeleccionados.remove(lab.id);
                    } else {
                      _laboratoriosSeleccionados.add(lab.id);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7B1FA2)
                          : const Color(0xFFE0E0E0),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7B1FA2).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF7B1FA2)
                              : const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _getLabEmoji(lab.nombre),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lab.nombre,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            if (lab.ubicacion != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                lab.ubicacion!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? const Color(0xFF7B1FA2)
                            : Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

          if (_laboratoriosSeleccionados.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF7B1FA2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_laboratoriosSeleccionados.length} laboratorio${_laboratoriosSeleccionados.length != 1 ? 's' : ''} seleccionado${_laboratoriosSeleccionados.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLabEmoji(String nombre) {
    final nombreLower = nombre.toLowerCase();
    
    if (nombreLower.contains('química') || nombreLower.contains('quimica')) {
      return '🧪';
    } else if (nombreLower.contains('computación') || nombreLower.contains('computacion')) {
      return '💻';
    } else if (nombreLower.contains('física') || nombreLower.contains('fisica')) {
      return '⚡';
    } else if (nombreLower.contains('biología') || nombreLower.contains('biologia')) {
      return '🔬';
    } else if (nombreLower.contains('electrónica') || nombreLower.contains('electronica')) {
      return '🔌';
    } else if (nombreLower.contains('mecánica') || nombreLower.contains('mecanica')) {
      return '⚙️';
    }
    return '🏢';
  }

  // ==========================================
  // PÁGINA 3: HORARIOS
  // ==========================================
  Widget _buildPaginaHorarios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Horarios de Trabajo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define los horarios semanales del auxiliar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de horarios
          ..._horarios.asMap().entries.map((entry) {
            final index = entry.key;
            final horario = entry.value;

            return _buildHorarioCard(horario, index);
          }).toList(),

          // Botón agregar horario
          OutlinedButton.icon(
            onPressed: _agregarHorario,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Día'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF388E3C),
              side: const BorderSide(
                color: Color(0xFF388E3C),
                style: BorderStyle.solid,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          // Total de horas
          if (_horarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${_calcularTotalHoras().toStringAsFixed(1)} horas',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total por semana',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorarioCard(HorarioTemp horario, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: horario.diaSemana,
                  decoration: const InputDecoration(
                    labelText: 'Día',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: AuxiliarService.diasSemana
                      .where((dia) => !_horarios
                          .any((h) => h != horario && h.diaSemana == dia))
                      .map((dia) {
                    return DropdownMenuItem(
                      value: dia,
                      child: Text(
                        dia[0].toUpperCase() + dia.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      horario.diaSemana = value!;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                onPressed: () => _eliminarHorario(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  'Inicio',
                  horario.horaInicio,
                  (time) {
                    setState(() {
                      horario.horaInicio = _formatTime(time);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  'Fin',
                  horario.horaFin,
                  (time) {
                    setState(() {
                      horario.horaFin = _formatTime(time);
                    });
                  },
                ),
              ),
            ],
          ),
          if (horario.horaInicio.isNotEmpty && horario.horaFin.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '⏱️ Duración: ${_calcularDuracion(horario.horaInicio, horario.horaFin).toStringAsFixed(1)} horas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    String value,
    Function(TimeOfDay) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _parseTime(value),
        );
        if (time != null) {
          onChanged(time);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          value.isEmpty ? '--:--' : value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // ==========================================
  // BOTONES DE NAVEGACIÓN
  // ==========================================
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF666666),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage == 2 ? _guardar : _siguientePagina,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentPage == 2 ? 'Guardar' : 'Siguiente',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _siguientePagina() {
    if (_currentPage == 0) {
      // Validar datos básicos antes de continuar
      if (_nombreController.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El nombre es requerido'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      if (_emailController.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El email es requerido'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    } else if (_currentPage == 1) {
      if (_laboratoriosSeleccionados.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes seleccionar al menos un laboratorio'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _agregarHorario() {
    // Encontrar día disponible
    final diasDisponibles = AuxiliarService.diasSemana
        .where((dia) => !_horarios.any((h) => h.diaSemana == dia))
        .toList();

    if (diasDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya has agregado todos los días'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _horarios.add(HorarioTemp(
        diaSemana: diasDisponibles.first,
        horaInicio: '08:00',
        horaFin: '12:00',
      ));
    });
  }

  void _eliminarHorario(int index) {
    setState(() {
      _horarios.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    // Validar datos personales
    if (_nombreController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre es requerido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(0);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El email es requerido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(0);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email inválido'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(0);
      return;
    }

    if (!_esEdicion && _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña es requerida'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(0);
      return;
    }

    if (_passwordController.text.isNotEmpty && _passwordController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña debe tener al menos 6 caracteres'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(0);
      return;
    }

    // Validar laboratorios
    if (_laboratoriosSeleccionados.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes seleccionar al menos un laboratorio'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _pageController.jumpToPage(1);
      return;
    }

    // Validar horarios
    if (_horarios.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes agregar al menos un horario'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Validar que los horarios tengan valores
    for (var horario in _horarios) {
      if (horario.horaInicio.isEmpty || horario.horaFin.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Completa el horario del ${horario.diaSemana}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final form = AuxiliarFormModel(
        email: _emailController.text.trim(),
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        estado: _estado,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        laboratorios: _laboratoriosSeleccionados,
        horarios: _horarios.map((h) => HorarioFormModel(
          diaSemana: h.diaSemana,
          horaInicio: h.horaInicio,
          horaFin: h.horaFin,
        )).toList(),
      );

      if (_esEdicion) {
        await AuxiliarService.update(widget.auxiliar!.id, form);
      } else {
        await AuxiliarService.create(form);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? '✅ Auxiliar actualizado exitosamente'
                  : '✅ Auxiliar creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error guardando auxiliar: $e');
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Helpers
  double _calcularTotalHoras() {
    double total = 0;
    for (var horario in _horarios) {
      total += _calcularDuracion(horario.horaInicio, horario.horaFin);
    }
    return total;
  }

  double _calcularDuracion(String inicio, String fin) {
    if (inicio.isEmpty || fin.isEmpty) return 0;
    
    final inicioMinutos = _convertirAMinutos(inicio);
    final finMinutos = _convertirAMinutos(fin);
    
    return (finMinutos - inicioMinutos) / 60.0;
  }

  int _convertirAMinutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  TimeOfDay _parseTime(String time) {
    if (time.isEmpty) return const TimeOfDay(hour: 8, minute: 0);
    
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Clase temporal para horarios
class HorarioTemp {
  String diaSemana;
  String horaInicio;
  String horaFin;

  HorarioTemp({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });
}