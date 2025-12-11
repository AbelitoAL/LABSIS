// src/routes/docentesRoutes.js

const express = require('express');
const router = express.Router();
const docentesController = require('../controllers/docentesController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// ==========================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// Y ROL DE ADMINISTRADOR
// ==========================================

// Obtener todos los docentes
router.get(
  '/',
  authMiddleware,
  isAdmin,
  docentesController.getAll
);

// Obtener docente por ID
router.get(
  '/:id',
  authMiddleware,
  isAdmin,
  docentesController.getById
);

// Crear docente
router.post(
  '/',
  authMiddleware,
  isAdmin,
  docentesController.create
);

// Actualizar docente
router.put(
  '/:id',
  authMiddleware,
  isAdmin,
  docentesController.update
);

// Eliminar docente
router.delete(
  '/:id',
  authMiddleware,
  isAdmin,
  docentesController.delete
);

// Cambiar estado
router.patch(
  '/:id/estado',
  authMiddleware,
  isAdmin,
  docentesController.cambiarEstado
);

module.exports = router;