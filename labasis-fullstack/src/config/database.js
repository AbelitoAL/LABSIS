// src/config/database.js

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || './database/labasis.db';

class Database {
  constructor() {
    this.db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Error conectando a la base de datos:', err.message);
      } else {
        console.log('✅ Conectado a la base de datos SQLite');
        this.initTables();
      }
    });
  }

  initTables() {
    // Tabla de usuarios
    this.db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nombre TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'auxiliar',
        activo INTEGER DEFAULT 1,
        laboratorios_asignados TEXT,
        fcm_token TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tabla de laboratorios
    this.db.run(`
      CREATE TABLE IF NOT EXISTS laboratorios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigo TEXT UNIQUE NOT NULL,
        ubicacion TEXT,
        capacidad INTEGER,
        equipamiento TEXT,
        manuales TEXT,
        contraseñas TEXT,
        horarios TEXT,
        auxiliares_asignados TEXT,
        estado TEXT DEFAULT 'activo',
        imagenes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        modificado_por INTEGER
      )
    `);

    // Tabla de tareas
    this.db.run(`
      CREATE TABLE IF NOT EXISTS tareas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        laboratorio_id INTEGER,
        auxiliar_id INTEGER,
        prioridad TEXT DEFAULT 'media',
        estado TEXT DEFAULT 'pendiente',
        fecha_limite DATETIME,
        fecha_completada DATETIME,
        creado_por INTEGER,
        evidencias TEXT,
        tags TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id),
        FOREIGN KEY (auxiliar_id) REFERENCES users(id),
        FOREIGN KEY (creado_por) REFERENCES users(id)
      )
    `);

    // Tabla de iconos
    this.db.run(`
      CREATE TABLE IF NOT EXISTS iconos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        imagen_url TEXT,
        categoria TEXT DEFAULT 'otros',
        tags TEXT,
        creado_por INTEGER,
        uso INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (creado_por) REFERENCES users(id)
      )
    `);

    // Tabla de plantillas
    this.db.run(`
      CREATE TABLE IF NOT EXISTS plantillas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        laboratorio_id INTEGER,
        ancho INTEGER NOT NULL,
        alto INTEGER NOT NULL,
        elementos TEXT,
        version INTEGER DEFAULT 1,
        creado_por INTEGER,
        activo INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id),
        FOREIGN KEY (creado_por) REFERENCES users(id)
      )
    `);

    // Tabla de bitácoras
    this.db.run(`
      CREATE TABLE IF NOT EXISTS bitacoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        plantilla_id INTEGER,
        laboratorio_id INTEGER,
        fecha DATETIME,
        turno TEXT,
        auxiliar_id INTEGER,
        atributos TEXT,
        grilla TEXT,
        resumen TEXT,
        exportada INTEGER DEFAULT 0,
        estado TEXT DEFAULT 'borrador',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (plantilla_id) REFERENCES plantillas(id),
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id),
        FOREIGN KEY (auxiliar_id) REFERENCES users(id)
      )
    `);

    // Tabla de objetos perdidos
    this.db.run(`
      CREATE TABLE IF NOT EXISTS objetos_perdidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foto_objeto TEXT,
        descripcion TEXT,
        categoria TEXT,
        laboratorio_id INTEGER,
        auxiliar_encontro_id INTEGER,
        fecha_encontrado DATETIME,
        estado TEXT DEFAULT 'encontrado',
        entrega TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id),
        FOREIGN KEY (auxiliar_encontro_id) REFERENCES users(id)
      )
    `);

    console.log('✅ Tablas de base de datos inicializadas');
  }

  // Métodos auxiliares
  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(sql, params, function(err) {
        if (err) {
          reject(err);
        } else {
          resolve({ id: this.lastID, changes: this.changes });
        }
      });
    });
  }

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.get(sql, params, (err, result) => {
        if (err) {
          reject(err);
        } else {
          resolve(result);
        }
      });
    });
  }

  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(sql, params, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      this.db.close((err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }
}

module.exports = new Database();