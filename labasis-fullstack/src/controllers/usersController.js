// src/controllers/usersController.js

const bcrypt = require('bcryptjs');
const db = require('../config/database');

class UsersController {
  // Obtener todos los usuarios (solo admin)
  async getAll(req, res) {
    try {
      const users = await db.all(
        'SELECT id, email, nombre, rol, activo, laboratorios_asignados, fcm_token, created_at, updated_at FROM users ORDER BY created_at DESC'
      );

      // Parsear laboratorios_asignados
      const usersFormateados = users.map(user => ({
        ...user,
        laboratorios_asignados: user.laboratorios_asignados ? JSON.parse(user.laboratorios_asignados) : []
      }));

      res.json({
        success: true,
        data: usersFormateados
      });
    } catch (error) {
      console.error('Error obteniendo usuarios:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener usuario por ID
  async getById(req, res) {
    try {
      const { id } = req.params;

      // Solo admin puede ver otros usuarios, auxiliares solo pueden verse a sí mismos
      if (req.user.rol !== 'admin' && req.user.id !== parseInt(id)) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para ver este usuario'
        });
      }

      const user = await db.get(
        'SELECT id, email, nombre, rol, activo, laboratorios_asignados, fcm_token, created_at, updated_at FROM users WHERE id = ?',
        [id]
      );

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      user.laboratorios_asignados = user.laboratorios_asignados ? JSON.parse(user.laboratorios_asignados) : [];

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

  // Crear usuario (solo admin)
  async create(req, res) {
    try {
      const { email, password, nombre, rol, laboratorios_asignados } = req.body;

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

      // Verificar si el email ya existe
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
      console.error('Error creando usuario:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actualizar usuario
  async update(req, res) {
    try {
      const { id } = req.params;
      const { nombre, email, password, rol, activo, laboratorios_asignados } = req.body;

      // Solo admin puede actualizar otros usuarios
      if (req.user.rol !== 'admin' && req.user.id !== parseInt(id)) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para actualizar este usuario'
        });
      }

      // Verificar que el usuario existe
      const user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      // Si se cambia el email, verificar que no exista
      if (email && email !== user.email) {
        const existingEmail = await db.get(
          'SELECT id FROM users WHERE email = ? AND id != ?',
          [email, id]
        );
        if (existingEmail) {
          return res.status(400).json({
            success: false,
            message: 'El email ya está en uso'
          });
        }
      }

      // Solo admin puede cambiar rol y estado activo
      if ((rol || activo !== undefined) && req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Solo administradores pueden cambiar rol o estado'
        });
      }

      // Preparar campos a actualizar
      let fieldsToUpdate = [];
      let values = [];

      if (nombre) {
        fieldsToUpdate.push('nombre = ?');
        values.push(nombre);
      }
      if (email) {
        fieldsToUpdate.push('email = ?');
        values.push(email);
      }
      if (password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        fieldsToUpdate.push('password = ?');
        values.push(hashedPassword);
      }
      if (rol && req.user.rol === 'admin') {
        fieldsToUpdate.push('rol = ?');
        values.push(rol);
      }
      if (activo !== undefined && req.user.rol === 'admin') {
        fieldsToUpdate.push('activo = ?');
        values.push(activo);
      }
      if (laboratorios_asignados && req.user.rol === 'admin') {
        fieldsToUpdate.push('laboratorios_asignados = ?');
        values.push(JSON.stringify(laboratorios_asignados));
      }

      if (fieldsToUpdate.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No hay campos para actualizar'
        });
      }

      fieldsToUpdate.push('updated_at = CURRENT_TIMESTAMP');
      values.push(id);

      await db.run(
        `UPDATE users SET ${fieldsToUpdate.join(', ')} WHERE id = ?`,
        values
      );

      res.json({
        success: true,
        message: 'Usuario actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando usuario:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar usuario (solo admin)
  async delete(req, res) {
    try {
      const { id } = req.params;

      // No permitir eliminar al propio usuario
      if (req.user.id === parseInt(id)) {
        return res.status(400).json({
          success: false,
          message: 'No puedes eliminar tu propio usuario'
        });
      }

      const user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      await db.run('DELETE FROM users WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Usuario eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando usuario:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Asignar laboratorios a un auxiliar
  async asignarLaboratorios(req, res) {
    try {
      const { id } = req.params;
      const { laboratorios_asignados } = req.body;

      if (!Array.isArray(laboratorios_asignados)) {
        return res.status(400).json({
          success: false,
          message: 'laboratorios_asignados debe ser un array'
        });
      }

      const user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      // Verificar que los laboratorios existan
      for (const labId of laboratorios_asignados) {
        const lab = await db.get('SELECT id FROM laboratorios WHERE id = ?', [labId]);
        if (!lab) {
          return res.status(404).json({
            success: false,
            message: `Laboratorio con ID ${labId} no encontrado`
          });
        }
      }

      await db.run(
        'UPDATE users SET laboratorios_asignados = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [JSON.stringify(laboratorios_asignados), id]
      );

      res.json({
        success: true,
        message: 'Laboratorios asignados exitosamente'
      });
    } catch (error) {
      console.error('Error asignando laboratorios:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Cambiar contraseña
  async cambiarPassword(req, res) {
    try {
      const { id } = req.params;
      const { password_actual, password_nuevo } = req.body;

      // Solo el propio usuario o admin puede cambiar la contraseña
      if (req.user.rol !== 'admin' && req.user.id !== parseInt(id)) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para cambiar esta contraseña'
        });
      }

      if (!password_nuevo) {
        return res.status(400).json({
          success: false,
          message: 'La nueva contraseña es requerida'
        });
      }

      const user = await db.get('SELECT * FROM users WHERE id = ?', [id]);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      // Si no es admin, verificar contraseña actual
      if (req.user.rol !== 'admin') {
        if (!password_actual) {
          return res.status(400).json({
            success: false,
            message: 'La contraseña actual es requerida'
          });
        }

        const isValidPassword = await bcrypt.compare(password_actual, user.password);
        if (!isValidPassword) {
          return res.status(401).json({
            success: false,
            message: 'Contraseña actual incorrecta'
          });
        }
      }

      const hashedPassword = await bcrypt.hash(password_nuevo, 10);
      await db.run(
        'UPDATE users SET password = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [hashedPassword, id]
      );

      res.json({
        success: true,
        message: 'Contraseña actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error cambiando contraseña:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new UsersController();