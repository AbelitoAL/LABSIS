// src/controllers/docentesController.js

const db = require('../config/database');
const bcrypt = require('bcryptjs');

class DocentesController {
  // ==========================================
  // OBTENER TODOS LOS DOCENTES CON INFO
  // ==========================================
  getAll = async (req, res) => {
    try {
      console.log('👨‍🏫 Obteniendo lista de docentes...');

      // Obtener todos los usuarios con rol docente
      const docentes = await db.all(`
        SELECT 
          u.id,
          u.email,
          u.nombre,
          u.telefono,
          u.codigo,
          u.estado,
          u.activo,
          u.created_at,
          u.updated_at,
          d.id as docente_id
        FROM users u
        LEFT JOIN docentes d ON u.id = d.user_id
        WHERE u.rol = 'docente'
        ORDER BY u.nombre ASC
      `);

      // Para cada docente, obtener estadísticas de reservas
      const docentesConInfo = await Promise.all(
        docentes.map(async (docente) => {
          // Obtener estadísticas de reservas
          const estadisticas = await db.get(`
            SELECT 
              COUNT(*) as total_reservas,
              SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as reservas_pendientes,
              SUM(CASE WHEN estado = 'aprobada' THEN 1 ELSE 0 END) as reservas_aprobadas,
              SUM(CASE WHEN estado = 'rechazada' THEN 1 ELSE 0 END) as reservas_rechazadas
            FROM reservas
            WHERE docente_id = ?
          `, [docente.id]);

          return {
            ...docente,
            estadisticas: estadisticas || {
              total_reservas: 0,
              reservas_pendientes: 0,
              reservas_aprobadas: 0,
              reservas_rechazadas: 0
            }
          };
        })
      );

      console.log(`✅ ${docentesConInfo.length} docentes obtenidos`);

      res.json({
        success: true,
        data: docentesConInfo
      });
    } catch (error) {
      console.error('❌ Error obteniendo docentes:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo docentes',
        error: error.message
      });
    }
  };

  // ==========================================
  // OBTENER DOCENTE POR ID CON DETALLE
  // ==========================================
  getById = async (req, res) => {
    try {
      const { id } = req.params;
      console.log(`👤 Obteniendo docente ${id}...`);

      // Obtener datos del docente
      const docente = await db.get(`
        SELECT 
          u.id,
          u.email,
          u.nombre,
          u.telefono,
          u.codigo,
          u.estado,
          u.activo,
          u.created_at,
          u.updated_at,
          d.id as docente_id,
          d.created_at as fecha_registro_docente
        FROM users u
        LEFT JOIN docentes d ON u.id = d.user_id
        WHERE u.id = ? AND u.rol = 'docente'
      `, [id]);

      if (!docente) {
        return res.status(404).json({
          success: false,
          message: 'Docente no encontrado'
        });
      }

      // Obtener reservas recientes
      const reservasRecientes = await db.all(`
        SELECT 
          r.id,
          r.fecha,
          r.hora_inicio,
          r.hora_fin,
          r.materia,
          r.estado,
          l.nombre as laboratorio_nombre,
          l.codigo as laboratorio_codigo
        FROM reservas r
        INNER JOIN laboratorios l ON r.laboratorio_id = l.id
        WHERE r.docente_id = ?
        ORDER BY r.fecha DESC, r.hora_inicio DESC
        LIMIT 10
      `, [id]);

      // Obtener estadísticas completas
      const estadisticas = await db.get(`
        SELECT 
          COUNT(*) as total_reservas,
          SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as reservas_pendientes,
          SUM(CASE WHEN estado = 'aprobada' THEN 1 ELSE 0 END) as reservas_aprobadas,
          SUM(CASE WHEN estado = 'rechazada' THEN 1 ELSE 0 END) as reservas_rechazadas,
          SUM(CASE WHEN estado = 'cancelada' THEN 1 ELSE 0 END) as reservas_canceladas
        FROM reservas
        WHERE docente_id = ?
      `, [id]);

      // Laboratorios más reservados
      const laboratoriosFrecuentes = await db.all(`
        SELECT 
          l.id,
          l.nombre,
          l.codigo,
          COUNT(*) as cantidad_reservas
        FROM reservas r
        INNER JOIN laboratorios l ON r.laboratorio_id = l.id
        WHERE r.docente_id = ?
        GROUP BY l.id, l.nombre, l.codigo
        ORDER BY cantidad_reservas DESC
        LIMIT 5
      `, [id]);

      console.log(`✅ Docente ${id} obtenido con detalle completo`);

      res.json({
        success: true,
        data: {
          docente,
          reservas_recientes: reservasRecientes,
          laboratorios_frecuentes: laboratoriosFrecuentes,
          estadisticas: estadisticas || {
            total_reservas: 0,
            reservas_pendientes: 0,
            reservas_aprobadas: 0,
            reservas_rechazadas: 0,
            reservas_canceladas: 0
          }
        }
      });
    } catch (error) {
      console.error('❌ Error obteniendo docente:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo docente',
        error: error.message
      });
    }
  };

  // ==========================================
  // CREAR DOCENTE
  // ==========================================
  create = async (req, res) => {
    try {
      const { email, password, nombre, telefono, codigo } = req.body;
      const adminId = req.user.id;

      console.log('➕ Creando nuevo docente:', nombre);

      // Validaciones
      if (!email || !password || !nombre || !codigo || !telefono) {
        return res.status(400).json({
          success: false,
          message: 'Email, contraseña, nombre, código y teléfono son requeridos'
        });
      }

      // Validar formato de código (opcional)
      if (!/^[A-Z0-9-]+$/i.test(codigo)) {
        return res.status(400).json({
          success: false,
          message: 'El código solo puede contener letras, números y guiones'
        });
      }

      // Verificar si el email ya existe
      const existingEmail = await db.get(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if (existingEmail) {
        return res.status(400).json({
          success: false,
          message: 'El email ya está registrado'
        });
      }

      // Verificar si el código ya existe
      const existingCodigo = await db.get(
        'SELECT id FROM users WHERE codigo = ?',
        [codigo]
      );

      if (existingCodigo) {
        return res.status(400).json({
          success: false,
          message: 'El código ya está registrado'
        });
      }

      // Verificar si el código existe en tabla docentes
      const existingCodigoDocente = await db.get(
        'SELECT id FROM docentes WHERE codigo = ?',
        [codigo]
      );

      if (existingCodigoDocente) {
        return res.status(400).json({
          success: false,
          message: 'El código ya está en uso'
        });
      }

      // Encriptar contraseña
      const hashedPassword = await bcrypt.hash(password, 10);

      // Crear usuario
      const resultUser = await db.run(`
        INSERT INTO users (
          email, 
          password, 
          nombre, 
          rol, 
          codigo,
          telefono, 
          estado,
          activo
        ) VALUES (?, ?, ?, 'docente', ?, ?, 'activo', 1)
      `, [email, hashedPassword, nombre, codigo, telefono]);

      // Crear registro en tabla docentes
      await db.run(`
        INSERT INTO docentes (
          user_id,
          codigo,
          created_by
        ) VALUES (?, ?, ?)
      `, [resultUser.id, codigo, adminId]);

      console.log(`✅ Docente creado con ID: ${resultUser.id}`);

      // Obtener el docente creado
      const docente = await db.get(`
        SELECT 
          u.id, 
          u.email, 
          u.nombre, 
          u.telefono, 
          u.codigo,
          u.estado, 
          u.activo, 
          u.created_at,
          d.id as docente_id
        FROM users u
        LEFT JOIN docentes d ON u.id = d.user_id
        WHERE u.id = ?
      `, [resultUser.id]);

      res.status(201).json({
        success: true,
        message: 'Docente creado exitosamente',
        data: docente
      });
    } catch (error) {
      console.error('❌ Error creando docente:', error);
      res.status(500).json({
        success: false,
        message: 'Error creando docente',
        error: error.message
      });
    }
  };

  // ==========================================
  // ACTUALIZAR DOCENTE
  // ==========================================
  update = async (req, res) => {
    try {
      const { id } = req.params;
      const { nombre, email, telefono, codigo, estado, password } = req.body;

      console.log(`✏️ Actualizando docente ${id}...`);

      // Verificar que existe
      const docente = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "docente"',
        [id]
      );

      if (!docente) {
        return res.status(404).json({
          success: false,
          message: 'Docente no encontrado'
        });
      }

      // Si se proporciona email, verificar que no esté en uso
      if (email) {
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

      // Si se proporciona código, verificar que no esté en uso
      if (codigo) {
        // Validar formato
        if (!/^[A-Z0-9-]+$/i.test(codigo)) {
          return res.status(400).json({
            success: false,
            message: 'El código solo puede contener letras, números y guiones'
          });
        }

        const existingCodigo = await db.get(
          'SELECT id FROM users WHERE codigo = ? AND id != ?',
          [codigo, id]
        );

        if (existingCodigo) {
          return res.status(400).json({
            success: false,
            message: 'El código ya está en uso'
          });
        }

        // También verificar en tabla docentes
        const existingCodigoDocente = await db.get(
          'SELECT id FROM docentes WHERE codigo = ? AND user_id != ?',
          [codigo, id]
        );

        if (existingCodigoDocente) {
          return res.status(400).json({
            success: false,
            message: 'El código ya está en uso'
          });
        }
      }

      // Preparar campos a actualizar en users
      const updates = [];
      const params = [];

      if (nombre !== undefined) {
        updates.push('nombre = ?');
        params.push(nombre);
      }
      if (email !== undefined) {
        updates.push('email = ?');
        params.push(email);
      }
      if (telefono !== undefined) {
        updates.push('telefono = ?');
        params.push(telefono);
      }
      if (codigo !== undefined) {
        updates.push('codigo = ?');
        params.push(codigo);
      }
      if (estado !== undefined) {
        updates.push('estado = ?');
        params.push(estado);
      }
      if (password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        updates.push('password = ?');
        params.push(hashedPassword);
      }

      updates.push('updated_at = CURRENT_TIMESTAMP');
      params.push(id);

      // Actualizar usuario
      await db.run(`
        UPDATE users 
        SET ${updates.join(', ')}
        WHERE id = ?
      `, params);

      // Si se actualiza el código, actualizar también en tabla docentes
      if (codigo !== undefined) {
        await db.run(`
          UPDATE docentes
          SET codigo = ?, updated_at = CURRENT_TIMESTAMP
          WHERE user_id = ?
        `, [codigo, id]);
      }

      // Obtener docente actualizado
      const docenteActualizado = await db.get(`
        SELECT 
          u.id, 
          u.email, 
          u.nombre, 
          u.telefono,
          u.codigo, 
          u.estado, 
          u.activo, 
          u.updated_at,
          d.id as docente_id
        FROM users u
        LEFT JOIN docentes d ON u.id = d.user_id
        WHERE u.id = ?
      `, [id]);

      console.log(`✅ Docente ${id} actualizado`);

      res.json({
        success: true,
        message: 'Docente actualizado exitosamente',
        data: docenteActualizado
      });
    } catch (error) {
      console.error('❌ Error actualizando docente:', error);
      res.status(500).json({
        success: false,
        message: 'Error actualizando docente',
        error: error.message
      });
    }
  };

  // ==========================================
  // ELIMINAR DOCENTE
  // ==========================================
  delete = async (req, res) => {
    try {
      const { id } = req.params;
      console.log(`🗑️ Eliminando docente ${id}...`);

      // Verificar que existe
      const docente = await db.get(
        'SELECT id, nombre FROM users WHERE id = ? AND rol = "docente"',
        [id]
      );

      if (!docente) {
        return res.status(404).json({
          success: false,
          message: 'Docente no encontrado'
        });
      }

      // Verificar si tiene reservas pendientes o aprobadas
      const reservasActivas = await db.get(`
        SELECT COUNT(*) as total
        FROM reservas
        WHERE docente_id = ? AND estado IN ('pendiente', 'aprobada')
      `, [id]);

      if (reservasActivas.total > 0) {
        return res.status(400).json({
          success: false,
          message: `No se puede eliminar: tiene ${reservasActivas.total} reserva(s) activa(s)`,
          data: { reservas_activas: reservasActivas.total }
        });
      }

      // Eliminar (el registro en docentes y reservas se elimina por CASCADE)
      await db.run('DELETE FROM users WHERE id = ?', [id]);

      console.log(`✅ Docente ${docente.nombre} eliminado`);

      res.json({
        success: true,
        message: 'Docente eliminado exitosamente'
      });
    } catch (error) {
      console.error('❌ Error eliminando docente:', error);
      res.status(500).json({
        success: false,
        message: 'Error eliminando docente',
        error: error.message
      });
    }
  };

  // ==========================================
  // CAMBIAR ESTADO ACTIVO/INACTIVO
  // ==========================================
  cambiarEstado = async (req, res) => {
    try {
      const { id } = req.params;
      const { estado } = req.body; // activo, inactivo

      console.log(`🔄 Cambiando estado de docente ${id} a ${estado}...`);

      // Validar estado
      const estadosValidos = ['activo', 'inactivo'];
      if (!estadosValidos.includes(estado)) {
        return res.status(400).json({
          success: false,
          message: 'Estado inválido. Use: activo o inactivo'
        });
      }

      // Verificar que existe
      const docente = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "docente"',
        [id]
      );

      if (!docente) {
        return res.status(404).json({
          success: false,
          message: 'Docente no encontrado'
        });
      }

      // Actualizar estado
      await db.run(`
        UPDATE users 
        SET estado = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [estado, id]);

      console.log(`✅ Estado cambiado a ${estado}`);

      res.json({
        success: true,
        message: 'Estado actualizado exitosamente',
        data: { estado }
      });
    } catch (error) {
      console.error('❌ Error cambiando estado:', error);
      res.status(500).json({
        success: false,
        message: 'Error cambiando estado',
        error: error.message
      });
    }
  };
}

module.exports = new DocentesController();