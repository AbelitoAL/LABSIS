// src/routes/statsRoutes.js

const express = require('express');
const router = express.Router();
const statsController = require('../controllers/statsController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Estadísticas generales (solo admin)
router.get('/general', isAdmin, statsController.getGeneral);
router.get('/laboratorios', isAdmin, statsController.getLaboratorios);
router.get('/tareas', isAdmin, statsController.getTareas);
router.get('/objetos-perdidos', isAdmin, statsController.getObjetosPerdidos);
router.get('/actividad-reciente', isAdmin, statsController.getActividadReciente);

// Estadísticas de auxiliar (admin puede ver cualquiera, auxiliar solo las suyas)
router.get('/auxiliar/:id', statsController.getAuxiliar);

module.exports = router;