require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');
const config = require('./config');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Create MySQL connection pool
const pool = mysql.createPool(config.database);

// Initialize database - create table if it doesn't exist
async function initializeDatabase() {
  try {
    const connection = await pool.getConnection();
    
    // Create database if it doesn't exist
    await connection.query(`CREATE DATABASE IF NOT EXISTS ${config.database.database}`);
    await connection.query(`USE ${config.database.database}`);
    
    // Check if favorites table exists and has foreign key constraint
    const [tables] = await connection.query(`
      SELECT TABLE_NAME 
      FROM information_schema.TABLES 
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'favorites'
    `, [config.database.database]);
    
    if (tables.length > 0) {
      // Table exists, check for foreign key constraints
      const [constraints] = await connection.query(`
        SELECT CONSTRAINT_NAME 
        FROM information_schema.KEY_COLUMN_USAGE 
        WHERE TABLE_SCHEMA = ? 
        AND TABLE_NAME = 'favorites' 
        AND REFERENCED_TABLE_NAME IS NOT NULL
      `, [config.database.database]);
      
      // Remove foreign key constraints if they exist
      for (const constraint of constraints) {
        try {
          await connection.query(`ALTER TABLE favorites DROP FOREIGN KEY ${constraint.CONSTRAINT_NAME}`);
          console.log(`✅ Removed foreign key constraint: ${constraint.CONSTRAINT_NAME}`);
        } catch (err) {
          // Constraint might not exist, ignore
        }
      }
    }
    
    // Create or recreate favorites table without foreign key constraint
    await connection.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
        productId VARCHAR(255) NOT NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_user_product (userId, productId),
        INDEX idx_userId (userId),
        INDEX idx_productId (productId)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    
    connection.release();
    console.log('✅ MySQL database initialized successfully');
    console.log(`📊 Database: ${config.database.database}`);
  } catch (error) {
    console.error('❌ Error initializing database:', error.message);
    process.exit(1);
  }
}

// Initialize database on startup
initializeDatabase();

// Helper functions for database queries
const dbQuery = async (sql, params = []) => {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    throw error;
  }
};

// Routes

// GET /favorites - Get all favorite product IDs for a user
app.get('/api/v1/favorites', async (req, res) => {
  try {
    const userId = req.query.userId || 'default_user';
    const favorites = await dbQuery(
      'SELECT productId FROM favorites WHERE userId = ?',
      [userId]
    );
    
    const productIds = favorites.map(f => f.productId);
    
    res.json({
      data: productIds
    });
  } catch (error) {
    console.error('Error fetching favorites:', error);
    res.status(500).json({
      message: 'Failed to fetch favorites',
      error: error.message
    });
  }
});

// POST /favorites - Add a product to favorites
app.post('/api/v1/favorites', async (req, res) => {
  try {
    const { productId } = req.body;
    const userId = req.query.userId || req.body.userId || 'default_user';
    
    if (!productId) {
      return res.status(400).json({
        message: 'productId is required'
      });
    }
    
    try {
      await dbQuery(
        'INSERT INTO favorites (userId, productId) VALUES (?, ?)',
        [userId, productId]
      );
      
      res.json({
        data: {
          userId,
          productId,
          message: 'Favorite added successfully'
        }
      });
    } catch (err) {
      // MySQL error code 1062 is duplicate entry
      if (err.code === 'ER_DUP_ENTRY' || err.errno === 1062) {
        // Already favorited, return success
        res.json({
          data: {
            userId,
            productId,
            message: 'Already in favorites'
          }
        });
      } else {
        throw err;
      }
    }
  } catch (error) {
    console.error('Error adding favorite:', error);
    res.status(500).json({
      message: 'Failed to add favorite',
      error: error.message
    });
  }
});

// DELETE /favorites/:productId - Remove a product from favorites
app.delete('/api/v1/favorites/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.query.userId || 'default_user';
    
    const result = await dbQuery(
      'DELETE FROM favorites WHERE userId = ? AND productId = ?',
      [userId, productId]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        message: 'Favorite not found'
      });
    }
    
    res.json({
      data: {
        userId,
        productId,
        message: 'Favorite removed successfully'
      }
    });
  } catch (error) {
    console.error('Error removing favorite:', error);
    res.status(500).json({
      message: 'Failed to remove favorite',
      error: error.message
    });
  }
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await dbQuery('SELECT 1');
    res.json({ 
      status: 'ok', 
      message: 'Favorites API is running',
      database: 'connected'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Database connection failed',
      error: error.message
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Favorites API server running on http://localhost:${PORT}`);
  console.log(`🔌 MySQL Host: ${config.database.host}:${config.database.port}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down server...');
  await pool.end();
  console.log('✅ Database connections closed');
  process.exit(0);
});
