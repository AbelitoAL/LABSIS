// src/routes/uploadRoutes.js

const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const { uploadImage, uploadFile, uploadMultipleImages } = require('../config/multer');
const { authMiddleware } = require('../middleware/auth');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Subir imagen única
router.post('/image', uploadImage.single('image'), uploadController.uploadImage);

// Subir múltiples imágenes
router.post('/images', uploadMultipleImages, uploadController.uploadMultipleImages);

// Subir archivo (PDF, doc, etc.)
router.post('/file', uploadFile.single('file'), uploadController.uploadFile);

// Listar archivos
router.get('/list/:type', uploadController.listFiles);

// Eliminar archivo
router.delete('/:type/:filename', uploadController.deleteFile);

module.exports = router;