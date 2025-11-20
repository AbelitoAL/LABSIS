// src/routes/tareasRoutes.js

const express = require('express');
const router = express.Router();
const tareasController = require('../controllers/tareasController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Rutas disponibles para todos
router.get('/', tareasController.getAll);
router.get('/mis-tareas', tareasController.getMisTareas);
router.get('/:id', tareasController.getById);
router.put('/:id', tareasController.update);
router.post('/:id/completar', tareasController.marcarCompletada);

// Rutas solo para admin
router.post('/', isAdmin, tareasController.create);
router.delete('/:id', isAdmin, tareasController.delete);

module.exports = router;