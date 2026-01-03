const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Database setup
const dbPath = path.join(__dirname, 'favorites.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database');
    // Create favorites table if it doesn't exist
    db.run(`CREATE TABLE IF NOT EXISTS favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT NOT NULL DEFAULT 'default_user',
      productId TEXT NOT NULL,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(userId, productId)
    )`, (err) => {
      if (err) {
        console.error('Error creating table:', err.message);
      } else {
        console.log('Favorites table ready');
      }
    });
  }
});

// Helper function to wrap database queries in promises
const dbRun = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function(err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
};

const dbGet = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

const dbAll = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

// Routes

// GET /favorites - Get all favorite product IDs for a user
app.get('/api/v1/favorites', async (req, res) => {
  try {
    const userId = req.query.userId || 'default_user';
    const favorites = await dbAll(
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
      await dbRun(
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
      if (err.message.includes('UNIQUE constraint')) {
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
    
    const result = await dbRun(
      'DELETE FROM favorites WHERE userId = ? AND productId = ?',
      [userId, productId]
    );
    
    if (result.changes === 0) {
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
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Favorites API is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Favorites API server running on http://localhost:${PORT}`);
  console.log(`📊 Database: ${dbPath}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error(err.message);
    }
    console.log('Database connection closed');
    process.exit(0);
  });
});

