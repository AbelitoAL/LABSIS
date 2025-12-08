// server.js - LABASIS Backend API

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Importar rutas
const authRoutes = require('./src/routes/authRoutes');
const laboratoriosRoutes = require('./src/routes/laboratoriosRoutes');
const tareasRoutes = require('./src/routes/tareasRoutes');
const iconosRoutes = require('./src/routes/iconosRoutes');
const plantillasRoutes = require('./src/routes/plantillasRoutes');
const bitacorasRoutes = require('./src/routes/bitacorasRoutes');
const objetosPerdidosRoutes = require('./src/routes/objetosPerdidosRoutes');
const uploadRoutes = require('./src/routes/uploadRoutes');
const usersRoutes = require('./src/routes/usersRoutes');
const statsRoutes = require('./src/routes/statsRoutes');
const asistenteRoutes = require('./src/routes/asistenteRoutes');
const manualesRoutes = require('./src/routes/manualesRoutes'); // ← NUEVA RUTA

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir archivos estáticos
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Registrar rutas
app.use('/api/auth', authRoutes);
app.use('/api/laboratorios', laboratoriosRoutes);
app.use('/api/tareas', tareasRoutes);
app.use('/api/iconos', iconosRoutes);
app.use('/api/plantillas', plantillasRoutes);
app.use('/api/bitacoras', bitacorasRoutes);
app.use('/api/objetos-perdidos', objetosPerdidosRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/asistente', asistenteRoutes);
app.use('/api/manuales', manualesRoutes); // ← NUEVA RUTA

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({
    message: '🚀 LABASIS API funcionando correctamente',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      laboratorios: '/api/laboratorios',
      tareas: '/api/tareas',
      iconos: '/api/iconos',
      plantillas: '/api/plantillas',
      bitacoras: '/api/bitacoras',
      objetosPerdidos: '/api/objetos-perdidos',
      upload: '/api/upload',
      stats: '/api/stats',
      asistente: '/api/asistente',
      manuales: '/api/manuales' // ← NUEVO ENDPOINT
    }
  });
});

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada'
  });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Error en el servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║   🚀 LABASIS Backend API               ║
║   📡 Servidor corriendo en:            ║
║   http://localhost:${PORT}                ║
║                                        ║
║   📚 Endpoints disponibles:            ║
║   ✅ /api/auth                         ║
║   ✅ /api/laboratorios                 ║
║   ✅ /api/tareas                       ║
║   ✅ /api/iconos                       ║
║   ✅ /api/plantillas                   ║
║   ✅ /api/bitacoras                    ║
║   ✅ /api/objetos-perdidos             ║
║   ✅ /api/upload                       ║
║   ✅ /api/users                        ║
║   ✅ /api/stats                        ║
║   🤖 /api/asistente                    ║
║   📖 /api/manuales                     ║
╚════════════════════════════════════════╝
  `);
});