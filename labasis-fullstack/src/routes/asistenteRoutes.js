// src/routes/asistenteRoutes.js

const express = require('express');
const router = express.Router();
const asistenteController = require('../controllers/asistenteController');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Chat con el asistente
router.post('/chat', asistenteController.chat);

// Obtener historial de conversación
router.get('/historial', asistenteController.getHistorial);

// Limpiar historial
router.delete('/historial', asistenteController.clearHistorial);

// Obtener sugerencias inteligentes
router.get('/sugerencias', asistenteController.getSugerencias);

module.exports = router;