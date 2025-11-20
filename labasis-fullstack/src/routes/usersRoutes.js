// src/routes/usersRoutes.js

const express = require('express');
const router = express.Router();
const usersController = require('../controllers/usersController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Rutas disponibles para todos (ver su propio perfil)
router.get('/:id', usersController.getById);

// Rutas solo para admin
router.get('/', isAdmin, usersController.getAll);
router.post('/', isAdmin, usersController.create);
router.put('/:id', isAdmin, usersController.update);
router.delete('/:id', isAdmin, usersController.delete);
router.put('/:id/asignar-laboratorios', isAdmin, usersController.asignarLaboratorios);

// Cambiar contraseña (propio usuario o admin)
router.put('/:id/cambiar-password', usersController.cambiarPassword);

module.exports = router;