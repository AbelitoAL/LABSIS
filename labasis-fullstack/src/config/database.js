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
        codigo TEXT,
        activo INTEGER DEFAULT 1,
        telefono TEXT,
        estado TEXT DEFAULT 'activo',
        notas TEXT,
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

    // Tabla de manuales
    this.db.run(`
      CREATE TABLE IF NOT EXISTS manuales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        laboratorio_id INTEGER NOT NULL,
        items TEXT NOT NULL,
        created_by INTEGER,
        updated_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id),
        FOREIGN KEY (created_by) REFERENCES users(id),
        FOREIGN KEY (updated_by) REFERENCES users(id)
      )
    `);

    // ==========================================
    // TABLAS PARA SISTEMA DE AUXILIARES
    // ==========================================

    // Tabla de asignaciones de laboratorios a auxiliares
    this.db.run(`
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
    `);

    // Tabla de horarios de auxiliares
    this.db.run(`
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
    `);

    // ==========================================
    // TABLAS PARA SISTEMA DE DOCENTES Y RESERVAS
    // ==========================================

    // Tabla de docentes (info adicional)
    this.db.run(`
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
    `);

    // Tabla de reservas de laboratorios
    this.db.run(`
      CREATE TABLE IF NOT EXISTS reservas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        docente_id INTEGER NOT NULL,
        laboratorio_id INTEGER NOT NULL,
        fecha DATE NOT NULL,
        hora_inicio TIME NOT NULL,
        hora_fin TIME NOT NULL,
        materia TEXT NOT NULL,
        descripcion TEXT,
        estado TEXT DEFAULT 'pendiente',
        motivo_rechazo TEXT,
        aprobada_por INTEGER,
        aprobada_en DATETIME,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (docente_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios(id) ON DELETE CASCADE,
        FOREIGN KEY (aprobada_por) REFERENCES users(id)
      )
    `, (err) => {
      if (err) {
        console.error('Error creando tabla reservas:', err.message);
      } else {
        // Crear índices solo después de que la tabla existe
        this.db.run(`CREATE INDEX IF NOT EXISTS idx_reservas_docente ON reservas(docente_id)`);
        this.db.run(`CREATE INDEX IF NOT EXISTS idx_reservas_laboratorio ON reservas(laboratorio_id)`);
        this.db.run(`CREATE INDEX IF NOT EXISTS idx_reservas_fecha ON reservas(fecha)`);
        this.db.run(`CREATE INDEX IF NOT EXISTS idx_reservas_estado ON reservas(estado)`);
      }
    });

    // Crear índice para docentes
    this.db.run(`
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
    `, (err) => {
      if (err) {
        console.error('Error creando tabla docentes:', err.message);
      } else {
        this.db.run(`CREATE INDEX IF NOT EXISTS idx_docentes_codigo ON docentes(codigo)`);
      }
    });

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