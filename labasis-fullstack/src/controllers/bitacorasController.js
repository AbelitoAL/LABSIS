// src/controllers/bitacorasController.js

const db = require('../config/database');

class BitacorasController {
  // Obtener todas las bitácoras
  async getAll(req, res) {
    try {
      const { laboratorio_id, auxiliar_id, fecha_desde, fecha_hasta } = req.query;
      const user = req.user;

      let query = 'SELECT * FROM bitacoras WHERE 1=1';
      let params = [];

      // Filtros
      if (laboratorio_id) {
        query += ' AND laboratorio_id = ?';
        params.push(laboratorio_id);
      }

      if (auxiliar_id) {
        query += ' AND auxiliar_id = ?';
        params.push(auxiliar_id);
      }

      if (fecha_desde) {
        query += ' AND fecha >= ?';
        params.push(fecha_desde);
      }

      if (fecha_hasta) {
        query += ' AND fecha <= ?';
        params.push(fecha_hasta);
      }

      // Si no es admin, solo ver sus propias bitácoras
      if (user.rol !== 'admin') {
        query += ' AND auxiliar_id = ?';
        params.push(user.id);
      }

      query += ' ORDER BY fecha DESC, created_at DESC';

      const bitacoras = await db.all(query, params);

      // Parsear campos JSON
      const bitacorasFormateadas = bitacoras.map(bitacora => ({
        ...bitacora,
        atributos: bitacora.atributos ? JSON.parse(bitacora.atributos) : [],
        grilla: bitacora.grilla ? JSON.parse(bitacora.grilla) : {},
        resumen: bitacora.resumen ? JSON.parse(bitacora.resumen) : {}
      }));

      res.json({
        success: true,
        data: bitacorasFormateadas
      });
    } catch (error) {
      console.error('Error obteniendo bitácoras:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener bitácora por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const bitacora = await db.get('SELECT * FROM bitacoras WHERE id = ?', [id]);

      if (!bitacora) {
        return res.status(404).json({
          success: false,
          message: 'Bitácora no encontrada'
        });
      }

      // Verificar permisos
      if (req.user.rol !== 'admin' && bitacora.auxiliar_id !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes acceso a esta bitácora'
        });
      }

      const bitacoraFormateada = {
        ...bitacora,
        atributos: bitacora.atributos ? JSON.parse(bitacora.atributos) : [],
        grilla: bitacora.grilla ? JSON.parse(bitacora.grilla) : {},
        resumen: bitacora.resumen ? JSON.parse(bitacora.resumen) : {}
      };

      res.json({
        success: true,
        data: bitacoraFormateada
      });
    } catch (error) {
      console.error('Error obteniendo bitácora:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Crear bitácora (plantilla_id es OPCIONAL)
  async create(req, res) {
    try {
      const {
        nombre,
        plantilla_id,
        laboratorio_id,
        fecha,
        turno,
        atributos,
        grilla,
        resumen
      } = req.body;

      console.log('📝 Creando bitácora:', req.body);

      // Validación - SOLO nombre y laboratorio son obligatorios
      if (!nombre || !laboratorio_id) {
        return res.status(400).json({
          success: false,
          message: 'Nombre y laboratorio son requeridos'
        });
      }

      // Verificar que el laboratorio existe
      const laboratorio = await db.get('SELECT id, nombre FROM laboratorios WHERE id = ?', [laboratorio_id]);
      if (!laboratorio) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      // Verificar plantilla solo si se proporciona
      if (plantilla_id) {
        const plantilla = await db.get('SELECT id, nombre FROM plantillas WHERE id = ?', [plantilla_id]);
        if (!plantilla) {
          return res.status(404).json({
            success: false,
            message: 'Plantilla no encontrada'
          });
        }
      }

      console.log('✅ Validaciones pasadas, creando bitácora...');

      const result = await db.run(
        `INSERT INTO bitacoras (
          nombre, plantilla_id, laboratorio_id, fecha, turno,
          auxiliar_id, atributos, grilla, resumen, estado
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          nombre,
          plantilla_id || null,
          laboratorio_id,
          fecha || new Date().toISOString(),
          turno || 'mañana',
          req.user.id,
          JSON.stringify(atributos || []),
          JSON.stringify(grilla || {}),
          JSON.stringify(resumen || {}),
          'borrador'
        ]
      );

      console.log('✅ Bitácora creada con ID:', result.id);

      res.status(201).json({
        success: true,
        message: 'Bitácora creada exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('❌ Error creando bitácora:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // Actualizar bitácora
  async update(req, res) {
    try {
      const { id } = req.params;
      const { nombre, atributos, grilla, resumen, estado } = req.body;

      const bitacora = await db.get('SELECT * FROM bitacoras WHERE id = ?', [id]);
      if (!bitacora) {
        return res.status(404).json({
          success: false,
          message: 'Bitácora no encontrada'
        });
      }

      // Solo el creador puede editar (si está en borrador)
      if (bitacora.auxiliar_id !== req.user.id && req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para editar esta bitácora'
        });
      }

      await db.run(
        `UPDATE bitacoras SET
          nombre = COALESCE(?, nombre),
          atributos = COALESCE(?, atributos),
          grilla = COALESCE(?, grilla),
          resumen = COALESCE(?, resumen),
          estado = COALESCE(?, estado),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [
          nombre,
          atributos ? JSON.stringify(atributos) : null,
          grilla ? JSON.stringify(grilla) : null,
          resumen ? JSON.stringify(resumen) : null,
          estado,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Bitácora actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando bitácora:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar bitácora
  async delete(req, res) {
    try {
      const { id } = req.params;

      const bitacora = await db.get('SELECT * FROM bitacoras WHERE id = ?', [id]);
      if (!bitacora) {
        return res.status(404).json({
          success: false,
          message: 'Bitácora no encontrada'
        });
      }

      // Solo el creador o admin puede eliminar
      if (bitacora.auxiliar_id !== req.user.id && req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para eliminar esta bitácora'
        });
      }

      await db.run('DELETE FROM bitacoras WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Bitácora eliminada exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando bitácora:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Completar bitácora
  async completar(req, res) {
    try {
      const { id } = req.params;

      const bitacora = await db.get('SELECT * FROM bitacoras WHERE id = ?', [id]);
      if (!bitacora) {
        return res.status(404).json({
          success: false,
          message: 'Bitácora no encontrada'
        });
      }

      if (bitacora.auxiliar_id !== req.user.id && req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para completar esta bitácora'
        });
      }

      await db.run(
        `UPDATE bitacoras SET estado = 'completada', updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
        [id]
      );

      res.json({
        success: true,
        message: 'Bitácora marcada como completada'
      });
    } catch (error) {
      console.error('Error completando bitácora:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new BitacorasController();