// src/controllers/reservasController.js

const db = require('../config/database');

class ReservasController {
  // ==========================================
  // OBTENER TODAS LAS RESERVAS (SEGÚN ROL)
  // ==========================================
  async getAll(req, res) {
    try {
      const user = req.user;
      let reservas;

      console.log(`📅 Obteniendo reservas para usuario ${user.id} (${user.rol})...`);

      if (user.rol === 'admin') {
        // Admin ve todas las reservas
        reservas = await db.all(`
          SELECT 
            r.*,
            u.nombre as docente_nombre,
            u.email as docente_email,
            u.codigo as docente_codigo,
            l.nombre as laboratorio_nombre,
            l.codigo as laboratorio_codigo,
            l.ubicacion as laboratorio_ubicacion
          FROM reservas r
          INNER JOIN users u ON r.docente_id = u.id
          INNER JOIN laboratorios l ON r.laboratorio_id = l.id
          ORDER BY r.fecha DESC, r.hora_inicio DESC
        `);

        console.log(`✅ Admin: ${reservas.length} reservas obtenidas`);

      } else if (user.rol === 'docente') {
        // Docente solo ve sus propias reservas
        reservas = await db.all(`
          SELECT 
            r.*,
            u.nombre as docente_nombre,
            u.email as docente_email,
            u.codigo as docente_codigo,
            l.nombre as laboratorio_nombre,
            l.codigo as laboratorio_codigo,
            l.ubicacion as laboratorio_ubicacion
          FROM reservas r
          INNER JOIN users u ON r.docente_id = u.id
          INNER JOIN laboratorios l ON r.laboratorio_id = l.id
          WHERE r.docente_id = ?
          ORDER BY r.fecha DESC, r.hora_inicio DESC
        `, [user.id]);

        console.log(`✅ Docente: ${reservas.length} reservas propias obtenidas`);

      } else if (user.rol === 'auxiliar') {
        // Auxiliar ve TODAS las reservas APROBADAS (sin filtro de laboratorios)
        console.log(`🔍 Auxiliar ${user.id} obteniendo todas las reservas aprobadas...`);
        
        reservas = await db.all(`
          SELECT 
            r.*,
            u.nombre as docente_nombre,
            u.email as docente_email,
            u.codigo as docente_codigo,
            l.nombre as laboratorio_nombre,
            l.codigo as laboratorio_codigo,
            l.ubicacion as laboratorio_ubicacion
          FROM reservas r
          INNER JOIN users u ON r.docente_id = u.id
          INNER JOIN laboratorios l ON r.laboratorio_id = l.id
          WHERE r.estado = 'aprobada'
          ORDER BY r.fecha DESC, r.hora_inicio DESC
        `);

        console.log(`✅ Auxiliar: ${reservas.length} reservas aprobadas encontradas (todas)`);
      }

      res.json({
        success: true,
        data: reservas
      });
    } catch (error) {
      console.error('❌ Error obteniendo reservas:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // OBTENER RESERVA POR ID
  // ==========================================
  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = req.user;

      console.log(`📋 Obteniendo reserva ${id}...`);

      const reserva = await db.get(`
        SELECT 
          r.*,
          u.nombre as docente_nombre,
          u.email as docente_email,
          u.codigo as docente_codigo,
          u.telefono as docente_telefono,
          l.nombre as laboratorio_nombre,
          l.codigo as laboratorio_codigo,
          l.ubicacion as laboratorio_ubicacion,
          l.capacidad as laboratorio_capacidad,
          admin.nombre as aprobada_por_nombre
        FROM reservas r
        INNER JOIN users u ON r.docente_id = u.id
        INNER JOIN laboratorios l ON r.laboratorio_id = l.id
        LEFT JOIN users admin ON r.aprobada_por = admin.id
        WHERE r.id = ?
      `, [id]);

      if (!reserva) {
        return res.status(404).json({
          success: false,
          message: 'Reserva no encontrada'
        });
      }

      // Verificar permisos según rol
      if (user.rol === 'docente' && reserva.docente_id !== user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes acceso a esta reserva'
        });
      }

      if (user.rol === 'auxiliar') {
        // Verificar que sea de sus laboratorios y esté aprobada
        const esDelAuxiliar = await db.get(`
          SELECT 1 FROM auxiliares_laboratorios
          WHERE auxiliar_id = ? AND laboratorio_id = ?
        `, [user.id, reserva.laboratorio_id]);

        if (!esDelAuxiliar || reserva.estado !== 'aprobada') {
          return res.status(403).json({
            success: false,
            message: 'No tienes acceso a esta reserva'
          });
        }
      }

      console.log(`✅ Reserva obtenida: ${reserva.materia}`);

      res.json({
        success: true,
        data: reserva
      });
    } catch (error) {
      console.error('❌ Error obteniendo reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // CREAR RESERVA (SOLO DOCENTES)
  // ==========================================
  async create(req, res) {
    try {
      const {
        laboratorio_id,
        fecha,
        hora_inicio,
        hora_fin,
        materia,
        descripcion
      } = req.body;

      const docente_id = req.user.id;

      console.log('📝 Creando nueva reserva:', {
        docente_id,
        laboratorio_id,
        fecha,
        hora_inicio,
        hora_fin,
        materia
      });

      // ==========================================
      // VALIDACIONES
      // ==========================================

      // 1. Campos requeridos
      if (!laboratorio_id || !fecha || !hora_inicio || !hora_fin || !materia) {
        return res.status(400).json({
          success: false,
          message: 'Todos los campos son requeridos'
        });
      }

      // 2. Verificar que el laboratorio existe y está activo
      const laboratorio = await db.get(
        'SELECT id, nombre, estado FROM laboratorios WHERE id = ?',
        [laboratorio_id]
      );

      if (!laboratorio) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      if (laboratorio.estado !== 'activo') {
        return res.status(400).json({
          success: false,
          message: 'El laboratorio no está disponible'
        });
      }

      // 3. Validar formato de fecha (YYYY-MM-DD)
      if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
        return res.status(400).json({
          success: false,
          message: 'Formato de fecha inválido (usar YYYY-MM-DD)'
        });
      }

      // 4. Validar formato de hora (HH:MM)
      const regexHora = /^([01]\d|2[0-3]):([0-5]\d)$/;
      if (!regexHora.test(hora_inicio) || !regexHora.test(hora_fin)) {
        return res.status(400).json({
          success: false,
          message: 'Formato de hora inválido (usar HH:MM)'
        });
      }

      // 5. Validar que la fecha no sea pasada
      const fechaReserva = new Date(fecha + 'T00:00:00');
      const hoy = new Date();
      hoy.setHours(0, 0, 0, 0);

      if (fechaReserva < hoy) {
        return res.status(400).json({
          success: false,
          message: 'No se pueden hacer reservas en fechas pasadas'
        });
      }

      // 6. Validar que hora_inicio < hora_fin
      const [inicioH, inicioM] = hora_inicio.split(':').map(Number);
      const [finH, finM] = hora_fin.split(':').map(Number);
      const inicioMinutos = inicioH * 60 + inicioM;
      const finMinutos = finH * 60 + finM;

      if (inicioMinutos >= finMinutos) {
        return res.status(400).json({
          success: false,
          message: 'La hora de inicio debe ser menor a la hora de fin'
        });
      }

      // 7. Validar duración (mínimo 30 min, máximo 8 horas)
      const duracionMinutos = finMinutos - inicioMinutos;
      if (duracionMinutos < 30) {
        return res.status(400).json({
          success: false,
          message: 'La duración mínima es de 30 minutos'
        });
      }

      if (duracionMinutos > 480) {
        return res.status(400).json({
          success: false,
          message: 'La duración máxima es de 8 horas'
        });
      }

      // 8. Validar anticipación mínima (24 horas)
      const ahora = new Date();
      const fechaHoraReserva = new Date(`${fecha}T${hora_inicio}:00`);
      const diferenciaHoras = (fechaHoraReserva - ahora) / (1000 * 60 * 60);

      if (diferenciaHoras < 24) {
        return res.status(400).json({
          success: false,
          message: 'Debes reservar con al menos 24 horas de anticipación'
        });
      }

      // 9. Verificar overlap con reservas APROBADAS del mismo laboratorio
      const overlap = await db.get(`
        SELECT id FROM reservas
        WHERE laboratorio_id = ?
          AND fecha = ?
          AND estado = 'aprobada'
          AND (
            (hora_inicio < ? AND hora_fin > ?) OR
            (hora_inicio < ? AND hora_fin > ?) OR
            (hora_inicio >= ? AND hora_fin <= ?)
          )
      `, [
        laboratorio_id,
        fecha,
        hora_fin, hora_inicio,
        hora_fin, hora_inicio,
        hora_inicio, hora_fin
      ]);

      if (overlap) {
        return res.status(400).json({
          success: false,
          message: 'Ya existe una reserva aprobada en ese horario para este laboratorio'
        });
      }

      // ==========================================
      // CREAR RESERVA
      // ==========================================

      const result = await db.run(`
        INSERT INTO reservas (
          docente_id,
          laboratorio_id,
          fecha,
          hora_inicio,
          hora_fin,
          materia,
          descripcion,
          estado
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'pendiente')
      `, [
        docente_id,
        laboratorio_id,
        fecha,
        hora_inicio,
        hora_fin,
        materia.trim(),
        descripcion ? descripcion.trim() : null
      ]);

      console.log(`✅ Reserva creada con ID: ${result.id}`);

      res.status(201).json({
        success: true,
        message: 'Reserva creada exitosamente. Espera la aprobación del administrador.',
        data: {
          id: result.id,
          estado: 'pendiente'
        }
      });
    } catch (error) {
      console.error('❌ Error creando reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // APROBAR RESERVA (SOLO ADMIN)
  // ==========================================
  async aprobar(req, res) {
    try {
      const { id } = req.params;
      const admin_id = req.user.id;

      console.log(`✅ Admin ${admin_id} aprobando reserva ${id}...`);

      const reserva = await db.get('SELECT * FROM reservas WHERE id = ?', [id]);

      if (!reserva) {
        return res.status(404).json({
          success: false,
          message: 'Reserva no encontrada'
        });
      }

      if (reserva.estado !== 'pendiente') {
        return res.status(400).json({
          success: false,
          message: `No se puede aprobar una reserva en estado '${reserva.estado}'`
        });
      }

      // Verificar nuevamente overlap antes de aprobar
      const overlap = await db.get(`
        SELECT id FROM reservas
        WHERE laboratorio_id = ?
          AND fecha = ?
          AND estado = 'aprobada'
          AND id != ?
          AND (
            (hora_inicio < ? AND hora_fin > ?) OR
            (hora_inicio < ? AND hora_fin > ?) OR
            (hora_inicio >= ? AND hora_fin <= ?)
          )
      `, [
        reserva.laboratorio_id,
        reserva.fecha,
        id,
        reserva.hora_fin, reserva.hora_inicio,
        reserva.hora_fin, reserva.hora_inicio,
        reserva.hora_inicio, reserva.hora_fin
      ]);

      if (overlap) {
        return res.status(400).json({
          success: false,
          message: 'Conflicto: ya existe otra reserva aprobada en ese horario'
        });
      }

      await db.run(`
        UPDATE reservas 
        SET estado = 'aprobada',
            aprobada_por = ?,
            aprobada_en = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [admin_id, id]);

      console.log(`✅ Reserva ${id} aprobada exitosamente`);

      res.json({
        success: true,
        message: 'Reserva aprobada exitosamente'
      });
    } catch (error) {
      console.error('❌ Error aprobando reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // RECHAZAR RESERVA (SOLO ADMIN)
  // ==========================================
  async rechazar(req, res) {
    try {
      const { id } = req.params;
      const { motivo_rechazo } = req.body;
      const admin_id = req.user.id;

      console.log(`❌ Admin ${admin_id} rechazando reserva ${id}...`);

      if (!motivo_rechazo || motivo_rechazo.trim() === '') {
        return res.status(400).json({
          success: false,
          message: 'El motivo de rechazo es requerido'
        });
      }

      const reserva = await db.get('SELECT * FROM reservas WHERE id = ?', [id]);

      if (!reserva) {
        return res.status(404).json({
          success: false,
          message: 'Reserva no encontrada'
        });
      }

      if (reserva.estado !== 'pendiente') {
        return res.status(400).json({
          success: false,
          message: `No se puede rechazar una reserva en estado '${reserva.estado}'`
        });
      }

      await db.run(`
        UPDATE reservas 
        SET estado = 'rechazada',
            motivo_rechazo = ?,
            aprobada_por = ?,
            aprobada_en = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [motivo_rechazo.trim(), admin_id, id]);

      console.log(`✅ Reserva ${id} rechazada: ${motivo_rechazo}`);

      res.json({
        success: true,
        message: 'Reserva rechazada'
      });
    } catch (error) {
      console.error('❌ Error rechazando reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // CANCELAR RESERVA (DOCENTE PROPIETARIO)
  // ==========================================
  async cancelar(req, res) {
    try {
      const { id } = req.params;
      const docente_id = req.user.id;

      console.log(`⚫ Docente ${docente_id} cancelando reserva ${id}...`);

      const reserva = await db.get(
        'SELECT * FROM reservas WHERE id = ? AND docente_id = ?',
        [id, docente_id]
      );

      if (!reserva) {
        return res.status(404).json({
          success: false,
          message: 'Reserva no encontrada o no tienes permiso'
        });
      }

      if (reserva.estado === 'cancelada') {
        return res.status(400).json({
          success: false,
          message: 'La reserva ya está cancelada'
        });
      }

      if (reserva.estado === 'aprobada') {
        return res.status(400).json({
          success: false,
          message: 'No puedes cancelar una reserva aprobada. Contacta al administrador.'
        });
      }

      await db.run(`
        UPDATE reservas 
        SET estado = 'cancelada',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [id]);

      console.log(`✅ Reserva ${id} cancelada por el docente`);

      res.json({
        success: true,
        message: 'Reserva cancelada exitosamente'
      });
    } catch (error) {
      console.error('❌ Error cancelando reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // ==========================================
  // ELIMINAR RESERVA (SOLO ADMIN)
  // ==========================================
  async delete(req, res) {
    try {
      const { id } = req.params;

      console.log(`🗑️ Eliminando reserva ${id}...`);

      const existe = await db.get('SELECT id FROM reservas WHERE id = ?', [id]);

      if (!existe) {
        return res.status(404).json({
          success: false,
          message: 'Reserva no encontrada'
        });
      }

      await db.run('DELETE FROM reservas WHERE id = ?', [id]);

      console.log(`✅ Reserva ${id} eliminada`);

      res.json({
        success: true,
        message: 'Reserva eliminada exitosamente'
      });
    } catch (error) {
      console.error('❌ Error eliminando reserva:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }
}

module.exports = new ReservasController();