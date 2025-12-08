// src/controllers/manualesController.js

const db = require('../config/database');

class ManualesController {
  // ==========================================
  // OBTENER TODOS LOS MANUALES
  // ==========================================
  getAll = async (req, res) => {
    try {
      console.log('📖 Obteniendo todos los manuales...');

      // Obtener todos los manuales con información del laboratorio
      const manuales = await db.all(`
        SELECT 
          m.*,
          l.nombre as laboratorio_nombre,
          l.codigo as laboratorio_codigo,
          l.ubicacion as laboratorio_ubicacion,
          u1.nombre as creado_por_nombre,
          u2.nombre as actualizado_por_nombre
        FROM manuales m
        INNER JOIN laboratorios l ON m.laboratorio_id = l.id
        LEFT JOIN users u1 ON m.created_by = u1.id
        LEFT JOIN users u2 ON m.updated_by = u2.id
        ORDER BY l.nombre ASC
      `);

      // Parsear items JSON
      const manualesFormateados = manuales.map(manual => ({
        ...manual,
        items: JSON.parse(manual.items),
        cantidad_items: JSON.parse(manual.items).length
      }));

      console.log(`✅ ${manualesFormateados.length} manuales obtenidos`);

      res.json({
        success: true,
        data: manualesFormateados
      });
    } catch (error) {
      console.error('❌ Error obteniendo manuales:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  };

  // ==========================================
  // OBTENER MANUAL POR LABORATORIO
  // ==========================================
  getByLaboratorioId = async (req, res) => {
    try {
      const { laboratorioId } = req.params;
      console.log(`📖 Obteniendo manual del laboratorio ${laboratorioId}...`);

      // Verificar que el laboratorio existe
      const laboratorio = await db.get(
        'SELECT id, nombre, codigo, ubicacion FROM laboratorios WHERE id = ?',
        [laboratorioId]
      );

      if (!laboratorio) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      // Obtener el manual
      const manual = await db.get(`
        SELECT 
          m.*,
          u1.nombre as creado_por_nombre,
          u2.nombre as actualizado_por_nombre
        FROM manuales m
        LEFT JOIN users u1 ON m.created_by = u1.id
        LEFT JOIN users u2 ON m.updated_by = u2.id
        WHERE m.laboratorio_id = ?
      `, [laboratorioId]);

      if (!manual) {
        // Si no existe manual, retornar estructura vacía
        return res.json({
          success: true,
          data: {
            laboratorio: laboratorio,
            manual: null,
            items: []
          }
        });
      }

      // Parsear items
      const items = JSON.parse(manual.items);

      console.log(`✅ Manual obtenido con ${items.length} items`);

      res.json({
        success: true,
        data: {
          laboratorio: laboratorio,
          manual: {
            id: manual.id,
            laboratorio_id: manual.laboratorio_id,
            created_by: manual.created_by,
            updated_by: manual.updated_by,
            created_at: manual.created_at,
            updated_at: manual.updated_at,
            creado_por_nombre: manual.creado_por_nombre,
            actualizado_por_nombre: manual.actualizado_por_nombre
          },
          items: items
        }
      });
    } catch (error) {
      console.error('❌ Error obteniendo manual:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  };

  // ==========================================
  // CREAR O ACTUALIZAR MANUAL (UPSERT)
  // ==========================================
  createOrUpdate = async (req, res) => {
    try {
      const { laboratorioId } = req.params;
      const { items } = req.body;

      console.log(`📖 Guardando manual del laboratorio ${laboratorioId}...`);

      // Verificar que sea admin
      if (req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Solo los administradores pueden crear o editar manuales'
        });
      }

      // Validar items
      if (!items || !Array.isArray(items)) {
        return res.status(400).json({
          success: false,
          message: 'El campo items es requerido y debe ser un array'
        });
      }

      // Validar que cada item tenga titulo y descripcion
      for (let i = 0; i < items.length; i++) {
        if (!items[i].titulo || !items[i].descripcion) {
          return res.status(400).json({
            success: false,
            message: `El item ${i + 1} debe tener título y descripción`
          });
        }
      }

      // Verificar que el laboratorio existe
      const laboratorio = await db.get(
        'SELECT id FROM laboratorios WHERE id = ?',
        [laboratorioId]
      );

      if (!laboratorio) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      // Verificar si ya existe un manual para este laboratorio
      const manualExistente = await db.get(
        'SELECT id FROM manuales WHERE laboratorio_id = ?',
        [laboratorioId]
      );

      const itemsJSON = JSON.stringify(items);

      if (manualExistente) {
        // Actualizar manual existente
        await db.run(`
          UPDATE manuales 
          SET items = ?,
              updated_by = ?,
              updated_at = CURRENT_TIMESTAMP
          WHERE laboratorio_id = ?
        `, [itemsJSON, req.user.id, laboratorioId]);

        console.log(`✅ Manual actualizado con ${items.length} items`);

        res.json({
          success: true,
          message: 'Manual actualizado exitosamente',
          data: {
            id: manualExistente.id,
            laboratorio_id: parseInt(laboratorioId),
            items: items
          }
        });
      } else {
        // Crear nuevo manual
        const result = await db.run(`
          INSERT INTO manuales (laboratorio_id, items, created_by, updated_by)
          VALUES (?, ?, ?, ?)
        `, [laboratorioId, itemsJSON, req.user.id, req.user.id]);

        console.log(`✅ Manual creado con ${items.length} items`);

        res.status(201).json({
          success: true,
          message: 'Manual creado exitosamente',
          data: {
            id: result.id,
            laboratorio_id: parseInt(laboratorioId),
            items: items
          }
        });
      }
    } catch (error) {
      console.error('❌ Error guardando manual:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  };

  // ==========================================
  // ELIMINAR MANUAL
  // ==========================================
  delete = async (req, res) => {
    try {
      const { laboratorioId } = req.params;

      console.log(`📖 Eliminando manual del laboratorio ${laboratorioId}...`);

      // Verificar que sea admin
      if (req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Solo los administradores pueden eliminar manuales'
        });
      }

      // Verificar que existe el manual
      const manual = await db.get(
        'SELECT id FROM manuales WHERE laboratorio_id = ?',
        [laboratorioId]
      );

      if (!manual) {
        return res.status(404).json({
          success: false,
          message: 'Manual no encontrado'
        });
      }

      // Eliminar el manual
      await db.run(
        'DELETE FROM manuales WHERE laboratorio_id = ?',
        [laboratorioId]
      );

      console.log('✅ Manual eliminado exitosamente');

      res.json({
        success: true,
        message: 'Manual eliminado exitosamente'
      });
    } catch (error) {
      console.error('❌ Error eliminando manual:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  };

  // ==========================================
  // OBTENER LABORATORIOS CON/SIN MANUALES
  // ==========================================
  getLaboratoriosConManuales = async (req, res) => {
    try {
      console.log('📖 Obteniendo laboratorios con información de manuales...');

      const laboratorios = await db.all(`
        SELECT 
          l.id,
          l.nombre,
          l.codigo,
          l.ubicacion,
          l.estado,
          CASE 
            WHEN m.id IS NOT NULL THEN 1 
            ELSE 0 
          END as tiene_manual,
          m.id as manual_id,
          CASE 
            WHEN m.items IS NOT NULL 
            THEN json_array_length(m.items)
            ELSE 0 
          END as cantidad_items,
          m.updated_at as manual_actualizado
        FROM laboratorios l
        LEFT JOIN manuales m ON l.id = m.laboratorio_id
        WHERE l.estado = 'activo'
        ORDER BY l.nombre ASC
      `);

      console.log(`✅ ${laboratorios.length} laboratorios obtenidos`);

      res.json({
        success: true,
        data: laboratorios
      });
    } catch (error) {
      console.error('❌ Error obteniendo laboratorios:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  };
}

module.exports = new ManualesController();