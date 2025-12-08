// src/controllers/auxiliaresController.js

const db = require('../config/database');
const bcrypt = require('bcryptjs');

class AuxiliaresController {
  // ==========================================
  // OBTENER TODOS LOS AUXILIARES CON INFO
  // ==========================================
  getAll = async (req, res) => {
    try {
      console.log('👥 Obteniendo lista de auxiliares...');

      // Obtener todos los usuarios con rol auxiliar
      const auxiliares = await db.all(`
        SELECT 
          id,
          email,
          nombre,
          telefono,
          estado,
          notas,
          activo,
          created_at,
          updated_at
        FROM users 
        WHERE rol = 'auxiliar'
        ORDER BY nombre ASC
      `);

      // Para cada auxiliar, obtener sus laboratorios y horarios
      const auxiliaresConInfo = await Promise.all(
        auxiliares.map(async (auxiliar) => {
          // Obtener laboratorios asignados
          const laboratorios = await db.all(`
            SELECT 
              l.id,
              l.nombre,
              l.codigo,
              al.created_at as fecha_asignacion
            FROM auxiliares_laboratorios al
            INNER JOIN laboratorios l ON al.laboratorio_id = l.id
            WHERE al.auxiliar_id = ?
            ORDER BY l.nombre ASC
          `, [auxiliar.id]);

          // Obtener horarios
          const horarios = await db.all(`
            SELECT 
              id,
              dia_semana,
              hora_inicio,
              hora_fin,
              created_at
            FROM auxiliares_horarios
            WHERE auxiliar_id = ?
            ORDER BY 
              CASE dia_semana
                WHEN 'lunes' THEN 1
                WHEN 'martes' THEN 2
                WHEN 'miércoles' THEN 3
                WHEN 'jueves' THEN 4
                WHEN 'viernes' THEN 5
                WHEN 'sábado' THEN 6
                WHEN 'domingo' THEN 7
              END
          `, [auxiliar.id]);

          // Calcular total de horas semanales
          let totalHoras = 0;
          horarios.forEach(horario => {
            const [horaInicioH, horaInicioM] = horario.hora_inicio.split(':');
            const [horaFinH, horaFinM] = horario.hora_fin.split(':');
            const inicio = parseInt(horaInicioH) * 60 + parseInt(horaInicioM);
            const fin = parseInt(horaFinH) * 60 + parseInt(horaFinM);
            totalHoras += (fin - inicio) / 60;
          });

          return {
            ...auxiliar,
            laboratorios,
            horarios,
            cantidad_laboratorios: laboratorios.length,
            horas_semanales: Math.round(totalHoras * 10) / 10
          };
        })
      );

      console.log(`✅ ${auxiliaresConInfo.length} auxiliares obtenidos`);

      res.json({
        success: true,
        data: auxiliaresConInfo
      });
    } catch (error) {
      console.error('❌ Error obteniendo auxiliares:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo auxiliares',
        error: error.message
      });
    }
  };

  // ==========================================
  // OBTENER AUXILIAR POR ID CON DETALLE
  // ==========================================
  getById = async (req, res) => {
    try {
      const { id } = req.params;
      console.log(`👤 Obteniendo auxiliar ${id}...`);

      // Obtener datos del auxiliar
      const auxiliar = await db.get(`
        SELECT 
          id,
          email,
          nombre,
          telefono,
          estado,
          notas,
          activo,
          created_at,
          updated_at
        FROM users 
        WHERE id = ? AND rol = 'auxiliar'
      `, [id]);

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
        });
      }

      // Obtener laboratorios asignados con más detalle
      const laboratorios = await db.all(`
        SELECT 
          l.id,
          l.nombre,
          l.codigo,
          l.ubicacion,
          l.estado,
          al.created_at as fecha_asignacion,
          u.nombre as asignado_por
        FROM auxiliares_laboratorios al
        INNER JOIN laboratorios l ON al.laboratorio_id = l.id
        LEFT JOIN users u ON al.created_by = u.id
        WHERE al.auxiliar_id = ?
        ORDER BY l.nombre ASC
      `, [id]);

      // Obtener horarios
      const horarios = await db.all(`
        SELECT 
          id,
          dia_semana,
          hora_inicio,
          hora_fin,
          created_at,
          updated_at
        FROM auxiliares_horarios
        WHERE auxiliar_id = ?
        ORDER BY 
          CASE dia_semana
            WHEN 'lunes' THEN 1
            WHEN 'martes' THEN 2
            WHEN 'miércoles' THEN 3
            WHEN 'jueves' THEN 4
            WHEN 'viernes' THEN 5
            WHEN 'sábado' THEN 6
            WHEN 'domingo' THEN 7
          END
      `, [id]);

      // Calcular estadísticas
      let totalHoras = 0;
      const horasPorDia = {};
      
      horarios.forEach(horario => {
        const [horaInicioH, horaInicioM] = horario.hora_inicio.split(':');
        const [horaFinH, horaFinM] = horario.hora_fin.split(':');
        const inicio = parseInt(horaInicioH) * 60 + parseInt(horaInicioM);
        const fin = parseInt(horaFinH) * 60 + parseInt(horaFinM);
        const horas = (fin - inicio) / 60;
        
        totalHoras += horas;
        horasPorDia[horario.dia_semana] = horas;
      });

      // Obtener estadísticas de tareas
      const estadisticasTareas = await db.get(`
        SELECT 
          COUNT(*) as total_tareas,
          SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as tareas_completadas,
          SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as tareas_pendientes
        FROM tareas
        WHERE auxiliar_id = ?
      `, [id]);

      console.log(`✅ Auxiliar ${id} obtenido con detalle completo`);

      res.json({
        success: true,
        data: {
          auxiliar,
          laboratorios,
          horarios,
          estadisticas: {
            cantidad_laboratorios: laboratorios.length,
            horas_semanales: Math.round(totalHoras * 10) / 10,
            horas_por_dia: horasPorDia,
            cantidad_dias: horarios.length,
            ...estadisticasTareas
          }
        }
      });
    } catch (error) {
      console.error('❌ Error obteniendo auxiliar:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo auxiliar',
        error: error.message
      });
    }
  };

  // ==========================================
  // CREAR AUXILIAR
  // ==========================================
  create = async (req, res) => {
    try {
      const { email, password, nombre, telefono, estado, notas } = req.body;
      const adminId = req.user.id;

      console.log('➕ Creando nuevo auxiliar:', nombre);

      // Validaciones
      if (!email || !password || !nombre) {
        return res.status(400).json({
          success: false,
          message: 'Email, contraseña y nombre son requeridos'
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

      // Crear auxiliar
      const result = await db.run(`
        INSERT INTO users (
          email, 
          password, 
          nombre, 
          rol, 
          telefono, 
          estado, 
          notas,
          activo
        ) VALUES (?, ?, ?, 'auxiliar', ?, ?, ?, 1)
      `, [email, hashedPassword, nombre, telefono || null, estado || 'activo', notas || null]);

      console.log(`✅ Auxiliar creado con ID: ${result.id}`);

      // Obtener el auxiliar creado
      const auxiliar = await db.get(`
        SELECT 
          id, email, nombre, telefono, estado, notas, activo, created_at
        FROM users 
        WHERE id = ?
      `, [result.id]);

      res.status(201).json({
        success: true,
        message: 'Auxiliar creado exitosamente',
        data: auxiliar
      });
    } catch (error) {
      console.error('❌ Error creando auxiliar:', error);
      res.status(500).json({
        success: false,
        message: 'Error creando auxiliar',
        error: error.message
      });
    }
  };

  // ==========================================
  // ACTUALIZAR AUXILIAR
  // ==========================================
  update = async (req, res) => {
    try {
      const { id } = req.params;
      const { nombre, email, telefono, estado, notas, password } = req.body;

      console.log(`✏️ Actualizando auxiliar ${id}...`);

      // Verificar que existe
      const auxiliar = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "auxiliar"',
        [id]
      );

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
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

      // Preparar campos a actualizar
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
      if (estado !== undefined) {
        updates.push('estado = ?');
        params.push(estado);
      }
      if (notas !== undefined) {
        updates.push('notas = ?');
        params.push(notas);
      }
      if (password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        updates.push('password = ?');
        params.push(hashedPassword);
      }

      updates.push('updated_at = CURRENT_TIMESTAMP');
      params.push(id);

      // Actualizar
      await db.run(`
        UPDATE users 
        SET ${updates.join(', ')}
        WHERE id = ?
      `, params);

      // Obtener auxiliar actualizado
      const auxiliarActualizado = await db.get(`
        SELECT 
          id, email, nombre, telefono, estado, notas, activo, updated_at
        FROM users 
        WHERE id = ?
      `, [id]);

      console.log(`✅ Auxiliar ${id} actualizado`);

      res.json({
        success: true,
        message: 'Auxiliar actualizado exitosamente',
        data: auxiliarActualizado
      });
    } catch (error) {
      console.error('❌ Error actualizando auxiliar:', error);
      res.status(500).json({
        success: false,
        message: 'Error actualizando auxiliar',
        error: error.message
      });
    }
  };

  // ==========================================
  // ELIMINAR AUXILIAR
  // ==========================================
  delete = async (req, res) => {
    try {
      const { id } = req.params;
      console.log(`🗑️ Eliminando auxiliar ${id}...`);

      // Verificar que existe
      const auxiliar = await db.get(
        'SELECT id, nombre FROM users WHERE id = ? AND rol = "auxiliar"',
        [id]
      );

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
        });
      }

      // Eliminar (las asignaciones y horarios se eliminan por CASCADE)
      await db.run('DELETE FROM users WHERE id = ?', [id]);

      console.log(`✅ Auxiliar ${auxiliar.nombre} eliminado`);

      res.json({
        success: true,
        message: 'Auxiliar eliminado exitosamente'
      });
    } catch (error) {
      console.error('❌ Error eliminando auxiliar:', error);
      res.status(500).json({
        success: false,
        message: 'Error eliminando auxiliar',
        error: error.message
      });
    }
  };

  // ==========================================
  // ASIGNAR LABORATORIOS
  // ==========================================
  asignarLaboratorios = async (req, res) => {
    try {
      const { id } = req.params;
      const { laboratorios } = req.body; // Array de IDs
      const adminId = req.user.id;

      console.log(`🧪 Asignando laboratorios a auxiliar ${id}...`);

      // Validar
      if (!Array.isArray(laboratorios)) {
        return res.status(400).json({
          success: false,
          message: 'Se esperaba un array de IDs de laboratorios'
        });
      }

      // Verificar que el auxiliar existe
      const auxiliar = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "auxiliar"',
        [id]
      );

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
        });
      }

      // Eliminar asignaciones anteriores
      await db.run(
        'DELETE FROM auxiliares_laboratorios WHERE auxiliar_id = ?',
        [id]
      );

      // Insertar nuevas asignaciones
      for (const labId of laboratorios) {
        await db.run(`
          INSERT INTO auxiliares_laboratorios (
            auxiliar_id, 
            laboratorio_id, 
            created_by
          ) VALUES (?, ?, ?)
        `, [id, labId, adminId]);
      }

      console.log(`✅ ${laboratorios.length} laboratorios asignados`);

      res.json({
        success: true,
        message: 'Laboratorios asignados exitosamente',
        data: {
          auxiliar_id: id,
          laboratorios_asignados: laboratorios.length
        }
      });
    } catch (error) {
      console.error('❌ Error asignando laboratorios:', error);
      res.status(500).json({
        success: false,
        message: 'Error asignando laboratorios',
        error: error.message
      });
    }
  };

  // ==========================================
  // ASIGNAR HORARIOS
  // ==========================================
  asignarHorarios = async (req, res) => {
    try {
      const { id } = req.params;
      const { horarios } = req.body; // Array de {dia_semana, hora_inicio, hora_fin}
      const adminId = req.user.id;

      console.log(`📅 Asignando horarios a auxiliar ${id}...`);

      // Validar
      if (!Array.isArray(horarios)) {
        return res.status(400).json({
          success: false,
          message: 'Se esperaba un array de horarios'
        });
      }

      // Verificar que el auxiliar existe
      const auxiliar = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "auxiliar"',
        [id]
      );

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
        });
      }

      // Validar horarios
      const diasValidos = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
      for (const horario of horarios) {
        if (!diasValidos.includes(horario.dia_semana)) {
          return res.status(400).json({
            success: false,
            message: `Día inválido: ${horario.dia_semana}`
          });
        }

        // Validar formato de horas
        const regexHora = /^([01]\d|2[0-3]):([0-5]\d)$/;
        if (!regexHora.test(horario.hora_inicio) || !regexHora.test(horario.hora_fin)) {
          return res.status(400).json({
            success: false,
            message: 'Formato de hora inválido (use HH:MM)'
          });
        }

        // Validar que hora_inicio < hora_fin
        if (horario.hora_inicio >= horario.hora_fin) {
          return res.status(400).json({
            success: false,
            message: 'La hora de inicio debe ser menor a la hora de fin'
          });
        }
      }

      // Eliminar horarios anteriores
      await db.run(
        'DELETE FROM auxiliares_horarios WHERE auxiliar_id = ?',
        [id]
      );

      // Insertar nuevos horarios
      for (const horario of horarios) {
        await db.run(`
          INSERT INTO auxiliares_horarios (
            auxiliar_id,
            dia_semana,
            hora_inicio,
            hora_fin,
            created_by
          ) VALUES (?, ?, ?, ?, ?)
        `, [id, horario.dia_semana, horario.hora_inicio, horario.hora_fin, adminId]);
      }

      console.log(`✅ ${horarios.length} horarios asignados`);

      res.json({
        success: true,
        message: 'Horarios asignados exitosamente',
        data: {
          auxiliar_id: id,
          horarios_asignados: horarios.length
        }
      });
    } catch (error) {
      console.error('❌ Error asignando horarios:', error);
      res.status(500).json({
        success: false,
        message: 'Error asignando horarios',
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
      const { estado } = req.body; // activo, inactivo, vacaciones, licencia

      console.log(`🔄 Cambiando estado de auxiliar ${id} a ${estado}...`);

      // Validar estado
      const estadosValidos = ['activo', 'inactivo', 'vacaciones', 'licencia'];
      if (!estadosValidos.includes(estado)) {
        return res.status(400).json({
          success: false,
          message: 'Estado inválido'
        });
      }

      // Verificar que existe
      const auxiliar = await db.get(
        'SELECT id FROM users WHERE id = ? AND rol = "auxiliar"',
        [id]
      );

      if (!auxiliar) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
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

module.exports = new AuxiliaresController();