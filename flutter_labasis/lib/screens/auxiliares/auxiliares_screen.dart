// lib/screens/auxiliares/auxiliares_screen.dart

import 'package:flutter/material.dart';
import '../../models/auxiliar_model.dart';
import '../../services/auxiliar_service.dart';
import 'auxiliar_detalle_screen.dart';
import 'auxiliar_form_screen.dart';

class AuxiliaresScreen extends StatefulWidget {
  const AuxiliaresScreen({Key? key}) : super(key: key);

  @override
  State<AuxiliaresScreen> createState() => _AuxiliaresScreenState();
}

class _AuxiliaresScreenState extends State<AuxiliaresScreen> {
  List<AuxiliarModel> _auxiliares = [];
  List<AuxiliarModel> _auxiliaresFiltrados = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarAuxiliares();
  }

  Future<void> _cargarAuxiliares() async {
    setState(() => _isLoading = true);

    try {
      final auxiliares = await AuxiliarService.getAll();
      
      setState(() {
        _auxiliares = auxiliares;
        _auxiliaresFiltrados = auxiliares;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando auxiliares: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarAuxiliares(String query) {
    setState(() {
      _searchQuery = query;
      
      if (query.isEmpty) {
        _auxiliaresFiltrados = _auxiliares;
      } else {
        _auxiliaresFiltrados = _auxiliares.where((aux) {
          return aux.nombre.toLowerCase().contains(query.toLowerCase()) ||
                 aux.email.toLowerCase().contains(query.toLowerCase());
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
          '👥 Auxiliares',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarAuxiliares,
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: TextField(
                      onChanged: _filtrarAuxiliares,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '🔍 Buscar auxiliar...',
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

                  // Contador
                  if (_auxiliaresFiltrados.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${_auxiliaresFiltrados.length} auxiliar${_auxiliaresFiltrados.length != 1 ? 'es' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Lista de auxiliares
                  Expanded(
                    child: _auxiliaresFiltrados.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            itemCount: _auxiliaresFiltrados.length,
                            itemBuilder: (context, index) {
                              final auxiliar = _auxiliaresFiltrados[index];
                              return _buildAuxiliarCard(auxiliar);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearAuxiliar,
        backgroundColor: const Color(0xFFFF6B6B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAuxiliarCard(AuxiliarModel auxiliar) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuxiliarDetalleScreen(
              auxiliarId: auxiliar.id,
            ),
          ),
        ).then((_) => _cargarAuxiliares());
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
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFC92A2A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      auxiliar.iniciales,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nombre y email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auxiliar.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auxiliar.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Flecha
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFFF6B6B),
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(auxiliar.colorEstado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${auxiliar.emojiEstado} ${auxiliar.textoEstado}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(auxiliar.colorEstado),
                    ),
                  ),
                ),

                // Laboratorios
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🧪 ${auxiliar.cantidadLaboratorios} lab${auxiliar.cantidadLaboratorios != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ),

                // Horas
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🕐 ${auxiliar.horasSemanales.toStringAsFixed(1)} hrs/sem',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuxiliarDetalleScreen(
                            auxiliarId: auxiliar.id,
                          ),
                        ),
                      ).then((_) => _cargarAuxiliares());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7B1FA2),
                      side: const BorderSide(color: Color(0xFF7B1FA2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      '👁️ Ver',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editarAuxiliar(auxiliar),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: const Color(0xFF1976D2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      '✏️ Editar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _eliminarAuxiliar(auxiliar),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
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
            '👥',
            style: TextStyle(
              fontSize: 64,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No hay auxiliares registrados'
                : 'No se encontraron resultados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Agrega el primer auxiliar con el botón +',
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

  void _crearAuxiliar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuxiliarFormScreen(),
      ),
    ).then((actualizado) {
      if (actualizado == true) {
        _cargarAuxiliares();
      }
    });
  }

  void _editarAuxiliar(AuxiliarModel auxiliar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuxiliarFormScreen(
          auxiliar: auxiliar,
        ),
      ),
    ).then((actualizado) {
      if (actualizado == true) {
        _cargarAuxiliares();
      }
    });
  }

  Future<void> _eliminarAuxiliar(AuxiliarModel auxiliar) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Auxiliar'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${auxiliar.nombre}?\n\n'
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
      await AuxiliarService.delete(auxiliar.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Auxiliar eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarAuxiliares();
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