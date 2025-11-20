// src/migrations/add_conversaciones_asistente.js

const db = require('../config/database');

async function migrate() {
  try {
    console.log('📝 Creando tabla conversaciones_asistente...');

    await db.run(`
      CREATE TABLE IF NOT EXISTS conversaciones_asistente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        mensaje TEXT NOT NULL,
        respuesta TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    console.log('✅ Tabla conversaciones_asistente creada exitosamente');

    // Crear índice para mejorar rendimiento
    await db.run(`
      CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario 
      ON conversaciones_asistente(usuario_id, created_at DESC)
    `);

    console.log('✅ Índice creado exitosamente');
  } catch (error) {
    console.error('❌ Error en migración:', error);
    throw error;
  }
}

// Ejecutar migración si se llama directamente
if (require.main === module) {
  migrate()
    .then(() => {
      console.log('✅ Migración completada');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Error en migración:', error);
      process.exit(1);
    });
}

module.exports = migrate;