// src/controllers/plantillasController.js

const db = require('../config/database');

class PlantillasController {
  // Obtener todas las plantillas
  async getAll(req, res) {
    try {
      const { laboratorio_id } = req.query;
      const user = req.user;

      let plantillas;
      if (laboratorio_id) {
        plantillas = await db.all(
          'SELECT * FROM plantillas WHERE laboratorio_id = ? AND activo = 1 ORDER BY created_at DESC',
          [laboratorio_id]
        );
      } else if (user.rol === 'admin') {
        plantillas = await db.all(
          'SELECT * FROM plantillas WHERE activo = 1 ORDER BY created_at DESC'
        );
      } else {
        // Auxiliar solo ve plantillas de sus laboratorios asignados
        const userDetails = await db.get(
          'SELECT laboratorios_asignados FROM users WHERE id = ?',
          [user.id]
        );
        const labsAsignados = JSON.parse(userDetails.laboratorios_asignados || '[]');
        
        if (labsAsignados.length === 0) {
          return res.json({ success: true, data: [] });
        }

        const placeholders = labsAsignados.map(() => '?').join(',');
        plantillas = await db.all(
          `SELECT * FROM plantillas 
           WHERE laboratorio_id IN (${placeholders}) AND activo = 1 
           ORDER BY created_at DESC`,
          labsAsignados
        );
      }

      // Parsear elementos JSON
      const plantillasFormateadas = plantillas.map(plantilla => ({
        ...plantilla,
        elementos: plantilla.elementos ? JSON.parse(plantilla.elementos) : []
      }));

      res.json({
        success: true,
        data: plantillasFormateadas
      });
    } catch (error) {
      console.error('Error obteniendo plantillas:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener plantilla por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const plantilla = await db.get('SELECT * FROM plantillas WHERE id = ?', [id]);

      if (!plantilla) {
        return res.status(404).json({
          success: false,
          message: 'Plantilla no encontrada'
        });
      }

      const plantillaFormateada = {
        ...plantilla,
        elementos: plantilla.elementos ? JSON.parse(plantilla.elementos) : []
      };

      res.json({
        success: true,
        data: plantillaFormateada
      });
    } catch (error) {
      console.error('Error obteniendo plantilla:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Crear plantilla
  async create(req, res) {
    try {
      const { nombre, descripcion, laboratorio_id, ancho, alto, elementos } = req.body;

      if (!nombre || !ancho || !alto) {
        return res.status(400).json({
          success: false,
          message: 'Nombre, ancho y alto son requeridos'
        });
      }

      // Validar dimensiones
      if (ancho < 5 || ancho > 50 || alto < 5 || alto > 50) {
        return res.status(400).json({
          success: false,
          message: 'Las dimensiones deben estar entre 5 y 50'
        });
      }

      const result = await db.run(
        `INSERT INTO plantillas (
          nombre, descripcion, laboratorio_id, ancho, alto, 
          elementos, creado_por
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          nombre,
          descripcion || null,
          laboratorio_id || null,
          ancho,
          alto,
          JSON.stringify(elementos || []),
          req.user.id
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Plantilla creada exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('Error creando plantilla:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actualizar plantilla
  async update(req, res) {
    try {
      const { id } = req.params;
      const { nombre, descripcion, ancho, alto, elementos, activo } = req.body;

      const plantilla = await db.get('SELECT * FROM plantillas WHERE id = ?', [id]);
      if (!plantilla) {
        return res.status(404).json({
          success: false,
          message: 'Plantilla no encontrada'
        });
      }

      // Solo el creador o admin puede editar
      if (req.user.rol !== 'admin' && plantilla.creado_por !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para editar esta plantilla'
        });
      }

      // Validar dimensiones si se proporcionan
      if (ancho && (ancho < 5 || ancho > 50)) {
        return res.status(400).json({
          success: false,
          message: 'El ancho debe estar entre 5 y 50'
        });
      }
      if (alto && (alto < 5 || alto > 50)) {
        return res.status(400).json({
          success: false,
          message: 'El alto debe estar entre 5 y 50'
        });
      }

      await db.run(
        `UPDATE plantillas SET
          nombre = COALESCE(?, nombre),
          descripcion = COALESCE(?, descripcion),
          ancho = COALESCE(?, ancho),
          alto = COALESCE(?, alto),
          elementos = COALESCE(?, elementos),
          activo = COALESCE(?, activo),
          version = version + 1,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [
          nombre,
          descripcion,
          ancho,
          alto,
          elementos ? JSON.stringify(elementos) : null,
          activo,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Plantilla actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando plantilla:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar plantilla (soft delete)
  async delete(req, res) {
    try {
      const { id } = req.params;

      const plantilla = await db.get('SELECT * FROM plantillas WHERE id = ?', [id]);
      if (!plantilla) {
        return res.status(404).json({
          success: false,
          message: 'Plantilla no encontrada'
        });
      }

      // Solo el creador o admin puede eliminar
      if (req.user.rol !== 'admin' && plantilla.creado_por !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para eliminar esta plantilla'
        });
      }

      // Soft delete
      await db.run('UPDATE plantillas SET activo = 0 WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Plantilla eliminada exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando plantilla:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Duplicar plantilla
  async duplicar(req, res) {
    try {
      const { id } = req.params;
      const { nombre } = req.body;

      const plantilla = await db.get('SELECT * FROM plantillas WHERE id = ?', [id]);
      if (!plantilla) {
        return res.status(404).json({
          success: false,
          message: 'Plantilla no encontrada'
        });
      }

      const nuevoNombre = nombre || `${plantilla.nombre} (Copia)`;

      const result = await db.run(
        `INSERT INTO plantillas (
          nombre, descripcion, laboratorio_id, ancho, alto, 
          elementos, creado_por
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          nuevoNombre,
          plantilla.descripcion,
          plantilla.laboratorio_id,
          plantilla.ancho,
          plantilla.alto,
          plantilla.elementos,
          req.user.id
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Plantilla duplicada exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('Error duplicando plantilla:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new PlantillasController();