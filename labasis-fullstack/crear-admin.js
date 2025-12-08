// crear-admin.js - Versión mejorada
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');

// Ruta a la base de datos
const dbPath = path.join(__dirname, 'database', 'labasis.db');
console.log('📂 Ruta de BD:', dbPath);

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Error conectando a la base de datos:', err.message);
    process.exit(1);
  }
  console.log('✅ Conectado a la base de datos');
});

async function crearAdmin() {
  const email = 'admin@labasis.com';
  const password = 'admin123';
  const nombre = 'Administrador';
  
  console.log('');
  console.log('🔍 Buscando usuario con email:', email);
  
  db.get('SELECT * FROM users WHERE email = ?', [email], (err, user) => {
    if (err) {
      console.error('❌ Error buscando usuario:', err.message);
      db.close();
      process.exit(1);
      return;
    }
    
    if (user) {
      console.log('');
      console.log('📋 Usuario encontrado:');
      console.log('   ID:', user.id);
      console.log('   📧 Email:', user.email);
      console.log('   📝 Nombre:', user.nombre);
      console.log('   👤 Rol:', user.rol);
      console.log('   ✓ Activo:', user.activo === 1 ? 'Sí' : 'No');
      
      if (user.rol !== 'admin') {
        console.log('');
        console.log('⚠️  El usuario existe pero no es admin');
        console.log('🔧 Actualizando rol a admin...');
        
        db.run('UPDATE users SET rol = ?, activo = 1 WHERE id = ?', ['admin', user.id], (err) => {
          if (err) {
            console.error('❌ Error actualizando rol:', err.message);
          } else {
            console.log('✅ Rol actualizado exitosamente a admin');
            console.log('');
            console.log('🎉 Ahora puedes iniciar sesión como admin');
          }
          db.close();
        });
      } else {
        console.log('');
        console.log('✅ El usuario ya tiene rol de admin');
        console.log('');
        console.log('🎉 Puedes iniciar sesión con:');
        console.log('   📧 Email:', email);
        console.log('   🔑 Password:', password);
        db.close();
      }
    } else {
      console.log('');
      console.log('📝 Usuario no existe, creando nuevo admin...');
      
      bcrypt.hash(password, 10, (err, hashedPassword) => {
        if (err) {
          console.error('❌ Error hasheando password:', err.message);
          db.close();
          process.exit(1);
          return;
        }
        
        const sql = `INSERT INTO users (email, password, nombre, rol, activo, created_at, updated_at) 
                     VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`;
        
        db.run(sql, [email, hashedPassword, nombre, 'admin', 1], function(err) {
          if (err) {
            console.error('❌ Error creando admin:', err.message);
            db.close();
            process.exit(1);
            return;
          }
          
          console.log('');
          console.log('✅ ¡Usuario admin creado exitosamente!');
          console.log('');
          console.log('📋 Credenciales:');
          console.log('   ID:', this.lastID);
          console.log('   📧 Email:', email);
          console.log('   🔑 Password:', password);
          console.log('   👤 Rol: admin');
          console.log('');
          console.log('🎉 Ahora puedes:');
          console.log('   1. Cerrar sesión en la app Flutter');
          console.log('   2. Iniciar sesión con las credenciales de arriba');
          console.log('   3. Acceder a la tarjeta de Auxiliares');
          console.log('');
          
          db.close();
        });
      });
    }
  });
}

console.log('');
console.log('╔══════════════════════════════════════════╗');
console.log('║  🚀 Script de Creación de Admin         ║');
console.log('║     LABASIS Backend                      ║');
console.log('╚══════════════════════════════════════════╝');
console.log('');

crearAdmin();