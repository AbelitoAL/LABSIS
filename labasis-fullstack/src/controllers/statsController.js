// src/controllers/statsController.js

const db = require('../config/database');

class StatsController {
  // Estadísticas generales del sistema
  async getGeneral(req, res) {
    try {
      // Total de usuarios
      const totalUsers = await db.get('SELECT COUNT(*) as count FROM users');
      const activeUsers = await db.get('SELECT COUNT(*) as count FROM users WHERE activo = 1');
      const adminUsers = await db.get('SELECT COUNT(*) as count FROM users WHERE rol = "admin"');
      const auxiliarUsers = await db.get('SELECT COUNT(*) as count FROM users WHERE rol = "auxiliar"');

      // Total de laboratorios
      const totalLabs = await db.get('SELECT COUNT(*) as count FROM laboratorios');
      const activeLabs = await db.get('SELECT COUNT(*) as count FROM laboratorios WHERE estado = "activo"');

      // Total de tareas
      const totalTareas = await db.get('SELECT COUNT(*) as count FROM tareas');
      const tareasPendientes = await db.get('SELECT COUNT(*) as count FROM tareas WHERE estado = "pendiente"');
      const tareasEnProceso = await db.get('SELECT COUNT(*) as count FROM tareas WHERE estado = "en_proceso"');
      const tareasCompletadas = await db.get('SELECT COUNT(*) as count FROM tareas WHERE estado = "completada"');

      // Total de bitácoras
      const totalBitacoras = await db.get('SELECT COUNT(*) as count FROM bitacoras');
      const bitacorasBorrador = await db.get('SELECT COUNT(*) as count FROM bitacoras WHERE estado = "borrador"');
      const bitacorasCompletadas = await db.get('SELECT COUNT(*) as count FROM bitacoras WHERE estado = "completada"');

      // Total de objetos perdidos
      const totalObjetosPerdidos = await db.get('SELECT COUNT(*) as count FROM objetos_perdidos');
      const objetosEncontrados = await db.get('SELECT COUNT(*) as count FROM objetos_perdidos WHERE estado = "encontrado"');
      const objetosEntregados = await db.get('SELECT COUNT(*) as count FROM objetos_perdidos WHERE estado = "entregado"');

      // Total de plantillas e iconos
      const totalPlantillas = await db.get('SELECT COUNT(*) as count FROM plantillas WHERE activo = 1');
      const totalIconos = await db.get('SELECT COUNT(*) as count FROM iconos');

      res.json({
        success: true,
        data: {
          usuarios: {
            total: totalUsers.count,
            activos: activeUsers.count,
            inactivos: totalUsers.count - activeUsers.count,
            admins: adminUsers.count,
            auxiliares: auxiliarUsers.count
          },
          laboratorios: {
            total: totalLabs.count,
            activos: activeLabs.count,
            inactivos: totalLabs.count - activeLabs.count
          },
          tareas: {
            total: totalTareas.count,
            pendientes: tareasPendientes.count,
            en_proceso: tareasEnProceso.count,
            completadas: tareasCompletadas.count
          },
          bitacoras: {
            total: totalBitacoras.count,
            borradores: bitacorasBorrador.count,
            completadas: bitacorasCompletadas.count
          },
          objetos_perdidos: {
            total: totalObjetosPerdidos.count,
            encontrados: objetosEncontrados.count,
            entregados: objetosEntregados.count,
            pendientes: objetosEncontrados.count
          },
          plantillas: totalPlantillas.count,
          iconos: totalIconos.count
        }
      });
    } catch (error) {
      console.error('Error obteniendo estadísticas generales:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Estadísticas de laboratorios
  async getLaboratorios(req, res) {
    try {
      const laboratorios = await db.all(`
        SELECT 
          l.id,
          l.nombre,
          l.codigo,
          l.capacidad,
          l.estado,
          (SELECT COUNT(*) FROM tareas WHERE laboratorio_id = l.id) as total_tareas,
          (SELECT COUNT(*) FROM tareas WHERE laboratorio_id = l.id AND estado = 'pendiente') as tareas_pendientes,
          (SELECT COUNT(*) FROM bitacoras WHERE laboratorio_id = l.id) as total_bitacoras,
          (SELECT COUNT(*) FROM objetos_perdidos WHERE laboratorio_id = l.id) as objetos_perdidos
        FROM laboratorios l
        ORDER BY l.nombre
      `);

      res.json({
        success: true,
        data: laboratorios
      });
    } catch (error) {
      console.error('Error obteniendo estadísticas de laboratorios:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Estadísticas de tareas
  async getTareas(req, res) {
    try {
      // Tareas por prioridad
      const porPrioridad = await db.all(`
        SELECT 
          prioridad,
          COUNT(*) as cantidad
        FROM tareas
        GROUP BY prioridad
      `);

      // Tareas por estado
      const porEstado = await db.all(`
        SELECT 
          estado,
          COUNT(*) as cantidad
        FROM tareas
        GROUP BY estado
      `);

      // Tareas por auxiliar
      const porAuxiliar = await db.all(`
        SELECT 
          u.nombre as auxiliar,
          COUNT(*) as total_tareas,
          SUM(CASE WHEN t.estado = 'completada' THEN 1 ELSE 0 END) as completadas,
          SUM(CASE WHEN t.estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes
        FROM tareas t
        INNER JOIN users u ON t.auxiliar_id = u.id
        GROUP BY u.id, u.nombre
        ORDER BY total_tareas DESC
      `);

      // Tareas próximas a vencer (en los próximos 7 días)
      const proximasVencer = await db.all(`
        SELECT 
          t.id,
          t.titulo,
          t.descripcion,
          t.prioridad,
          t.fecha_limite,
          u.nombre as auxiliar,
          l.nombre as laboratorio
        FROM tareas t
        LEFT JOIN users u ON t.auxiliar_id = u.id
        LEFT JOIN laboratorios l ON t.laboratorio_id = l.id
        WHERE t.estado != 'completada' 
          AND t.fecha_limite IS NOT NULL
          AND t.fecha_limite <= datetime('now', '+7 days')
        ORDER BY t.fecha_limite ASC
        LIMIT 10
      `);

      // Tareas vencidas
      const vencidas = await db.all(`
        SELECT 
          t.id,
          t.titulo,
          t.prioridad,
          t.fecha_limite,
          u.nombre as auxiliar,
          l.nombre as laboratorio
        FROM tareas t
        LEFT JOIN users u ON t.auxiliar_id = u.id
        LEFT JOIN laboratorios l ON t.laboratorio_id = l.id
        WHERE t.estado != 'completada' 
          AND t.fecha_limite IS NOT NULL
          AND t.fecha_limite < datetime('now')
        ORDER BY t.fecha_limite ASC
      `);

      res.json({
        success: true,
        data: {
          por_prioridad: porPrioridad,
          por_estado: porEstado,
          por_auxiliar: porAuxiliar,
          proximas_vencer: proximasVencer,
          vencidas: vencidas
        }
      });
    } catch (error) {
      console.error('Error obteniendo estadísticas de tareas:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Estadísticas de objetos perdidos
  async getObjetosPerdidos(req, res) {
    try {
      // Por categoría
      const porCategoria = await db.all(`
        SELECT 
          categoria,
          COUNT(*) as cantidad
        FROM objetos_perdidos
        GROUP BY categoria
        ORDER BY cantidad DESC
      `);

      // Por estado
      const porEstado = await db.all(`
        SELECT 
          estado,
          COUNT(*) as cantidad
        FROM objetos_perdidos
        GROUP BY estado
      `);

      // Por laboratorio
      const porLaboratorio = await db.all(`
        SELECT 
          l.nombre as laboratorio,
          COUNT(*) as cantidad
        FROM objetos_perdidos op
        INNER JOIN laboratorios l ON op.laboratorio_id = l.id
        GROUP BY l.id, l.nombre
        ORDER BY cantidad DESC
      `);

      // Objetos recientes (últimos 30 días)
      const recientes = await db.all(`
        SELECT 
          op.id,
          op.descripcion,
          op.categoria,
          op.fecha_encontrado,
          op.estado,
          l.nombre as laboratorio,
          u.nombre as auxiliar_encontro
        FROM objetos_perdidos op
        LEFT JOIN laboratorios l ON op.laboratorio_id = l.id
        LEFT JOIN users u ON op.auxiliar_encontro_id = u.id
        WHERE op.fecha_encontrado >= datetime('now', '-30 days')
        ORDER BY op.fecha_encontrado DESC
        LIMIT 20
      `);

      res.json({
        success: true,
        data: {
          por_categoria: porCategoria,
          por_estado: porEstado,
          por_laboratorio: porLaboratorio,
          recientes: recientes
        }
      });
    } catch (error) {
      console.error('Error obteniendo estadísticas de objetos perdidos:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Actividad reciente del sistema
  async getActividadReciente(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 20;

      // Últimas tareas creadas
      const ultimasTareas = await db.all(`
        SELECT 
          'tarea' as tipo,
          t.id,
          t.titulo as descripcion,
          t.created_at as fecha,
          u.nombre as usuario
        FROM tareas t
        LEFT JOIN users u ON t.creado_por = u.id
        ORDER BY t.created_at DESC
        LIMIT ?
      `, [limit]);

      // Últimas bitácoras creadas
      const ultimasBitacoras = await db.all(`
        SELECT 
          'bitacora' as tipo,
          b.id,
          b.nombre as descripcion,
          b.created_at as fecha,
          u.nombre as usuario
        FROM bitacoras b
        LEFT JOIN users u ON b.auxiliar_id = u.id
        ORDER BY b.created_at DESC
        LIMIT ?
      `, [limit]);

      // Últimos objetos perdidos registrados
      const ultimosObjetos = await db.all(`
        SELECT 
          'objeto_perdido' as tipo,
          op.id,
          op.descripcion,
          op.fecha_encontrado as fecha,
          u.nombre as usuario
        FROM objetos_perdidos op
        LEFT JOIN users u ON op.auxiliar_encontro_id = u.id
        ORDER BY op.fecha_encontrado DESC
        LIMIT ?
      `, [limit]);

      // Combinar y ordenar todas las actividades
      const actividades = [...ultimasTareas, ...ultimasBitacoras, ...ultimosObjetos]
        .sort((a, b) => new Date(b.fecha) - new Date(a.fecha))
        .slice(0, limit);

      res.json({
        success: true,
        data: actividades
      });
    } catch (error) {
      console.error('Error obteniendo actividad reciente:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }

  // Estadísticas de un auxiliar específico
  async getAuxiliar(req, res) {
    try {
      const { id } = req.params;

      // Verificar que el usuario existe y es auxiliar
      const usuario = await db.get('SELECT * FROM users WHERE id = ? AND rol = "auxiliar"', [id]);
      if (!usuario) {
        return res.status(404).json({
          success: false,
          message: 'Auxiliar no encontrado'
        });
      }

      // Tareas del auxiliar
      const tareas = await db.get(`
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas,
          SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes,
          SUM(CASE WHEN estado = 'en_proceso' THEN 1 ELSE 0 END) as en_proceso
        FROM tareas
        WHERE auxiliar_id = ?
      `, [id]);

      // Bitácoras del auxiliar
      const bitacoras = await db.get(`
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas,
          SUM(CASE WHEN estado = 'borrador' THEN 1 ELSE 0 END) as borradores
        FROM bitacoras
        WHERE auxiliar_id = ?
      `, [id]);

      // Objetos encontrados por el auxiliar
      const objetosEncontrados = await db.get(`
        SELECT COUNT(*) as total
        FROM objetos_perdidos
        WHERE auxiliar_encontro_id = ?
      `, [id]);

      // Laboratorios asignados
      const labsAsignados = usuario.laboratorios_asignados ? JSON.parse(usuario.laboratorios_asignados) : [];

      res.json({
        success: true,
        data: {
          auxiliar: {
            id: usuario.id,
            nombre: usuario.nombre,
            email: usuario.email
          },
          tareas: tareas,
          bitacoras: bitacoras,
          objetos_encontrados: objetosEncontrados.total,
          laboratorios_asignados: labsAsignados.length
        }
      });
    } catch (error) {
      console.error('Error obteniendo estadísticas del auxiliar:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new StatsController();