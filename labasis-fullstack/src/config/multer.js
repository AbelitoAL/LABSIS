// src/config/multer.js

const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Crear carpetas si no existen
const uploadsDir = path.join(__dirname, '../../uploads');
const imagesDir = path.join(uploadsDir, 'images');
const filesDir = path.join(uploadsDir, 'files');

[uploadsDir, imagesDir, filesDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configuración de almacenamiento para imágenes
const imageStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, imagesDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const nameWithoutExt = path.basename(file.originalname, ext);
    const sanitizedName = nameWithoutExt.replace(/[^a-zA-Z0-9]/g, '_');
    cb(null, sanitizedName + '-' + uniqueSuffix + ext);
  }
});

// Configuración de almacenamiento para archivos (PDFs, docs)
const fileStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, filesDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const nameWithoutExt = path.basename(file.originalname, ext);
    const sanitizedName = nameWithoutExt.replace(/[^a-zA-Z0-9]/g, '_');
    cb(null, sanitizedName + '-' + uniqueSuffix + ext);
  }
});

// Filtro para imágenes
const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Solo se permiten imágenes (jpeg, jpg, png, gif, webp)'));
  }
};

// Filtro para archivos PDF y documentos
const fileFilter = (req, file, cb) => {
  const allowedTypes = /pdf|doc|docx|xls|xlsx|txt/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = /pdf|msword|officedocument|text/.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Solo se permiten archivos PDF y documentos de Office'));
  }
};

// Límite de tamaño
const MAX_SIZE = parseInt(process.env.MAX_FILE_SIZE) || 10485760; // 10MB por defecto

// Configuraciones de Multer
const uploadImage = multer({
  storage: imageStorage,
  fileFilter: imageFilter,
  limits: { fileSize: MAX_SIZE }
});

const uploadFile = multer({
  storage: fileStorage,
  fileFilter: fileFilter,
  limits: { fileSize: MAX_SIZE }
});

// Upload múltiple
const uploadMultipleImages = multer({
  storage: imageStorage,
  fileFilter: imageFilter,
  limits: { fileSize: MAX_SIZE }
}).array('images', 10); // Máximo 10 imágenes

module.exports = {
  uploadImage,
  uploadFile,
  uploadMultipleImages
};