// src/routes/objetosPerdidosRoutes.js

const express = require('express');
const router = express.Router();
const objetosPerdidosController = require('../controllers/objetosPerdidosController');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.get('/', objetosPerdidosController.getAll);
router.get('/:id', objetosPerdidosController.getById);
router.post('/', objetosPerdidosController.create);
router.put('/:id', objetosPerdidosController.update);
router.delete('/:id', objetosPerdidosController.delete);
router.post('/:id/entregar', objetosPerdidosController.registrarEntrega);

module.exports = router;