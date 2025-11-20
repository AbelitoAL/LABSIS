// src/utils/initDatabase.js

const bcrypt = require('bcryptjs');
const db = require('../config/database');

async function initDatabase() {
  try {
    console.log('🔄 Inicializando base de datos con datos de prueba...');

    // Esperar a que la DB esté lista
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Crear usuario admin
    const adminPassword = await bcrypt.hash('admin123', 10);
    await db.run(
      `INSERT OR IGNORE INTO users (email, password, nombre, rol, laboratorios_asignados) 
       VALUES (?, ?, ?, ?, ?)`,
      ['admin@labasis.com', adminPassword, 'Administrador', 'admin', JSON.stringify([])]
    );

    // Crear usuario auxiliar
    const auxiliarPassword = await bcrypt.hash('auxiliar123', 10);
    await db.run(
      `INSERT OR IGNORE INTO users (email, password, nombre, rol, laboratorios_asignados) 
       VALUES (?, ?, ?, ?, ?)`,
      ['auxiliar@labasis.com', auxiliarPassword, 'Juan Pérez', 'auxiliar', JSON.stringify([1])]
    );

    // Crear laboratorio de ejemplo
    await db.run(
      `INSERT OR IGNORE INTO laboratorios (nombre, codigo, ubicacion, capacidad, estado) 
       VALUES (?, ?, ?, ?, ?)`,
      ['Laboratorio de Sistemas Operativos', 'LAB-SO-01', 'Edificio B, Piso 3', 30, 'activo']
    );

    console.log('✅ Base de datos inicializada con datos de prueba');
    console.log('\n📧 Usuarios creados:');
    console.log('   Admin: admin@labasis.com / admin123');
    console.log('   Auxiliar: auxiliar@labasis.com / auxiliar123\n');

    await db.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error inicializando base de datos:', error);
    process.exit(1);
  }
}

initDatabase();