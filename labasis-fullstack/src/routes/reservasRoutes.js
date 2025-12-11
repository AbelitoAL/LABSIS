// src/routes/reservasRoutes.js

const express = require('express');
const router = express.Router();
const reservasController = require('../controllers/reservasController');
const { authMiddleware, isAdmin, isDocente, isDocenteOrAdmin } = require('../middleware/auth');

// ==========================================
// TODAS LAS RUTAS REQUIEREN AUTENTICACIÓN
// ==========================================

// Obtener todas las reservas (filtrado por rol automáticamente)
// - Admin: todas
// - Docente: solo propias
// - Auxiliar: solo aprobadas de sus labs
router.get(
  '/',
  authMiddleware,
  reservasController.getAll
);

// Obtener reserva por ID
router.get(
  '/:id',
  authMiddleware,
  reservasController.getById
);

// Crear reserva (solo docentes)
router.post(
  '/',
  authMiddleware,
  isDocente,
  reservasController.create
);

// Aprobar reserva (solo admin)
router.patch(
  '/:id/aprobar',
  authMiddleware,
  isAdmin,
  reservasController.aprobar
);

// Rechazar reserva (solo admin)
router.patch(
  '/:id/rechazar',
  authMiddleware,
  isAdmin,
  reservasController.rechazar
);

// Cancelar reserva (docente propietario)
router.patch(
  '/:id/cancelar',
  authMiddleware,
  isDocente,
  reservasController.cancelar
);

// Eliminar reserva (solo admin)
router.delete(
  '/:id',
  authMiddleware,
  isAdmin,
  reservasController.delete
);

module.exports = router;