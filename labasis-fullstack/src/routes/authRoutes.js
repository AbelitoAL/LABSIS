// src/routes/authRoutes.js

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authMiddleware, isAdmin } = require('../middleware/auth');

// Rutas públicas
router.post('/login', authController.login);
router.post('/register-public', authController.registerPublic);

// Rutas protegidas
router.get('/me', authMiddleware, authController.me);
router.post('/register', authMiddleware, isAdmin, authController.register);

module.exports = router;