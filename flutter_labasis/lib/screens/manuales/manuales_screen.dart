// lib/screens/manuales/manuales_screen.dart

import 'package:flutter/material.dart';
import '../../models/manual_model.dart';
import '../../services/manual_service.dart';
import 'manual_detalle_screen.dart';

class ManualesScreen extends StatefulWidget {
  const ManualesScreen({Key? key}) : super(key: key);

  @override
  State<ManualesScreen> createState() => _ManualesScreenState();
}

class _ManualesScreenState extends State<ManualesScreen> {
  List<LaboratorioConManualModel> _laboratorios = [];
  List<LaboratorioConManualModel> _laboratoriosFiltrados = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarLaboratorios();
  }

  Future<void> _cargarLaboratorios() async {
    setState(() => _isLoading = true);

    try {
      final laboratorios = await ManualService.getLaboratoriosConManuales();
      
      setState(() {
        _laboratorios = laboratorios;
        _laboratoriosFiltrados = laboratorios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando laboratorios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarLaboratorios(String query) {
    setState(() {
      _searchQuery = query;
      
      if (query.isEmpty) {
        _laboratoriosFiltrados = _laboratorios;
      } else {
        _laboratoriosFiltrados = _laboratorios.where((lab) {
          return lab.nombre.toLowerCase().contains(query.toLowerCase()) ||
                 lab.codigo.toLowerCase().contains(query.toLowerCase()) ||
                 (lab.ubicacion?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '📖 Manuales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarLaboratorios,
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF667EEA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: TextField(
                      onChanged: _filtrarLaboratorios,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '🔍 Buscar laboratorio...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
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
                  ),

                  // Lista de laboratorios
                  Expanded(
                    child: _laboratoriosFiltrados.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _laboratoriosFiltrados.length,
                            itemBuilder: (context, index) {
                              final laboratorio = _laboratoriosFiltrados[index];
                              return _buildLaboratorioCard(laboratorio);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLaboratorioCard(LaboratorioConManualModel laboratorio) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManualDetalleScreen(
              laboratorioId: laboratorio.id,
            ),
          ),
        ).then((_) => _cargarLaboratorios()); // Recargar al volver
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
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
              children: [
                // Icono del laboratorio
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      laboratorio.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nombre y código
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laboratorio.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        laboratorio.codigo,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF667EEA),
                  size: 28,
                ),
              ],
            ),

            if (laboratorio.ubicacion != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      laboratorio.ubicacion!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Badge de estado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: laboratorio.tieneManual
                        ? const Color(0xFFE3F2FD)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        laboratorio.tieneManual
                            ? '${laboratorio.cantidadItems} items'
                            : 'Sin manual',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: laboratorio.tieneManual
                              ? const Color(0xFF1976D2)
                              : const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),

                if (laboratorio.tieneManual && laboratorio.manualActualizado != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actualizado ${ManualService.formatearFecha(laboratorio.manualActualizado)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📭',
            style: TextStyle(
              fontSize: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No hay laboratorios disponibles'
                : 'No se encontraron resultados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}