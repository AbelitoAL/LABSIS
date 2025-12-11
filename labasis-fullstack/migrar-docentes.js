// migrar-docentes.js - Script para agregar soporte de docentes
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'database', 'labasis.db');
const db = new sqlite3.Database(dbPath);

console.log('');
console.log('╔══════════════════════════════════════════╗');
console.log('║  🚀 MIGRACIÓN: SISTEMA DE DOCENTES       ║');
console.log('╚══════════════════════════════════════════╝');
console.log('');

let step = 0;

// PASO 1: Agregar columna codigo a users
function paso1_agregarColumnaCodigo() {
  step++;
  console.log(`PASO ${step}: Verificando columna 'codigo' en tabla 'users'...`);
  console.log('');

  db.all("PRAGMA table_info(users)", [], (err, columns) => {
    if (err) {
      console.error('❌ Error:', err.message);
      db.close();
      return;
    }

    const columnNames = columns.map(c => c.name);
    
    if (columnNames.includes('codigo')) {
      console.log('✅ Columna \'codigo\' ya existe');
      console.log('');
      paso2_crearTablaDocentes();
    } else {
      console.log('➕ Agregando columna \'codigo\'...');
      console.log('   (SQLite no soporta UNIQUE en ALTER TABLE, se agregará sin constraint)');
      console.log('   La restricción UNIQUE se manejará a nivel de aplicación');
      
      // SQLite no permite agregar columna con UNIQUE en ALTER TABLE
      // Se agrega sin UNIQUE y se maneja la unicidad en la app
      db.run('ALTER TABLE users ADD COLUMN codigo TEXT', (err) => {
        if (err) {
          console.error('❌ Error agregando columna:', err.message);
          db.close();
        } else {
          console.log('✅ Columna \'codigo\' agregada exitosamente');
          console.log('');
          paso2_crearTablaDocentes();
        }
      });
    }
  });
}

// PASO 2: Crear tabla docentes
function paso2_crearTablaDocentes() {
  step++;
  console.log(`PASO ${step}: Creando tabla 'docentes'...`);
  console.log('');

  const sql = `
    CREATE TABLE IF NOT EXISTS docentes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL UNIQUE,
      codigo TEXT NOT NULL UNIQUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      created_by INTEGER,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  `;

  db.run(sql, (err) => {
    if (err) {
      console.error('❌ Error creando tabla docentes:', err.message);
      db.close();
    } else {
      console.log('✅ Tabla \'docentes\' creada/verificada');
      console.log('');
      paso3_crearIndices();
    }
  });
}

// PASO 3: Crear índices
function paso3_crearIndices() {
  step++;
  console.log(`PASO ${step}: Creando índices...`);
  console.log('');

  db.run('CREATE INDEX IF NOT EXISTS idx_docentes_codigo ON docentes(codigo)', (err) => {
    if (err) {
      console.error('❌ Error creando índice:', err.message);
    } else {
      console.log('✅ Índice \'idx_docentes_codigo\' creado');
    }
    
    finalizarMigracion();
  });
}

// Finalizar
function finalizarMigracion() {
  console.log('');
  console.log('╔══════════════════════════════════════════╗');
  console.log('║  🎉 MIGRACIÓN COMPLETADA                 ║');
  console.log('╚══════════════════════════════════════════╝');
  console.log('');
  console.log('📋 Cambios aplicados:');
  console.log('   ✅ Columna \'codigo\' en users');
  console.log('   ✅ Tabla \'docentes\' creada');
  console.log('   ✅ Índices optimizados');
  console.log('');
  console.log('🚀 Próximos pasos:');
  console.log('   1. Reemplaza src/config/database.js');
  console.log('   2. Reinicia el backend: npm run dev');
  console.log('   3. Verifica que no haya errores');
  console.log('');
  
  db.close();
}

// Iniciar migración
paso1_agregarColumnaCodigo();