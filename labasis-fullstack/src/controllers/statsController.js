// src/controllers/statsController.js

const db = require('../config/database');

class StatsController {
  // ==========================================
  // MÉTODOS EXISTENTES (NO MODIFICADOS)
  // ==========================================

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

  // ==========================================
  // NUEVOS MÉTODOS PARA EL PANEL (DASHBOARD)
  // ==========================================

  // Dashboard completo para el Panel
  getDashboard = async (req, res) => {
    try {
      console.log('📊 Iniciando getDashboard...');
      console.log('Usuario:', req.user);

      // Verificar que sea admin
      if (req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Acceso denegado. Solo administradores pueden ver el panel.'
        });
      }

      const { auxiliar_id } = req.query;
      console.log('Auxiliar ID:', auxiliar_id);

      let dashboardData;

      if (auxiliar_id) {
        // Vista filtrada por auxiliar
        dashboardData = await this.getDashboardPorAuxiliar(auxiliar_id);
      } else {
        // Vista general del sistema
        dashboardData = await this.getDashboardGeneral();
      }

      console.log('✅ Dashboard generado exitosamente');

      res.json({
        success: true,
        data: dashboardData
      });
    } catch (error) {
      console.error('❌ Error obteniendo dashboard:', error);
      console.error('Stack:', error.stack);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor',
        error: error.message
      });
    }
  }

  // Dashboard general (todas las actividades)
  async getDashboardGeneral() {
    console.log('Generando dashboard general...');
    
    const resumen = await this.getResumenGeneral();
    const graficaTareas = await this.getGraficaTareasPorEstado();
    const graficaBitacoras = await this.getGraficaBitacorasPorMes();
    const graficaObjetos = await this.getGraficaObjetosPorCategoria();
    const topAuxiliares = await this.getTopAuxiliares();
    const actividadLaboratorios = await this.getActividadPorLaboratorio();
    const tareasProximasVencer = await this.getTareasProximasVencer();

    return {
      tipo: 'general',
      ultima_actualizacion: new Date().toISOString(),
      resumen,
      graficas: {
        tareas_por_estado: graficaTareas,
        bitacoras_por_mes: graficaBitacoras,
        objetos_por_categoria: graficaObjetos
      },
      rankings: {
        top_auxiliares: topAuxiliares
      },
      laboratorios: actividadLaboratorios,
      tareas_urgentes: tareasProximasVencer
    };
  }

  // Dashboard filtrado por auxiliar
  async getDashboardPorAuxiliar(auxiliarId) {
    const auxiliar = await db.get(
      'SELECT id, nombre, email, created_at FROM users WHERE id = ? AND rol = "auxiliar"',
      [auxiliarId]
    );

    if (!auxiliar) {
      throw new Error('Auxiliar no encontrado');
    }

    const resumen = await this.getResumenAuxiliar(auxiliarId);
    const graficaTareas = await this.getGraficaTareasPorEstadoAuxiliar(auxiliarId);
    const graficaBitacoras = await this.getGraficaBitacorasPorMesAuxiliar(auxiliarId);
    const laboratorios = await this.getLaboratoriosAuxiliar(auxiliarId);
    const tareasPendientes = await this.getTareasPendientesAuxiliar(auxiliarId);
    const ranking = await this.getRankingAuxiliar(auxiliarId);

    return {
      tipo: 'auxiliar',
      auxiliar: {
        id: auxiliar.id,
        nombre: auxiliar.nombre,
        email: auxiliar.email,
        activo_desde: auxiliar.created_at
      },
      ultima_actualizacion: new Date().toISOString(),
      resumen,
      graficas: {
        tareas_por_estado: graficaTareas,
        bitacoras_por_mes: graficaBitacoras
      },
      laboratorios,
      tareas_pendientes: tareasPendientes,
      ranking
    };
  }

  // Métodos auxiliares - Vista General
  async getResumenGeneral() {
    const tareas = await db.get(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes,
        SUM(CASE WHEN estado = 'en_proceso' THEN 1 ELSE 0 END) as en_proceso,
        SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
      FROM tareas
    `);

    const bitacoras = await db.get(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN estado = 'borrador' THEN 1 ELSE 0 END) as borradores,
        SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
      FROM bitacoras
    `);

    // Verificar si la tabla objetos_perdidos existe y tiene datos
    let objetos;
    try {
      objetos = await db.get(`
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN estado = 'en_custodia' OR estado = 'encontrado' THEN 1 ELSE 0 END) as en_custodia,
          SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) as entregados
        FROM objetos_perdidos
      `);
    } catch (error) {
      console.log('Tabla objetos_perdidos no existe o tiene error:', error.message);
      objetos = { total: 0, en_custodia: 0, entregados: 0 };
    }

    const usuarios = await db.get(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN activo = 1 THEN 1 ELSE 0 END) as activos,
        SUM(CASE WHEN activo = 0 THEN 1 ELSE 0 END) as inactivos
      FROM users
      WHERE rol = 'auxiliar'
    `);

    return {
      tareas: {
        total: tareas.total || 0,
        pendientes: tareas.pendientes || 0,
        en_proceso: tareas.en_proceso || 0,
        completadas: tareas.completadas || 0
      },
      bitacoras: {
        total: bitacoras.total || 0,
        borradores: bitacoras.borradores || 0,
        completadas: bitacoras.completadas || 0
      },
      objetos: {
        total: objetos.total || 0,
        en_custodia: objetos.en_custodia || 0,
        entregados: objetos.entregados || 0
      },
      usuarios: {
        total: usuarios.total || 0,
        activos: usuarios.activos || 0,
        inactivos: usuarios.inactivos || 0
      }
    };
  }

  async getGraficaTareasPorEstado() {
    const data = await db.all(`
      SELECT 
        estado,
        COUNT(*) as cantidad
      FROM tareas
      GROUP BY estado
    `);

    const total = data.reduce((sum, item) => sum + item.cantidad, 0);

    return data.map(item => ({
      estado: item.estado,
      cantidad: item.cantidad,
      porcentaje: total > 0 ? Math.round((item.cantidad / total) * 100) : 0
    }));
  }

  async getGraficaBitacorasPorMes() {
    const data = await db.all(`
      SELECT 
        strftime('%Y-%m', created_at) as mes,
        COUNT(*) as cantidad
      FROM bitacoras
      WHERE created_at >= date('now', '-6 months')
      GROUP BY mes
      ORDER BY mes ASC
    `);

    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    return data.map(item => {
      const [year, month] = item.mes.split('-');
      return {
        mes: meses[parseInt(month) - 1],
        cantidad: item.cantidad,
        fecha: item.mes
      };
    });
  }

  async getGraficaObjetosPorCategoria() {
    try {
      const data = await db.all(`
        SELECT 
          COALESCE(categoria, 'otros') as categoria,
          COUNT(*) as cantidad
        FROM objetos_perdidos
        GROUP BY categoria
        ORDER BY cantidad DESC
      `);

      const total = data.reduce((sum, item) => sum + item.cantidad, 0);

      return data.map(item => ({
        categoria: item.categoria,
        cantidad: item.cantidad,
        porcentaje: total > 0 ? Math.round((item.cantidad / total) * 100) : 0
      }));
    } catch (error) {
      console.log('Error en getGraficaObjetosPorCategoria:', error.message);
      return [];
    }
  }

  async getTopAuxiliares() {
    const data = await db.all(`
      SELECT 
        u.id,
        u.nombre,
        u.email,
        COUNT(DISTINCT t.id) as tareas_completadas,
        COUNT(DISTINCT b.id) as bitacoras_completadas,
        0 as objetos_encontrados
      FROM users u
      LEFT JOIN tareas t ON u.id = t.auxiliar_id AND t.estado = 'completada'
      LEFT JOIN bitacoras b ON u.id = b.auxiliar_id AND b.estado = 'completada'
      WHERE u.rol = 'auxiliar' AND u.activo = 1
      GROUP BY u.id
      ORDER BY (COUNT(DISTINCT t.id) + COUNT(DISTINCT b.id)) DESC
      LIMIT 5
    `);

    return data.map((item, index) => ({
      posicion: index + 1,
      id: item.id,
      nombre: item.nombre,
      email: item.email,
      tareas: item.tareas_completadas || 0,
      bitacoras: item.bitacoras_completadas || 0,
      objetos: item.objetos_encontrados || 0,
      total: (item.tareas_completadas || 0) + (item.bitacoras_completadas || 0) + (item.objetos_encontrados || 0)
    }));
  }

  async getActividadPorLaboratorio() {
    const data = await db.all(`
      SELECT 
        l.id,
        l.nombre,
        l.ubicacion,
        COUNT(DISTINCT t.id) as tareas,
        COUNT(DISTINCT b.id) as bitacoras,
        0 as objetos
      FROM laboratorios l
      LEFT JOIN tareas t ON l.id = t.laboratorio_id
      LEFT JOIN bitacoras b ON l.id = b.laboratorio_id
      WHERE l.estado = 'activo'
      GROUP BY l.id
      ORDER BY (COUNT(DISTINCT t.id) + COUNT(DISTINCT b.id)) DESC
    `);

    const maxActividad = Math.max(...data.map(l => (l.tareas || 0) + (l.bitacoras || 0)), 1);

    return data.map(item => {
      const actividad = (item.tareas || 0) + (item.bitacoras || 0);
      return {
        id: item.id,
        nombre: item.nombre,
        ubicacion: item.ubicacion,
        tareas: item.tareas || 0,
        bitacoras: item.bitacoras || 0,
        objetos: item.objetos || 0,
        actividad_total: actividad,
        porcentaje: Math.round((actividad / maxActividad) * 100)
      };
    });
  }

  async getTareasProximasVencer() {
    const data = await db.all(`
      SELECT 
        t.id,
        t.titulo,
        t.descripcion,
        t.prioridad,
        t.fecha_limite,
        t.estado,
        u.nombre as auxiliar_nombre,
        l.nombre as laboratorio_nombre,
        julianday(t.fecha_limite) - julianday('now') as dias_restantes
      FROM tareas t
      LEFT JOIN users u ON t.auxiliar_id = u.id
      LEFT JOIN laboratorios l ON t.laboratorio_id = l.id
      WHERE t.estado != 'completada' 
        AND t.fecha_limite IS NOT NULL
        AND t.fecha_limite >= datetime('now')
        AND t.fecha_limite <= datetime('now', '+7 days')
      ORDER BY t.fecha_limite ASC
      LIMIT 10
    `);

    return data.map(item => ({
      id: item.id,
      titulo: item.titulo,
      descripcion: item.descripcion,
      prioridad: item.prioridad,
      fecha_limite: item.fecha_limite,
      dias_restantes: Math.ceil(item.dias_restantes),
      auxiliar: item.auxiliar_nombre,
      laboratorio: item.laboratorio_nombre,
      urgencia: item.dias_restantes < 1 ? 'alta' : item.dias_restantes < 3 ? 'media' : 'baja'
    }));
  }

  // Métodos auxiliares - Vista por Auxiliar
  async getResumenAuxiliar(auxiliarId) {
    const tareas = await db.get(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes,
        SUM(CASE WHEN estado = 'en_proceso' THEN 1 ELSE 0 END) as en_proceso,
        SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
      FROM tareas
      WHERE auxiliar_id = ?
    `, [auxiliarId]);

    const bitacoras = await db.get(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN estado = 'borrador' THEN 1 ELSE 0 END) as borradores,
        SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
      FROM bitacoras
      WHERE auxiliar_id = ?
    `, [auxiliarId]);

    let objetos;
    try {
      objetos = await db.get(`
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN estado = 'en_custodia' OR estado = 'encontrado' THEN 1 ELSE 0 END) as en_custodia,
          SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) as entregados
        FROM objetos_perdidos
        WHERE auxiliar_encontro_id = ?
      `, [auxiliarId]);
    } catch (error) {
      objetos = { total: 0, en_custodia: 0, entregados: 0 };
    }

    return {
      tareas: {
        total: tareas.total || 0,
        pendientes: tareas.pendientes || 0,
        en_proceso: tareas.en_proceso || 0,
        completadas: tareas.completadas || 0
      },
      bitacoras: {
        total: bitacoras.total || 0,
        borradores: bitacoras.borradores || 0,
        completadas: bitacoras.completadas || 0
      },
      objetos: {
        total: objetos.total || 0,
        en_custodia: objetos.en_custodia || 0,
        entregados: objetos.entregados || 0
      }
    };
  }

  async getGraficaTareasPorEstadoAuxiliar(auxiliarId) {
    const data = await db.all(`
      SELECT 
        estado,
        COUNT(*) as cantidad
      FROM tareas
      WHERE auxiliar_id = ?
      GROUP BY estado
    `, [auxiliarId]);

    const total = data.reduce((sum, item) => sum + item.cantidad, 0);

    return data.map(item => ({
      estado: item.estado,
      cantidad: item.cantidad,
      porcentaje: total > 0 ? Math.round((item.cantidad / total) * 100) : 0
    }));
  }

  async getGraficaBitacorasPorMesAuxiliar(auxiliarId) {
    const data = await db.all(`
      SELECT 
        strftime('%Y-%m', created_at) as mes,
        COUNT(*) as cantidad
      FROM bitacoras
      WHERE auxiliar_id = ?
        AND created_at >= date('now', '-6 months')
      GROUP BY mes
      ORDER BY mes ASC
    `, [auxiliarId]);

    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    return data.map(item => {
      const [year, month] = item.mes.split('-');
      return {
        mes: meses[parseInt(month) - 1],
        cantidad: item.cantidad,
        fecha: item.mes
      };
    });
  }

  async getLaboratoriosAuxiliar(auxiliarId) {
    const user = await db.get(
      'SELECT laboratorios_asignados FROM users WHERE id = ?',
      [auxiliarId]
    );

    if (!user || !user.laboratorios_asignados) {
      return [];
    }

    const labsAsignados = JSON.parse(user.laboratorios_asignados);

    if (labsAsignados.length === 0) {
      return [];
    }

    const placeholders = labsAsignados.map(() => '?').join(',');
    const data = await db.all(`
      SELECT 
        l.id,
        l.nombre,
        l.ubicacion,
        COUNT(DISTINCT t.id) as tareas,
        COUNT(DISTINCT b.id) as bitacoras
      FROM laboratorios l
      LEFT JOIN tareas t ON l.id = t.laboratorio_id AND t.auxiliar_id = ?
      LEFT JOIN bitacoras b ON l.id = b.laboratorio_id AND b.auxiliar_id = ?
      WHERE l.id IN (${placeholders})
      GROUP BY l.id
      ORDER BY (COUNT(DISTINCT t.id) + COUNT(DISTINCT b.id)) DESC
    `, [auxiliarId, auxiliarId, ...labsAsignados]);

    return data.map(item => ({
      id: item.id,
      nombre: item.nombre,
      ubicacion: item.ubicacion,
      actividades: (item.tareas || 0) + (item.bitacoras || 0)
    }));
  }

  async getTareasPendientesAuxiliar(auxiliarId) {
    const data = await db.all(`
      SELECT 
        t.id,
        t.titulo,
        t.descripcion,
        t.prioridad,
        t.fecha_limite,
        t.estado,
        l.nombre as laboratorio_nombre,
        julianday(t.fecha_limite) - julianday('now') as dias_restantes
      FROM tareas t
      LEFT JOIN laboratorios l ON t.laboratorio_id = l.id
      WHERE t.auxiliar_id = ?
        AND t.estado != 'completada'
        AND t.fecha_limite IS NOT NULL
      ORDER BY t.fecha_limite ASC
      LIMIT 5
    `, [auxiliarId]);

    return data.map(item => ({
      id: item.id,
      titulo: item.titulo,
      prioridad: item.prioridad,
      fecha_limite: item.fecha_limite,
      dias_restantes: Math.ceil(item.dias_restantes),
      laboratorio: item.laboratorio_nombre,
      urgencia: item.dias_restantes < 1 ? 'alta' : item.dias_restantes < 3 ? 'media' : 'baja'
    }));
  }

  async getRankingAuxiliar(auxiliarId) {
    const todos = await db.all(`
      SELECT 
        u.id,
        COUNT(DISTINCT t.id) as tareas,
        COUNT(DISTINCT b.id) as bitacoras,
        0 as objetos
      FROM users u
      LEFT JOIN tareas t ON u.id = t.auxiliar_id AND t.estado = 'completada'
      LEFT JOIN bitacoras b ON u.id = b.auxiliar_id AND b.estado = 'completada'
      WHERE u.rol = 'auxiliar' AND u.activo = 1
      GROUP BY u.id
      ORDER BY (COUNT(DISTINCT t.id) + COUNT(DISTINCT b.id)) DESC
    `);

    const posicion = todos.findIndex(a => a.id === parseInt(auxiliarId)) + 1;
    const total = todos.length;
    const auxiliarData = todos.find(a => a.id === parseInt(auxiliarId));

    if (!auxiliarData) {
      return { posicion: 0, total: 0 };
    }

    const promedioTareas = todos.reduce((sum, a) => sum + a.tareas, 0) / total;
    const promedioBitacoras = todos.reduce((sum, a) => sum + a.bitacoras, 0) / total;
    const promedioObjetos = 0;

    const diffTareas = promedioTareas > 0 ? ((auxiliarData.tareas - promedioTareas) / promedioTareas) * 100 : 0;
    const diffBitacoras = promedioBitacoras > 0 ? ((auxiliarData.bitacoras - promedioBitacoras) / promedioBitacoras) * 100 : 0;

    return {
      posicion,
      total,
      comparacion: {
        tareas: {
          cantidad: auxiliarData.tareas,
          promedio: Math.round(promedioTareas),
          diferencia: Math.round(diffTareas)
        },
        bitacoras: {
          cantidad: auxiliarData.bitacoras,
          promedio: Math.round(promedioBitacoras),
          diferencia: Math.round(diffBitacoras)
        },
        objetos: {
          cantidad: auxiliarData.objetos,
          promedio: Math.round(promedioObjetos),
          diferencia: 0
        }
      }
    };
  }

  // Lista de auxiliares para el dropdown
  getListaAuxiliares = async (req, res) => {
    try {
      if (req.user.rol !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Acceso denegado'
        });
      }

      const auxiliares = await db.all(`
        SELECT id, nombre, email
        FROM users
        WHERE rol = 'auxiliar' AND activo = 1
        ORDER BY nombre ASC
      `);

      res.json({
        success: true,
        data: auxiliares
      });
    } catch (error) {
      console.error('Error obteniendo lista de auxiliares:', error);
      res.status(500).json({
        success: false,
        message: 'Error en el servidor'
      });
    }
  }
}

module.exports = new StatsController();