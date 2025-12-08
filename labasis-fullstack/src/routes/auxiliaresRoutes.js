// src/routes/auxiliaresRoutes.js

const express = require('express');
const router = express.Router();
const auxiliaresController = require('../controllers/auxiliaresController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// ==========================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// Y ROL DE ADMINISTRADOR
// ==========================================

// Obtener todos los auxiliares
router.get(
  '/',
  authMiddleware,
  isAdmin,
  auxiliaresController.getAll
);

// Obtener auxiliar por ID
router.get(
  '/:id',
  authMiddleware,
  isAdmin,
  auxiliaresController.getById
);

// Crear auxiliar
router.post(
  '/',
  authMiddleware,
  isAdmin,
  auxiliaresController.create
);

// Actualizar auxiliar
router.put(
  '/:id',
  authMiddleware,
  isAdmin,
  auxiliaresController.update
);

// Eliminar auxiliar
router.delete(
  '/:id',
  authMiddleware,
  isAdmin,
  auxiliaresController.delete
);

// Asignar laboratorios
router.post(
  '/:id/laboratorios',
  authMiddleware,
  isAdmin,
  auxiliaresController.asignarLaboratorios
);

// Asignar horarios
router.post(
  '/:id/horarios',
  authMiddleware,
  isAdmin,
  auxiliaresController.asignarHorarios
);

// Cambiar estado
router.patch(
  '/:id/estado',
  authMiddleware,
  isAdmin,
  auxiliaresController.cambiarEstado
);

module.exports = router;