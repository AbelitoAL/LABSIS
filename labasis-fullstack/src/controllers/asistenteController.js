// src/controllers/asistenteController.js

const { GoogleGenerativeAI } = require('@google/generative-ai');
const db = require('../config/database');

class AsistenteController {
  constructor() {
    // Inicializar Gemini
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });
  }

  // Obtener contexto del sistema para el asistente
  async getSystemContext(userId) {
    try {
      // Obtener información del usuario
      const user = await db.get('SELECT id, nombre, email, rol FROM users WHERE id = ?', [userId]);

      // Obtener tareas pendientes
      const tareas = await db.all(
        `SELECT COUNT(*) as total, 
                SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) as pendientes,
                SUM(CASE WHEN estado = 'en_proceso' THEN 1 ELSE 0 END) as en_proceso,
                SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
         FROM tareas 
         WHERE auxiliar_id = ?`,
        [userId]
      );

      // Obtener laboratorios
      const laboratorios = await db.all('SELECT id, nombre, ubicacion FROM laboratorios');

      // Obtener objetos perdidos
      const objetosPerdidos = await db.all(
        `SELECT COUNT(*) as total,
                SUM(CASE WHEN estado = 'en_custodia' THEN 1 ELSE 0 END) as en_custodia,
                SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) as entregados
         FROM objetos_perdidos`
      );

      // Obtener bitácoras
      const bitacoras = await db.all(
        `SELECT COUNT(*) as total,
                SUM(CASE WHEN estado = 'borrador' THEN 1 ELSE 0 END) as borradores,
                SUM(CASE WHEN estado = 'completada' THEN 1 ELSE 0 END) as completadas
         FROM bitacoras
         WHERE auxiliar_id = ?`,
        [userId]
      );

      return {
        user,
        tareas: tareas[0],
        laboratorios,
        objetosPerdidos: objetosPerdidos[0],
        bitacoras: bitacoras[0],
      };
    } catch (error) {
      console.error('Error obteniendo contexto:', error);
      return null;
    }
  }

  // Construir prompt del sistema
  buildSystemPrompt(context) {
    return `Eres un asistente virtual inteligente llamado "Laby" para el sistema LABASIS (Sistema de Gestión de Laboratorios).

INFORMACIÓN DEL USUARIO:
- Nombre: ${context.user.nombre}
- Rol: ${context.user.rol === 'admin' ? 'Administrador' : 'Auxiliar de Laboratorio'}

ESTADO ACTUAL DEL SISTEMA:
- Tareas totales: ${context.tareas.total || 0}
  * Pendientes: ${context.tareas.pendientes || 0}
  * En proceso: ${context.tareas.en_proceso || 0}
  * Completadas: ${context.tareas.completadas || 0}

- Laboratorios disponibles: ${context.laboratorios.length}
${context.laboratorios.map(lab => `  * ${lab.nombre} - ${lab.ubicacion}`).join('\n')}

- Objetos perdidos:
  * Total: ${context.objetosPerdidos.total || 0}
  * En custodia: ${context.objetosPerdidos.en_custodia || 0}
  * Entregados: ${context.objetosPerdidos.entregados || 0}

- Bitácoras:
  * Total: ${context.bitacoras.total || 0}
  * Borradores: ${context.bitacoras.borradores || 0}
  * Completadas: ${context.bitacoras.completadas || 0}

INSTRUCCIONES:
1. Responde de manera amigable, profesional y concisa
2. Usa emojis cuando sea apropiado para hacer las respuestas más amigables
3. Si te preguntan sobre el sistema, usa la información proporcionada arriba
4. Si necesitas más información específica, pide amablemente que reformulen la pregunta
5. Puedes dar sugerencias y consejos sobre gestión de laboratorios
6. Mantén un tono positivo y servicial
7. Si te preguntan algo que no puedas responder con la información disponible, sé honesto al respecto
8. Responde en español de forma natural
9. Sé breve pero informativo (máximo 200 palabras por respuesta)

CAPACIDADES:
- Responder preguntas sobre tareas, laboratorios, bitácoras y objetos perdidos
- Proporcionar estadísticas y resúmenes
- Dar sugerencias y recordatorios
- Ayudar con la organización del trabajo

EJEMPLO DE RESPUESTAS:
Usuario: "¿Cuántas tareas tengo?"
Laby: "¡Hola! 👋 Tienes un total de ${context.tareas.total || 0} tareas. De estas, ${context.tareas.pendientes || 0} están pendientes, ${context.tareas.en_proceso || 0} en proceso y ${context.tareas.completadas || 0} completadas. ¿Necesitas ayuda con alguna tarea específica?"

Ahora responde al usuario de forma similar.`;
  }

  // Chat con el asistente
  async chat(req, res) {
    try {
      const { mensaje, historial = [] } = req.body;
      const userId = req.user.id;

      if (!mensaje || mensaje.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'El mensaje es requerido',
        });
      }

      // Verificar API key
      if (!process.env.GEMINI_API_KEY) {
        return res.status(500).json({
          success: false,
          message: 'API key de Gemini no configurada',
        });
      }

      // Obtener contexto del sistema
      const context = await this.getSystemContext(userId);
      if (!context) {
        return res.status(500).json({
          success: false,
          message: 'Error obteniendo contexto del sistema',
        });
      }

      // Construir prompt del sistema
      const systemPrompt = this.buildSystemPrompt(context);

      // Construir historial de conversación para Gemini
      const chat = this.model.startChat({
        history: [
          {
            role: 'user',
            parts: [{ text: systemPrompt }],
          },
          {
            role: 'model',
            parts: [{ text: '¡Entendido! Estoy listo para ayudarte con LABASIS. ¿En qué puedo asistirte hoy?' }],
          },
          // Agregar historial previo
          ...historial.flatMap(msg => [
            {
              role: 'user',
              parts: [{ text: msg.mensaje }],
            },
            {
              role: 'model',
              parts: [{ text: msg.respuesta }],
            },
          ]),
        ],
      });

      // Enviar mensaje y obtener respuesta
      const result = await chat.sendMessage(mensaje);
      const respuesta = result.response.text();

      // Guardar en historial de base de datos (opcional)
      await db.run(
        `INSERT INTO conversaciones_asistente (usuario_id, mensaje, respuesta, created_at) 
         VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
        [userId, mensaje, respuesta]
      );

      res.json({
        success: true,
        data: {
          mensaje,
          respuesta,
          timestamp: new Date().toISOString(),
        },
      });
    } catch (error) {
      console.error('Error en chat con asistente:', error);
      res.status(500).json({
        success: false,
        message: 'Error procesando mensaje',
        error: error.message,
      });
    }
  }

  // Obtener historial de conversación
  async getHistorial(req, res) {
    try {
      const userId = req.user.id;
      const { limit = 50 } = req.query;

      const historial = await db.all(
        `SELECT mensaje, respuesta, created_at 
         FROM conversaciones_asistente 
         WHERE usuario_id = ? 
         ORDER BY created_at DESC 
         LIMIT ?`,
        [userId, parseInt(limit)]
      );

      res.json({
        success: true,
        data: historial.reverse(), // Más antiguos primero
      });
    } catch (error) {
      console.error('Error obteniendo historial:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo historial',
      });
    }
  }

  // Limpiar historial de conversación
  async clearHistorial(req, res) {
    try {
      const userId = req.user.id;

      await db.run(
        'DELETE FROM conversaciones_asistente WHERE usuario_id = ?',
        [userId]
      );

      res.json({
        success: true,
        message: 'Historial limpiado exitosamente',
      });
    } catch (error) {
      console.error('Error limpiando historial:', error);
      res.status(500).json({
        success: false,
        message: 'Error limpiando historial',
      });
    }
  }

  // Sugerencias inteligentes
  async getSugerencias(req, res) {
    try {
      const userId = req.user.id;
      const context = await this.getSystemContext(userId);

      const sugerencias = [];

      // Sugerencias basadas en el contexto
      if (context.tareas.pendientes > 0) {
        sugerencias.push({
          tipo: 'tareas',
          mensaje: `Tienes ${context.tareas.pendientes} tareas pendientes. ¿Quieres revisarlas?`,
          accion: 'ver_tareas',
        });
      }

      if (context.objetosPerdidos.en_custodia > 0) {
        sugerencias.push({
          tipo: 'objetos',
          mensaje: `Hay ${context.objetosPerdidos.en_custodia} objetos perdidos en custodia.`,
          accion: 'ver_objetos',
        });
      }

      if (context.bitacoras.borradores > 0) {
        sugerencias.push({
          tipo: 'bitacoras',
          mensaje: `Tienes ${context.bitacoras.borradores} bitácoras en borrador pendientes de completar.`,
          accion: 'ver_bitacoras',
        });
      }

      res.json({
        success: true,
        data: sugerencias,
      });
    } catch (error) {
      console.error('Error obteniendo sugerencias:', error);
      res.status(500).json({
        success: false,
        message: 'Error obteniendo sugerencias',
      });
    }
  }
}

module.exports = new AsistenteController();