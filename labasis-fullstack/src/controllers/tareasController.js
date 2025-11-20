// src/controllers/tareasController.js

const db = require('../config/database');

class TareasController {
  // Obtener todas las tareas
  async getAll(req, res) {
    try {
      const user = req.user;
      let tareas;

      if (user.rol === 'admin') {
        // Admin ve todas las tareas
        tareas = await db.all('SELECT * FROM tareas ORDER BY created_at DESC');
      } else {
        // Auxiliar solo ve sus tareas asignadas
        tareas = await db.all(
          'SELECT * FROM tareas WHERE auxiliar_id = ? ORDER BY created_at DESC',
          [user.id]
        );
      }

      // Parsear campos JSON
      tareas = tareas.map(tarea => ({
        ...tarea,
        evidencias: tarea.evidencias ? JSON.parse(tarea.evidencias) : [],
        tags: tarea.tags ? JSON.parse(tarea.tags) : []
      }));

      res.json({
        success: true,
        data: tareas
      });
    } catch (error) {
      console.error('Error obteniendo tareas:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener tareas del usuario actual
  async getMisTareas(req, res) {
    try {
      const tareas = await db.all(
        'SELECT * FROM tareas WHERE auxiliar_id = ? ORDER BY fecha_limite ASC',
        [req.user.id]
      );

      const tareasFormateadas = tareas.map(tarea => ({
        ...tarea,
        evidencias: tarea.evidencias ? JSON.parse(tarea.evidencias) : [],
        tags: tarea.tags ? JSON.parse(tarea.tags) : []
      }));

      res.json({
        success: true,
        data: tareasFormateadas
      });
    } catch (error) {
      console.error('Error obteniendo mis tareas:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Obtener tarea por ID
  async getById(req, res) {
    try {
      const { id } = req.params;
      const tarea = await db.get('SELECT * FROM tareas WHERE id = ?', [id]);

      if (!tarea) {
        return res.status(404).json({
          success: false,
          message: 'Tarea no encontrada'
        });
      }

      // Verificar permisos
      if (req.user.rol !== 'admin' && tarea.auxiliar_id !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes acceso a esta tarea'
        });
      }

      const tareaFormateada = {
        ...tarea,
        evidencias: tarea.evidencias ? JSON.parse(tarea.evidencias) : [],
        tags: tarea.tags ? JSON.parse(tarea.tags) : []
      };

      res.json({
        success: true,
        data: tareaFormateada
      });
    } catch (error) {
      console.error('Error obteniendo tarea:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Crear tarea (solo admin)
  async create(req, res) {
    try {
      const {
        titulo,
        descripcion,
        laboratorio_id,
        auxiliar_id,
        prioridad,
        fecha_limite,
        tags
      } = req.body;

      console.log('📝 Datos recibidos para crear tarea:', {
        titulo,
        descripcion,
        laboratorio_id,
        auxiliar_id,
        prioridad,
        fecha_limite,
        tags
      });

      // Validación detallada
      if (!titulo || titulo.trim() === '') {
        console.log('❌ Validación falló: Título requerido');
        return res.status(400).json({
          success: false,
          message: 'El título es requerido'
        });
      }

      if (!auxiliar_id) {
        console.log('❌ Validación falló: Auxiliar requerido');
        return res.status(400).json({
          success: false,
          message: 'El auxiliar es requerido'
        });
      }

      // Verificar que el auxiliar existe
      console.log('🔍 Buscando auxiliar con ID:', auxiliar_id);
      const auxiliar = await db.get('SELECT id, nombre, rol FROM users WHERE id = ?', [auxiliar_id]);
      
      if (!auxiliar) {
        console.log('❌ Auxiliar no encontrado con ID:', auxiliar_id);
        return res.status(404).json({
          success: false,
          message: `No existe un usuario con ID ${auxiliar_id}`
        });
      }

      console.log('✅ Auxiliar encontrado:', auxiliar);

      // Verificar laboratorio si se proporciona
      if (laboratorio_id) {
        console.log('🔍 Verificando laboratorio con ID:', laboratorio_id);
        const lab = await db.get('SELECT id, nombre FROM laboratorios WHERE id = ?', [laboratorio_id]);
        
        if (!lab) {
          console.log('❌ Laboratorio no encontrado con ID:', laboratorio_id);
          return res.status(404).json({
            success: false,
            message: `No existe un laboratorio con ID ${laboratorio_id}`
          });
        }
        
        console.log('✅ Laboratorio encontrado:', lab);
      }

      console.log('✅ Todas las validaciones pasadas, creando tarea...');

      // Crear tarea
      const result = await db.run(
        `INSERT INTO tareas (
          titulo, descripcion, laboratorio_id, auxiliar_id,
          prioridad, fecha_limite, creado_por, evidencias, tags, estado
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          titulo.trim(),
          descripcion ? descripcion.trim() : null,
          laboratorio_id || null,
          auxiliar_id,
          prioridad || 'media',
          fecha_limite || null,
          req.user.id,
          JSON.stringify([]),
          JSON.stringify(tags || []),
          'pendiente'
        ]
      );

      console.log('✅ Tarea creada exitosamente con ID:', result.id);

      res.status(201).json({
        success: true,
        message: 'Tarea creada exitosamente',
        data: { 
          id: result.id,
          titulo: titulo,
          auxiliar: auxiliar.nombre
        }
      });
    } catch (error) {
      console.error('❌ Error creando tarea:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // Actualizar tarea
  async update(req, res) {
    try {
      const { id } = req.params;
      const {
        titulo,
        descripcion,
        prioridad,
        estado,
        fecha_limite,
        evidencias,
        tags
      } = req.body;

      const tarea = await db.get('SELECT * FROM tareas WHERE id = ?', [id]);
      if (!tarea) {
        return res.status(404).json({
          success: false,
          message: 'Tarea no encontrada'
        });
      }

      // Verificar permisos
      if (req.user.rol !== 'admin' && tarea.auxiliar_id !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para actualizar esta tarea'
        });
      }

      // Si se marca como completada, guardar fecha
      let fechaCompletada = tarea.fecha_completada;
      if (estado === 'completada' && tarea.estado !== 'completada') {
        fechaCompletada = new Date().toISOString();
      }

      await db.run(
        `UPDATE tareas SET
          titulo = COALESCE(?, titulo),
          descripcion = COALESCE(?, descripcion),
          prioridad = COALESCE(?, prioridad),
          estado = COALESCE(?, estado),
          fecha_limite = COALESCE(?, fecha_limite),
          fecha_completada = ?,
          evidencias = COALESCE(?, evidencias),
          tags = COALESCE(?, tags),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [
          titulo,
          descripcion,
          prioridad,
          estado,
          fecha_limite,
          fechaCompletada,
          evidencias ? JSON.stringify(evidencias) : null,
          tags ? JSON.stringify(tags) : null,
          id
        ]
      );

      res.json({
        success: true,
        message: 'Tarea actualizada exitosamente'
      });
    } catch (error) {
      console.error('Error actualizando tarea:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Eliminar tarea (solo admin)
  async delete(req, res) {
    try {
      const { id } = req.params;

      const existe = await db.get('SELECT id FROM tareas WHERE id = ?', [id]);
      if (!existe) {
        return res.status(404).json({
          success: false,
          message: 'Tarea no encontrada'
        });
      }

      await db.run('DELETE FROM tareas WHERE id = ?', [id]);

      res.json({
        success: true,
        message: 'Tarea eliminada exitosamente'
      });
    } catch (error) {
      console.error('Error eliminando tarea:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Marcar tarea como completada
  async marcarCompletada(req, res) {
    try {
      const { id } = req.params;

      const tarea = await db.get('SELECT * FROM tareas WHERE id = ?', [id]);
      if (!tarea) {
        return res.status(404).json({
          success: false,
          message: 'Tarea no encontrada'
        });
      }

      // Verificar permisos
      if (req.user.rol !== 'admin' && tarea.auxiliar_id !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'No tienes permiso para completar esta tarea'
        });
      }

      await db.run(
        `UPDATE tareas SET
          estado = 'completada',
          fecha_completada = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = ?`,
        [id]
      );

      res.json({
        success: true,
        message: 'Tarea marcada como completada'
      });
    } catch (error) {
      console.error('Error marcando tarea como completada:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new TareasController();