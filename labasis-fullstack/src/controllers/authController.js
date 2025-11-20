// src/controllers/authController.js

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

class AuthController {
  // Login
  async login(req, res) {
    console.log('🔐 Intento de login:', req.body.email);
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email y contraseña son requeridos'
        });
      }

      const user = await db.get(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );

      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Credenciales inválidas'
        });
      }

      const isValidPassword = await bcrypt.compare(password, user.password);

      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          message: 'Credenciales inválidas'
        });
      }

      if (!user.activo) {
        return res.status(403).json({
          success: false,
          message: 'Usuario desactivado'
        });
      }

      const token = jwt.sign(
        {
          id: user.id,
          email: user.email,
          rol: user.rol
        },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      await db.run(
        'UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [user.id]
      );

      delete user.password;

      if (user.laboratorios_asignados) {
        user.laboratorios_asignados = JSON.parse(user.laboratorios_asignados);
      } else {
        user.laboratorios_asignados = [];
      }
     console.log('✅ Login exitoso para usuario ID:', user.id);
      res.json({
        success: true,
        message: 'Login exitoso',
        data: {
          token,
          user
        }
      });
    } catch (error) {
      console.error('Error en login:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener usuario actual
  async me(req, res) {
    try {
      const user = await db.get(
        'SELECT id, email, nombre, rol, activo, laboratorios_asignados, created_at FROM users WHERE id = ?',
        [req.user.id]
      );

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      if (user.laboratorios_asignados) {
        user.laboratorios_asignados = JSON.parse(user.laboratorios_asignados);
      } else {
        user.laboratorios_asignados = [];
      }

      res.json({
        success: true,
        data: user
      });
    } catch (error) {
      console.error('Error obteniendo usuario:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Registro público (cualquiera puede registrarse como auxiliar)
  async registerPublic(req, res) {
    try {
      const { email, password, nombre } = req.body;

      if (!email || !password || !nombre) {
        return res.status(400).json({
          success: false,
          message: 'Email, contraseña y nombre son requeridos'
        });
      }

      // Verificar que el email no exista
      const existingUser = await db.get(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'El email ya está registrado'
        });
      }

      // Encriptar contraseña
      const hashedPassword = await bcrypt.hash(password, 10);

      // Crear usuario (siempre como auxiliar)
      const result = await db.run(
        `INSERT INTO users (email, password, nombre, rol, laboratorios_asignados) 
         VALUES (?, ?, ?, ?, ?)`,
        [email, hashedPassword, nombre, 'auxiliar', JSON.stringify([])]
      );

      // Generar token automáticamente
      const token = jwt.sign(
        {
          id: result.id,
          email: email,
          rol: 'auxiliar'
        },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.status(201).json({
        success: true,
        message: 'Usuario creado exitosamente',
        data: {
          token,
          user: {
            id: result.id,
            email,
            nombre,
            rol: 'auxiliar'
          }
        }
      });
    } catch (error) {
      console.error('Error en registro público:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Registro por admin (puede crear cualquier rol)
  async register(req, res) {
    try {
      const { email, password, nombre, rol, laboratorios_asignados } = req.body;

      console.log('📝 Admin creando usuario:', { email, nombre, rol });

      // Validaciones
      if (!email || !password || !nombre || !rol) {
        return res.status(400).json({
          success: false,
          message: 'Email, contraseña, nombre y rol son requeridos'
        });
      }

      // Validar rol
      if (!['admin', 'auxiliar'].includes(rol)) {
        return res.status(400).json({
          success: false,
          message: 'Rol inválido. Debe ser "admin" o "auxiliar"'
        });
      }

      // Verificar que el email no exista
      const existingUser = await db.get(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'El email ya está registrado'
        });
      }

      // Encriptar contraseña
      const hashedPassword = await bcrypt.hash(password, 10);

      // Crear usuario
      const result = await db.run(
        `INSERT INTO users (email, password, nombre, rol, laboratorios_asignados) 
         VALUES (?, ?, ?, ?, ?)`,
        [
          email,
          hashedPassword,
          nombre,
          rol,
          JSON.stringify(laboratorios_asignados || [])
        ]
      );

      console.log('✅ Usuario creado con ID:', result.id);

      res.status(201).json({
        success: true,
        message: 'Usuario creado exitosamente',
        data: {
          id: result.id,
          email,
          nombre,
          rol
        }
      });
    } catch (error) {
      console.error('❌ Error en registro admin:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }
}

module.exports = new AuthController();