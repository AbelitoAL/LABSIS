// src/middleware/auth.js

const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  try {
    // Obtener token del header
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token no proporcionado'
      });
    }

    // Verificar token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Agregar usuario al request
    req.user = decoded;
    
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token inválido'
    });
  }
};

// Middleware para verificar si es admin
const isAdmin = (req, res, next) => {
  if (req.user.rol !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Solo administradores.'
    });
  }
  next();
};

// Middleware para verificar si es docente
const isDocente = (req, res, next) => {
  if (req.user.rol !== 'docente') {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Solo docentes.'
    });
  }
  next();
};

// Middleware para verificar si es docente o admin
const isDocenteOrAdmin = (req, res, next) => {
  if (req.user.rol !== 'docente' && req.user.rol !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Solo docentes y administradores.'
    });
  }
  next();
};

// Middleware para verificar si es auxiliar
const isAuxiliar = (req, res, next) => {
  if (req.user.rol !== 'auxiliar') {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Solo auxiliares.'
    });
  }
  next();
};

module.exports = { 
  authMiddleware, 
  isAdmin, 
  isDocente, 
  isDocenteOrAdmin,
  isAuxiliar
};