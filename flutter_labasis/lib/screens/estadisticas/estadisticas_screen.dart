// lib/screens/estadisticas/estadisticas_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/estadisticas_service.dart';
import '../../models/estadisticas_model.dart';
import '../../models/auxiliar_model.dart';
import 'widgets/stat_card.dart';
import 'widgets/pie_chart_widget.dart';
import 'widgets/line_chart_widget.dart';
import 'widgets/bar_chart_widget.dart';
import 'widgets/top_auxiliares_widget.dart';
import 'widgets/tareas_urgentes_widget.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({Key? key}) : super(key: key);

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  bool _isLoading = true;
  String? _error;
  EstadisticasModel? _estadisticas;
  List<AuxiliarModel> _auxiliares = [];
  int? _auxiliarSeleccionado; // null = Todos

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _cargarAuxiliares();
    await _cargarEstadisticas();
  }

  Future<void> _cargarAuxiliares() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() => _error = 'No autenticado');
        return;
      }

      final auxiliares = await EstadisticasService.getAuxiliares(token: token);
      setState(() => _auxiliares = auxiliares);
    } catch (e) {
      print('Error cargando auxiliares: $e');
      // No es crítico, continuar sin auxiliares
    }
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _error = 'No autenticado';
          _isLoading = false;
        });
        return;
      }

      final estadisticas = await EstadisticasService.getDashboard(
        token: token,
        auxiliarId: _auxiliarSeleccionado,
      );

      setState(() {
        _estadisticas = estadisticas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error cargando estadísticas: $e');
    }
  }

  void _cambiarAuxiliar(int? auxiliarId) {
    setState(() => _auxiliarSeleccionado = auxiliarId);
    _cargarEstadisticas();
  }

  Future<void> _refrescar() async {
    await _cargarEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Verificar que sea admin
    if (user?.rol != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Acceso denegado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Solo administradores pueden ver este panel'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Panel de Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refrescar,
            tooltip: 'Actualizar',
          ),
          // TODO: Botón de exportar PDF (siguiente paso)
          // IconButton(
          //   icon: const Icon(Icons.picture_as_pdf),
          //   onPressed: () {},
          //   tooltip: 'Exportar PDF',
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando estadísticas...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarEstadisticas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_estadisticas == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _refrescar,
      color: const Color(0xFFE91E63),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Filtro de auxiliar
            _buildFiltroAuxiliar(),

            // Contenido según el tipo de vista
            if (_estadisticas!.esVistaGeneral)
              _buildVistaGeneral()
            else
              _buildVistaAuxiliar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroAuxiliar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👤 Ver estadísticas de:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: _auxiliarSeleccionado,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
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
                borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.public, size: 20, color: Color(0xFFE91E63)),
                    SizedBox(width: 12),
                    Text(
                      'Todas las actividades',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ..._auxiliares.map((auxiliar) => DropdownMenuItem(
                    value: auxiliar.id,
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Color(0xFF2196F3)),
                        const SizedBox(width: 12),
                        Text(auxiliar.nombre),
                      ],
                    ),
                  )),
            ],
            onChanged: _cambiarAuxiliar,
          ),
        ],
      ),
    );
  }

  Widget _buildVistaGeneral() {
    final stats = _estadisticas!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 RESUMEN GENERAL DEL SISTEMA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Última actualización: ${_formatearFechaHora(stats.ultimaActualizacion)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Tarjetas de resumen
        _buildResumenCards(),

        const SizedBox(height: 16),

        // Gráfica de tareas por estado
        _buildSeccionGrafica(
          titulo: '📈 DISTRIBUCIÓN DE TAREAS',
          child: PieChartWidget(data: stats.graficas.tareasPorEstado),
        ),

        const SizedBox(height: 16),

        // Gráfica de bitácoras por mes
        _buildSeccionGrafica(
          titulo: '📊 BITÁCORAS POR MES',
          child: LineChartWidget(data: stats.graficas.bitacorasPorMes),
        ),

        const SizedBox(height: 16),

        // Gráfica de objetos por categoría
        if (stats.graficas.objetosPorCategoria != null)
          _buildSeccionGrafica(
            titulo: '📦 OBJETOS PERDIDOS POR CATEGORÍA',
            child: BarChartWidget(
              data: stats.graficas.objetosPorCategoria!,
              tipo: 'categoria',
            ),
          ),

        const SizedBox(height: 16),

        // Top auxiliares
        if (stats.rankings != null)
          _buildSeccionGrafica(
            titulo: '🏆 TOP 5 AUXILIARES MÁS ACTIVOS',
            child: TopAuxiliaresWidget(
              topAuxiliares: stats.rankings!.topAuxiliares,
            ),
          ),

        const SizedBox(height: 16),

        // Actividad por laboratorio
        _buildSeccionGrafica(
          titulo: '🔬 ACTIVIDAD POR LABORATORIO',
          child: BarChartWidget(
            data: stats.laboratorios
                .map((lab) => GraficaItemModel(
                      nombre: lab.nombre,
                      cantidad: lab.actividadTotal,
                      porcentaje: lab.porcentaje,
                    ))
                .toList(),
            tipo: 'laboratorio',
          ),
        ),

        const SizedBox(height: 16),

        // Tareas urgentes
        _buildSeccionGrafica(
          titulo: '⏰ TAREAS PRÓXIMAS A VENCER',
          child: TareasUrgentesWidget(tareas: stats.tareasUrgentes),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVistaAuxiliar() {
    final stats = _estadisticas!;
    final auxiliar = stats.auxiliarInfo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del auxiliar
        Container(
          margin: const EdgeInsets.all(16),
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auxiliar.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auxiliar.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Activo desde: ${_formatearFecha(auxiliar.activoDesde)}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (stats.ranking != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getMedallaEmoji(stats.ranking!.posicion),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stats.ranking!.posicionTexto,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Título de estadísticas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '📊 ESTADÍSTICAS DE ${auxiliar.nombre.toUpperCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Tarjetas de resumen
        _buildResumenCards(),

        const SizedBox(height: 16),

        // Sus tareas por estado
        _buildSeccionGrafica(
          titulo: '📈 SUS TAREAS POR ESTADO',
          child: PieChartWidget(data: stats.graficas.tareasPorEstado),
        ),

        const SizedBox(height: 16),

        // Sus bitácoras por mes
        _buildSeccionGrafica(
          titulo: '📊 SUS BITÁCORAS POR MES',
          child: LineChartWidget(data: stats.graficas.bitacorasPorMes),
        ),

        const SizedBox(height: 16),

        // Sus laboratorios
        if (stats.laboratorios.isNotEmpty)
          _buildSeccionGrafica(
            titulo: '🔬 SUS LABORATORIOS ASIGNADOS',
            child: BarChartWidget(
              data: stats.laboratorios
                  .map((lab) => GraficaItemModel(
                        nombre: lab.nombre,
                        cantidad: lab.actividades ?? lab.actividadTotal,
                        porcentaje: 100,
                      ))
                  .toList(),
              tipo: 'laboratorio',
            ),
          ),

        const SizedBox(height: 16),

        // Sus tareas pendientes
        if (stats.tareasPendientes != null && stats.tareasPendientes!.isNotEmpty)
          _buildSeccionGrafica(
            titulo: '⏰ SUS TAREAS PENDIENTES',
            child: _buildTareasPendientesAuxiliar(stats.tareasPendientes!),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResumenCards() {
    final resumen = _estadisticas!.resumen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: 2 columnas en móvil, 4 en tablet/escritorio
          final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95, // ← CAMBIADO de 1.1 a 0.95 (más alto)
            children: [
              StatCard(
                icon: Icons.assignment,
                iconColor: const Color(0xFF2196F3),
                titulo: 'Tareas',
                total: resumen.tareas.total,
                detalles: [
                  '${resumen.tareas.pendientes} Pendientes',
                  '${resumen.tareas.enProceso} En Proceso',
                  '${resumen.tareas.completadas} Completadas',
                ],
              ),
              StatCard(
                icon: Icons.description,
                iconColor: const Color(0xFF4CAF50),
                titulo: 'Bitácoras',
                total: resumen.bitacoras.total,
                detalles: [
                  '${resumen.bitacoras.borradores} Borradores',
                  '${resumen.bitacoras.completadas} Completadas',
                ],
              ),
              StatCard(
                icon: Icons.inventory_2,
                iconColor: const Color(0xFFFF9800),
                titulo: 'Objetos',
                total: resumen.objetos.total,
                detalles: [
                  '${resumen.objetos.enCustodia} En Custodia',
                  '${resumen.objetos.entregados} Entregados',
                ],
              ),
              if (resumen.usuarios != null)
                StatCard(
                  icon: Icons.people,
                  iconColor: const Color(0xFF9C27B0),
                  titulo: 'Usuarios',
                  total: resumen.usuarios!.total,
                  detalles: [
                    '${resumen.usuarios!.activos} Activos',
                    '${resumen.usuarios!.inactivos} Inactivos',
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeccionGrafica({
    required String titulo,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTareasPendientesAuxiliar(List<TareaPendienteModel> tareas) {
    return Column(
      children: tareas.map((tarea) {
        Color urgenciaColor;
        switch (tarea.urgencia) {
          case 'alta':
            urgenciaColor = const Color(0xFFF44336);
            break;
          case 'media':
            urgenciaColor = const Color(0xFFFFC107);
            break;
          default:
            urgenciaColor = const Color(0xFF4CAF50);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: urgenciaColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tarea.titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (tarea.laboratorio != null)
                Text(
                  '🔬 ${tarea.laboratorio}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgenciaColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tarea.diasRestantes == 0
                          ? 'Vence hoy'
                          : tarea.diasRestantes == 1
                              ? 'Vence mañana'
                              : 'Vence en ${tarea.diasRestantes} días',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: urgenciaColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '${fecha.day} ${meses[fecha.month - 1]}, ${fecha.year} - $hora:$minuto';
  }

  String _formatearFecha(String isoDate) {
    try {
      final fecha = DateTime.parse(isoDate);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${fecha.day} ${meses[fecha.month - 1]}, ${fecha.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _getMedallaEmoji(int posicion) {
    switch (posicion) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
  }
}