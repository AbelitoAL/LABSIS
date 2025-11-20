// src/routes/laboratoriosRoutes.js

const express = require('express');
const router = express.Router();
const laboratoriosController = require('../controllers/laboratoriosController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Rutas disponibles para todos los usuarios autenticados
router.get('/', laboratoriosController.getAll);
router.get('/:id', laboratoriosController.getById);

// Rutas solo para admin
router.post('/', isAdmin, laboratoriosController.create);
router.put('/:id', isAdmin, laboratoriosController.update);
router.delete('/:id', isAdmin, laboratoriosController.delete);

module.exports = router;