// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../laboratorios/laboratorios_screen.dart';
import '../tareas/tareas_screen.dart';
import '../bitacoras/bitacoras_screen.dart';
import '../objetos_perdidos/objetos_perdidos_screen.dart';
import '../asistente/asistente_screen.dart';
import '../estadisticas/estadisticas_screen.dart';
import '../manuales/manuales_screen.dart';
import '../perfil/perfil_screen.dart';
import '../auxiliares/auxiliares_screen.dart';
import '../docentes/docentes_screen.dart'; // ← NUEVO

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const LaboratoriosScreen(),
    const TareasScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            activeIcon: Icon(Icons.science),
            label: 'Laboratorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido/a!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user?.nombre ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.rol == 'admin' ? 'Administrador' : 'Auxiliar',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido principal
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accesos Rápidos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid de accesos rápidos
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          // ==========================================
                          // ASISTENTE IA (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.smart_toy,
                            iconColor: const Color(0xFF6C63FF),
                            label: 'Asistente IA',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AsistenteScreen(),
                                ),
                              );
                            },
                          ),

                          // ==========================================
                          // PANEL (SOLO ADMIN)
                          // ==========================================
                          if (user?.rol == 'admin')
                            _QuickAccessCard(
                              icon: Icons.dashboard,
                              iconColor: const Color(0xFFE91E63),
                              label: 'Panel',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EstadisticasScreen(),
                                  ),
                                );
                              },
                            ),

                          // ==========================================
                          // AUXILIARES (SOLO ADMIN)
                          // ==========================================
                          if (user?.rol == 'admin')
                            _QuickAccessCard(
                              icon: Icons.people,
                              iconColor: const Color(0xFFFF6B6B),
                              label: 'Auxiliares',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AuxiliaresScreen(),
                                  ),
                                );
                              },
                            ),

                          // ==========================================
                          // DOCENTES (SOLO ADMIN) ← NUEVO
                          // ==========================================
                          if (user?.rol == 'admin')
                            _QuickAccessCard(
                              icon: Icons.school,
                              iconColor: const Color(0xFF1976D2),
                              label: 'Docentes',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DocentesScreen(),
                                  ),
                                );
                              },
                            ),

                          // ==========================================
                          // MANUALES (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.menu_book,
                            iconColor: const Color(0xFF667EEA),
                            label: 'Manuales',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManualesScreen(),
                                ),
                              );
                            },
                          ),

                          // ==========================================
                          // LABORATORIOS (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.science,
                            iconColor: const Color(0xFF2196F3),
                            label: 'Laboratorios',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LaboratoriosScreen(),
                                ),
                              );
                            },
                          ),

                          // ==========================================
                          // MIS TAREAS (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.assignment,
                            iconColor: const Color(0xFFFF9800),
                            label: 'Mis Tareas',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TareasScreen(),
                                ),
                              );
                            },
                          ),

                          // ==========================================
                          // BITÁCORAS (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.description,
                            iconColor: const Color(0xFF4CAF50),
                            label: 'Bitácoras',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BitacorasScreen(),
                                ),
                              );
                            },
                          ),

                          // ==========================================
                          // OBJETOS PERDIDOS (TODOS)
                          // ==========================================
                          _QuickAccessCard(
                            icon: Icons.inventory_2,
                            iconColor: const Color(0xFF9C27B0),
                            label: 'Objetos Perdidos',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ObjetosPerdidosScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}