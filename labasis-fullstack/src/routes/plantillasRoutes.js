// src/routes/plantillasRoutes.js

const express = require('express');
const router = express.Router();
const plantillasController = require('../controllers/plantillasController');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.get('/', plantillasController.getAll);
router.get('/:id', plantillasController.getById);
router.post('/', plantillasController.create);
router.put('/:id', plantillasController.update);
router.delete('/:id', plantillasController.delete);
router.post('/:id/duplicar', plantillasController.duplicar);

module.exports = router;