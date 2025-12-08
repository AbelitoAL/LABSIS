// setup-auxiliares.js - Script maestro para configurar todo
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');

const dbPath = path.join(__dirname, 'database', 'labasis.db');
const db = new sqlite3.Database(dbPath);

console.log('');
console.log('╔══════════════════════════════════════════╗');
console.log('║  🚀 SETUP COMPLETO - SISTEMA AUXILIARES  ║');
console.log('╚══════════════════════════════════════════╝');
console.log('');

let step = 0;

// PASO 1: Agregar columnas a users
function paso1_agregarColumnasUsers() {
  step++;
  console.log(`PASO ${step}: Verificando columnas en tabla 'users'...`);
  console.log('');

  db.all("PRAGMA table_info(users)", [], (err, columns) => {
    if (err) {
      console.error('❌ Error:', err.message);
      db.close();
      return;
    }

    const columnNames = columns.map(c => c.name);
    const columnsToAdd = [];

    if (!columnNames.includes('telefono')) {
      columnsToAdd.push({ name: 'telefono', sql: 'ALTER TABLE users ADD COLUMN telefono TEXT' });
    }
    if (!columnNames.includes('estado')) {
      columnsToAdd.push({ name: 'estado', sql: "ALTER TABLE users ADD COLUMN estado TEXT DEFAULT 'activo'" });
    }
    if (!columnNames.includes('notas')) {
      columnsToAdd.push({ name: 'notas', sql: 'ALTER TABLE users ADD COLUMN notas TEXT' });
    }

    if (columnsToAdd.length === 0) {
      console.log('✅ Todas las columnas ya existen');
      console.log('');
      paso2_crearTablasAuxiliares();
      return;
    }

    let completed = 0;
    columnsToAdd.forEach((column) => {
      db.run(column.sql, (err) => {
        if (err) {
          console.error(`❌ Error agregando '${column.name}':`, err.message);
        } else {
          console.log(`✅ Columna '${column.name}' agregada`);
        }

        completed++;
        if (completed === columnsToAdd.length) {
          console.log('');
          paso2_crearTablasAuxiliares();
        }
      });
    });
  });
}

// PASO 2: Crear tablas auxiliares
function paso2_crearTablasAuxiliares() {
  step++;
  console.log(`PASO ${step}: Creando tablas de auxiliares...`);
  console.log('');

  const tables = [
    {
      name: 'auxiliares_laboratorios',
      sql: `
        CREATE TABLE IF NOT EXISTS auxiliares_laboratorios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          auxiliar_id INTEGER NOT NULL,
          laboratorio_id INTEGER NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          created_by INTEGER,
          FOREIGN KEY (auxiliar_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id) ON DELETE CASCADE,
          FOREIGN KEY (created_by) REFERENCES users(id),
          UNIQUE(auxiliar_id, laboratorio_id)
        )
      `
    },
    {
      name: 'auxiliares_horarios',
      sql: `
        CREATE TABLE IF NOT EXISTS auxiliares_horarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          auxiliar_id INTEGER NOT NULL,
          dia_semana TEXT NOT NULL,
          hora_inicio TEXT NOT NULL,
          hora_fin TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          created_by INTEGER,
          FOREIGN KEY (auxiliar_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (created_by) REFERENCES users(id)
        )
      `
    }
  ];

  let completed = 0;
  tables.forEach((table) => {
    db.run(table.sql, (err) => {
      if (err) {
        console.error(`❌ Error creando '${table.name}':`, err.message);
      } else {
        console.log(`✅ Tabla '${table.name}' creada/verificada`);
      }

      completed++;
      if (completed === tables.length) {
        console.log('');
        paso3_crearAdmin();
      }
    });
  });
}

// PASO 3: Crear usuario admin
function paso3_crearAdmin() {
  step++;
  console.log(`PASO ${step}: Verificando usuario administrador...`);
  console.log('');

  const email = 'admin@labasis.com';
  const password = 'admin123';
  const nombre = 'Administrador';

  db.get('SELECT * FROM users WHERE email = ?', [email], (err, user) => {
    if (err) {
      console.error('❌ Error:', err.message);
      finalizarSetup();
      return;
    }

    if (user) {
      console.log(`✅ Usuario admin existe (ID: ${user.id})`);
      
      if (user.rol !== 'admin') {
        console.log('⚠️  Actualizando rol a admin...');
        db.run('UPDATE users SET rol = ?, activo = 1 WHERE id = ?', ['admin', user.id], (err) => {
          if (err) {
            console.error('❌ Error actualizando rol:', err.message);
          } else {
            console.log('✅ Rol actualizado a admin');
          }
          finalizarSetup();
        });
      } else {
        finalizarSetup();
      }
    } else {
      console.log('📝 Creando usuario admin...');
      
      bcrypt.hash(password, 10, (err, hashedPassword) => {
        if (err) {
          console.error('❌ Error:', err.message);
          finalizarSetup();
          return;
        }

        const sql = `INSERT INTO users (email, password, nombre, rol, activo, estado, created_at, updated_at) 
                     VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`;

        db.run(sql, [email, hashedPassword, nombre, 'admin', 1, 'activo'], function(err) {
          if (err) {
            console.error('❌ Error creando admin:', err.message);
          } else {
            console.log(`✅ Usuario admin creado (ID: ${this.lastID})`);
            console.log(`   📧 Email: ${email}`);
            console.log(`   🔑 Password: ${password}`);
          }
          finalizarSetup();
        });
      });
    }
  });
}

// Finalizar
function finalizarSetup() {
  console.log('');
  console.log('╔══════════════════════════════════════════╗');
  console.log('║  🎉 SETUP COMPLETADO EXITOSAMENTE        ║');
  console.log('╚══════════════════════════════════════════╝');
  console.log('');
  console.log('📋 Resumen:');
  console.log('   ✅ Columnas agregadas a tabla users');
  console.log('   ✅ Tablas de auxiliares creadas');
  console.log('   ✅ Usuario admin configurado');
  console.log('');
  console.log('🚀 Próximos pasos:');
  console.log('   1. Reinicia el backend: npm run dev');
  console.log('   2. En Flutter, cierra sesión');
  console.log('   3. Inicia sesión con:');
  console.log('      📧 Email: admin@labasis.com');
  console.log('      🔑 Password: admin123');
  console.log('   4. Accede a la tarjeta "Auxiliares"');
  console.log('');
  
  db.close();
}

// Iniciar
paso1_agregarColumnasUsers();