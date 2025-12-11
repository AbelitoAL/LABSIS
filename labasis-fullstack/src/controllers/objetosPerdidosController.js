// src/controllers/objetosPerdidosController.js

const db = require('../config/database');

class ObjetosPerdidosController {
  // Obtener todos los objetos perdidos
  async getAll(req, res) {
    try {
      const { estado, laboratorio_id } = req.query;

      let query = 'SELECT * FROM objetos_perdidos WHERE 1=1';
      let params = [];

      if (estado) {
        query += ' AND estado = ?';
        params.push(estado);
      }

      if (laboratorio_id) {
        query += ' AND laboratorio_id = ?';
        params.push(laboratorio_id);
      }

      query += ' ORDER BY fecha_encontrado DESC';

      const objetos = await db.all(query, params);

      // Parsear entrega JSON
      const objetosFormateados = objetos.map(objeto => ({
        ...objeto,
        entrega: objeto.entrega ? JSON.parse(objeto.entrega) : null
      }));

      res.json({
        success: true,
        data: objetosFormateados
      });
    } catch (error) {
      console.error('Error obteniendo objetos perdidos:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener objeto perdido por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const objeto = await db.get('SELECT * FROM objetos_perdidos WHERE id = ?', [id]);

      if (!objeto) {
        return res.status(404).json({
          success: false,
          message: 'Objeto no encontrado'
        });
      }

      const objetoFormateado = {
        ...objeto,
        entrega: objeto.entrega ? JSON.parse(objeto.entrega) : null
      };

      res.json({
        success: true,
        data: objetoFormateado
      });
    } catch (error) {
      console.error('Error obteniendo objeto perdido:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Registrar objeto perdido
  async create(req, res) {
    try {
      const {
        foto_objeto,
        descripcion,
        categoria,
        laboratorio_id,
        fecha_encontrado
      } = req.body;

      if (!descripcion || !laboratorio_id) {
        return res.status(400).json({
          success: false,
          message: 'Descripción y laboratorio son requeridos'
        });
      }

      const result = await db.run(
        `INSERT INTO objetos_perdidos (
          foto_objeto, descripcion, categoria, laboratorio_id,
          auxiliar_encontro_id, fecha_encontrado, estado
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          foto_objeto || null,
          descripcion,
          categoria || 'otros',
          laboratorio_id,
          req.user.id,
          fecha_encontrado || new Date().toISOString(),
          'en_custodia' // Estado inicial
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Objeto perdido registrado exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('Error registrando objeto perdido:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Registrar entrega de objeto
  async registrarEntrega(req, res) {
    try {
      const { id } = req.params;
      const {
        foto_persona,
        nombre_completo,
        documento_identidad,
        tipo_documento,
        telefono,
        email,
        relacion_objeto
      } = req.body;

      if (!nombre_completo || !documento_identidad) {
        return res.status(400).json({
          success: false,
          message: 'Nombre y documento de identidad son requeridos'
        });
      }

      const objeto = await db.get('SELECT * FROM objetos_perdidos WHERE id = ?', [id]);
      if (!objeto) {
        return res.status(404).json({
          success: false,
          message: 'Objeto no encontrado'
        });
      }

      if (objeto.estado === 'entregado') {
        return res.status(400).json({
          success: false,
          message: 'Este objeto ya fue entregado'
        });
      }

      const entrega = {
        foto_persona: foto_persona || null,
        nombre_completo,
        documento_identidad,
        tipo_documento: tipo_documento || 'CI',
        telefono: telefono || null,
        email: email || null,
        relacion_objeto: relacion_objeto || null,
        fecha_entrega: new Date().toISOString(),
        auxiliar_entrego_id: req.user.id
      };

      await db.run(
        `UPDATE objetos_perdidos SET
          estado = 'entregado',
          entrega = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [JSON.stringify(entrega), id]
      );

      res.json({
        success: true,
        message: 'Entrega registrada exitosamente'
      });
    } catch (error) {
      console.error('Error registrando entrega:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actualizar objeto perdido
  async update(req, res) {
    try {
      const { id } = req.params;
      const { descripcion, categoria, foto_objeto } = req.body;

      const objeto = await db.get('SELECT * FROM objetos_perdidos WHERE id = ?', [id]);
      if (!objeto) {
        return res.status(404).json({
          success: false,
          message: 'Objeto no encontrado'
        });
      }

      // No permitir editar si ya fue entregado
      if (objeto.estado === 'entregado') {
        return res.status(400).json({
          success: false,
          message: 'No se puede editar un objeto ya entregado'
        });
      }

      await db.run(
        `UPDATE objetos_perdidos SET
          descripcion = COALESCE(?, descripcion),
          categoria = COALESCE(?, categoria),
          foto_objeto = COALESCE(?, foto_objeto),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [descripcion, categoria, foto_objeto, id]
      );

      res.json({
        success: true,
        message: 'Objeto actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando objeto:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar objeto perdido
  async delete(req, res) {
    try {
      const { id } = req.params;

      const existe = await db.get('SELECT id FROM objetos_perdidos WHERE id = ?', [id]);
      if (!existe) {
        return res.status(404).json({
          success: false,
          message: 'Objeto no encontrado'
        });
      }

      await db.run('DELETE FROM objetos_perdidos WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Objeto eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando objeto:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new ObjetosPerdidosController();