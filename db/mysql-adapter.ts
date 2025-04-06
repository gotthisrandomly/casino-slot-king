import mysql from 'mysql2/promise';
import { v4 as uuidv4 } from 'uuid';

// Database connection pool
let pool: mysql.Pool | null = null;

// Initialize the database connection
export async function initDatabaseConnection() {
  const config = getDatabaseConfig();
  
  if (!config.mysqlHost || !config.mysqlUser || !config.mysqlDatabase) {
    throw new Error('MySQL configuration is incomplete');
  }

  pool = mysql.createPool({
    host: config.mysqlHost,
    port: config.mysqlPort || 3306,
    user: config.mysqlUser,
    password: config.mysqlPassword || '',
    database: config.mysqlDatabase,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  });

  // Verify connection
  try {
    const conn = await pool.getConnection();
    console.log('MySQL database connected successfully');
    conn.release();
    return true;
  } catch (error) {
    console.error('Failed to connect to MySQL database:', error);
    throw error;
  }
}

// Get a connection from the pool
export async function getConnection() {
  if (!pool) {
    await initDatabaseConnection();
  }
  return pool!.getConnection();
}

// Execute a query
export async function query<T>(sql: string, params?: any[]): Promise<T> {
  const conn = await getConnection();
  try {
    const [rows] = await conn.query(sql, params);
    return rows as T;
  } finally {
    conn.release();
  }
}

// Create database tables from migration files
export async function runMigrations() {
  const conn = await getConnection();
  
  try {
    // Read migration file content
    const fs = require('fs');
    const path = require('path');
    const migrationPath = path.join(__dirname, 'migrations', '01_create_tables.sql');
    const migrationSql = fs.readFileSync(migrationPath, 'utf8');
    
    // Split SQL by semicolons to execute each statement separately
    const statements = migrationSql
      .split(';')
      .filter(statement => statement.trim().length > 0);
    
    for (const statement of statements) {
      await conn.query(statement);
    }
    
    console.log('Database migrations completed successfully');
  } catch (error) {
    console.error('Error running migrations:', error);
    throw error;
  } finally {
    conn.release();
  }
}

// Helper function to get database configuration
function getDatabaseConfig() {
  // Import database config from frontend
  try {
    // In a real environment, this would be properly imported
    return {
      mysqlHost: process.env.MYSQL_HOST,
      mysqlPort: process.env.MYSQL_PORT ? Number(process.env.MYSQL_PORT) : 3306,
      mysqlUser: process.env.MYSQL_USER,
      mysqlPassword: process.env.MYSQL_PASSWORD,
      mysqlDatabase: process.env.MYSQL_DATABASE
    };
  } catch (error) {
    console.error('Error loading database config:', error);
    return {
      mysqlHost: process.env.MYSQL_HOST,
      mysqlPort: process.env.MYSQL_PORT ? Number(process.env.MYSQL_PORT) : 3306,
      mysqlUser: process.env.MYSQL_USER,
      mysqlPassword: process.env.MYSQL_PASSWORD,
      mysqlDatabase: process.env.MYSQL_DATABASE
    };
  }
}
