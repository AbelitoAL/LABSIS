// src/routes/bitacorasRoutes.js

const express = require('express');
const router = express.Router();
const bitacorasController = require('../controllers/bitacorasController');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.get('/', bitacorasController.getAll);
router.get('/:id', bitacorasController.getById);
router.post('/', bitacorasController.create);
router.put('/:id', bitacorasController.update);
router.delete('/:id', bitacorasController.delete);
router.post('/:id/completar', bitacorasController.completar);

module.exports = router;