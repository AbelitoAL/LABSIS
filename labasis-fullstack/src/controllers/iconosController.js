// src/controllers/iconosController.js

const db = require('../config/database');

class IconosController {
  // Obtener todos los iconos
  async getAll(req, res) {
    try {
      const { categoria } = req.query;
      
      let iconos;
      if (categoria) {
        iconos = await db.all(
          'SELECT * FROM iconos WHERE categoria = ? ORDER BY uso DESC, created_at DESC',
          [categoria]
        );
      } else {
        iconos = await db.all('SELECT * FROM iconos ORDER BY uso DESC, created_at DESC');
      }

      const iconosFormateados = iconos.map(icono => ({
        ...icono,
        tags: icono.tags ? JSON.parse(icono.tags) : []
      }));

      res.json({
        success: true,
        data: iconosFormateados
      });
    } catch (error) {
      console.error('Error obteniendo iconos:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener icono por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const icono = await db.get('SELECT * FROM iconos WHERE id = ?', [id]);

      if (!icono) {
        return res.status(404).json({
          success: false,
          message: 'Icono no encontrado'
        });
      }

      const iconoFormateado = {
        ...icono,
        tags: icono.tags ? JSON.parse(icono.tags) : []
      };

      res.json({
        success: true,
        data: iconoFormateado
      });
    } catch (error) {
      console.error('Error obteniendo icono:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Crear icono
  async create(req, res) {
    try {
      const { nombre, descripcion, imagen_url, categoria, tags } = req.body;

      if (!nombre || !imagen_url) {
        return res.status(400).json({
          success: false,
          message: 'Nombre e imagen son requeridos'
        });
      }

      const result = await db.run(
        `INSERT INTO iconos (nombre, descripcion, imagen_url, categoria, tags, creado_por)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          nombre,
          descripcion || null,
          imagen_url,
          categoria || 'otros',
          JSON.stringify(tags || []),
          req.user.id
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Icono creado exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('Error creando icono:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actualizar icono
  async update(req, res) {
    try {
      const { id } = req.params;
      const { nombre, descripcion, imagen_url, categoria, tags } = req.body;

      const icono = await db.get('SELECT * FROM iconos WHERE id = ?', [id]);
      if (!icono) {
        return res.status(404).json({
          success: false,
          message: 'Icono no encontrado'
        });
      }

      // Solo el creador o admin puede editar
      if (req.user.rol !== 'admin' && icono.creado_por !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para editar este icono'
        });
      }

      await db.run(
        `UPDATE iconos SET
          nombre = COALESCE(?, nombre),
          descripcion = COALESCE(?, descripcion),
          imagen_url = COALESCE(?, imagen_url),
          categoria = COALESCE(?, categoria),
          tags = COALESCE(?, tags)
        WHERE id = ?`,
        [
          nombre,
          descripcion,
          imagen_url,
          categoria,
          tags ? JSON.stringify(tags) : null,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Icono actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando icono:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar icono
  async delete(req, res) {
    try {
      const { id } = req.params;

      const icono = await db.get('SELECT * FROM iconos WHERE id = ?', [id]);
      if (!icono) {
        return res.status(404).json({
          success: false,
          message: 'Icono no encontrado'
        });
      }

      // Solo el creador o admin puede eliminar
      if (req.user.rol !== 'admin' && icono.creado_por !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para eliminar este icono'
        });
      }

      await db.run('DELETE FROM iconos WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Icono eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando icono:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Incrementar uso de icono
  async incrementarUso(req, res) {
    try {
      const { id } = req.params;

      await db.run('UPDATE iconos SET uso = uso + 1 WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Uso incrementado'
      });
    } catch (error) {
      console.error('Error incrementando uso:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new IconosController();