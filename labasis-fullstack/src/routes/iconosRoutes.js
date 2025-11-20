// src/routes/iconosRoutes.js

const express = require('express');
const router = express.Router();
const iconosController = require('../controllers/iconosController');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.get('/', iconosController.getAll);
router.get('/:id', iconosController.getById);
router.post('/', iconosController.create);
router.put('/:id', iconosController.update);
router.delete('/:id', iconosController.delete);
router.post('/:id/uso', iconosController.incrementarUso);

module.exports = router;