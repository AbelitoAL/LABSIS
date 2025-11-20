// src/controllers/laboratoriosController.js

const db = require('../config/database');

class LaboratoriosController {
  // Obtener todos los laboratorios
  async getAll(req, res) {
    try {
      const user = req.user;
      let laboratorios;

      if (user.rol === 'admin') {
        // Admin ve todos los laboratorios
        laboratorios = await db.all('SELECT * FROM laboratorios ORDER BY created_at DESC');
      } else {
        // Auxiliar solo ve sus laboratorios asignados
        const userDetails = await db.get('SELECT laboratorios_asignados FROM users WHERE id = ?', [user.id]);
        const labsAsignados = JSON.parse(userDetails.laboratorios_asignados || '[]');
        
        if (labsAsignados.length === 0) {
          return res.json({ success: true, data: [] });
        }

        const placeholders = labsAsignados.map(() => '?').join(',');
        laboratorios = await db.all(
          `SELECT * FROM laboratorios WHERE id IN (${placeholders}) ORDER BY created_at DESC`,
          labsAsignados
        );
      }

      // Parsear campos JSON
      laboratorios = laboratorios.map(lab => ({
        ...lab,
        equipamiento: lab.equipamiento ? JSON.parse(lab.equipamiento) : [],
        manuales: lab.manuales ? JSON.parse(lab.manuales) : [],
        contraseñas: lab.contraseñas ? JSON.parse(lab.contraseñas) : {},
        horarios: lab.horarios ? JSON.parse(lab.horarios) : {},
        auxiliares_asignados: lab.auxiliares_asignados ? JSON.parse(lab.auxiliares_asignados) : [],
        imagenes: lab.imagenes ? JSON.parse(lab.imagenes) : []
      }));

      res.json({
        success: true,
        data: laboratorios
      });
    } catch (error) {
      console.error('Error obteniendo laboratorios:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener un laboratorio por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = req.user;

      const laboratorio = await db.get('SELECT * FROM laboratorios WHERE id = ?', [id]);

      if (!laboratorio) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      // Verificar permisos
      if (user.rol !== 'admin') {
        const userDetails = await db.get('SELECT laboratorios_asignados FROM users WHERE id = ?', [user.id]);
        const labsAsignados = JSON.parse(userDetails.laboratorios_asignados || '[]');
        
        if (!labsAsignados.includes(parseInt(id))) {
          return res.status(403).json({
            success: false,
            message: 'No tienes acceso a este laboratorio'
          });
        }
      }

      // Parsear campos JSON
      const labData = {
        ...laboratorio,
        equipamiento: laboratorio.equipamiento ? JSON.parse(laboratorio.equipamiento) : [],
        manuales: laboratorio.manuales ? JSON.parse(laboratorio.manuales) : [],
        contraseñas: laboratorio.contraseñas ? JSON.parse(laboratorio.contraseñas) : {},
        horarios: laboratorio.horarios ? JSON.parse(laboratorio.horarios) : {},
        auxiliares_asignados: laboratorio.auxiliares_asignados ? JSON.parse(laboratorio.auxiliares_asignados) : [],
        imagenes: laboratorio.imagenes ? JSON.parse(laboratorio.imagenes) : []
      };

      res.json({
        success: true,
        data: labData
      });
    } catch (error) {
      console.error('Error obteniendo laboratorio:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Crear laboratorio (solo admin)
  async create(req, res) {
    try {
      const {
        nombre,
        codigo,
        ubicacion,
        capacidad,
        equipamiento,
        manuales,
        contraseñas,
        horarios,
        auxiliares_asignados,
        estado,
        imagenes
      } = req.body;

      if (!nombre || !codigo) {
        return res.status(400).json({
          success: false,
          message: 'Nombre y código son requeridos'
        });
      }

      // Verificar que el código no exista
      const existe = await db.get('SELECT id FROM laboratorios WHERE codigo = ?', [codigo]);
      if (existe) {
        return res.status(400).json({
          success: false,
          message: 'El código ya existe'
        });
      }

      const result = await db.run(
        `INSERT INTO laboratorios (
          nombre, codigo, ubicacion, capacidad, equipamiento, manuales,
          contraseñas, horarios, auxiliares_asignados, estado, imagenes, modificado_por
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          nombre,
          codigo,
          ubicacion || null,
          capacidad || null,
          JSON.stringify(equipamiento || []),
          JSON.stringify(manuales || []),
          JSON.stringify(contraseñas || {}),
          JSON.stringify(horarios || {}),
          JSON.stringify(auxiliares_asignados || []),
          estado || 'activo',
          JSON.stringify(imagenes || []),
          req.user.id
        ]
      );

      res.status(201).json({
        success: true,
        message: 'Laboratorio creado exitosamente',
        data: { id: result.id }
      });
    } catch (error) {
      console.error('Error creando laboratorio:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actualizar laboratorio (solo admin)
  async update(req, res) {
    try {
      const { id } = req.params;
      const {
        nombre,
        codigo,
        ubicacion,
        capacidad,
        equipamiento,
        manuales,
        contraseñas,
        horarios,
        auxiliares_asignados,
        estado,
        imagenes
      } = req.body;

      // Verificar que existe
      const existe = await db.get('SELECT id FROM laboratorios WHERE id = ?', [id]);
      if (!existe) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      await db.run(
        `UPDATE laboratorios SET
          nombre = COALESCE(?, nombre),
          codigo = COALESCE(?, codigo),
          ubicacion = COALESCE(?, ubicacion),
          capacidad = COALESCE(?, capacidad),
          equipamiento = COALESCE(?, equipamiento),
          manuales = COALESCE(?, manuales),
          contraseñas = COALESCE(?, contraseñas),
          horarios = COALESCE(?, horarios),
          auxiliares_asignados = COALESCE(?, auxiliares_asignados),
          estado = COALESCE(?, estado),
          imagenes = COALESCE(?, imagenes),
          modificado_por = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [
          nombre,
          codigo,
          ubicacion,
          capacidad,
          equipamiento ? JSON.stringify(equipamiento) : null,
          manuales ? JSON.stringify(manuales) : null,
          contraseñas ? JSON.stringify(contraseñas) : null,
          horarios ? JSON.stringify(horarios) : null,
          auxiliares_asignados ? JSON.stringify(auxiliares_asignados) : null,
          estado,
          imagenes ? JSON.stringify(imagenes) : null,
          req.user.id,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Laboratorio actualizado exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando laboratorio:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar laboratorio (solo admin)
  async delete(req, res) {
    try {
      const { id } = req.params;

      const existe = await db.get('SELECT id FROM laboratorios WHERE id = ?', [id]);
      if (!existe) {
        return res.status(404).json({
          success: false,
          message: 'Laboratorio no encontrado'
        });
      }

      await db.run('DELETE FROM laboratorios WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Laboratorio eliminado exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando laboratorio:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new LaboratoriosController();