// src/routes/manualesRoutes.js

const express = require('express');
const router = express.Router();
const manualesController = require('../controllers/manualesController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// ==========================================
// RUTAS DE MANUALES
// ==========================================

// Obtener todos los manuales (ambos roles)
// GET /api/manuales
router.get('/', manualesController.getAll);

// Obtener laboratorios con información de manuales (ambos roles)
// GET /api/manuales/laboratorios
router.get('/laboratorios', manualesController.getLaboratoriosConManuales);

// Obtener manual de un laboratorio específico (ambos roles)
// GET /api/manuales/laboratorio/:laboratorioId
router.get('/laboratorio/:laboratorioId', manualesController.getByLaboratorioId);

// Crear o actualizar manual (solo admin)
// POST /api/manuales/laboratorio/:laboratorioId
// PUT /api/manuales/laboratorio/:laboratorioId
router.post('/laboratorio/:laboratorioId', isAdmin, manualesController.createOrUpdate);
router.put('/laboratorio/:laboratorioId', isAdmin, manualesController.createOrUpdate);

// Eliminar manual (solo admin)
// DELETE /api/manuales/laboratorio/:laboratorioId
router.delete('/laboratorio/:laboratorioId', isAdmin, manualesController.delete);

module.exports = router;