# Quick Setup Guide - MySQL Version

## Step 1: Install Node.js

If you don't have Node.js installed, download it from: https://nodejs.org/

Verify installation:
```bash
node --version
npm --version
```

## Step 2: Install MySQL

If you don't have MySQL installed:

**Windows:**
- Download from: https://dev.mysql.com/downloads/mysql/
- Or use XAMPP/WAMP which includes MySQL

**macOS:**
```bash
brew install mysql
brew services start mysql
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

## Step 3: Configure MySQL

1. **Login to MySQL:**
```bash
mysql -u root -p
```

2. **Create Database (optional - server will create it automatically):**
```sql
CREATE DATABASE burger_knight CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

3. **Note your MySQL credentials:**
   - Username (usually `root`)
   - Password (the one you set during installation)
   - Port (usually `3306`)

## Step 4: Configure Backend

1. **Navigate to backend folder:**
```bash
cd backend
```

2. **Copy environment file:**
```bash
cp .env.example .env
```

3. **Edit `.env` file with your MySQL credentials:**
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=burger_knight
DB_PORT=3306
PORT=3000
```

**OR** edit `config.js` directly:
```javascript
module.exports = {
  database: {
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'burger_knight',
    port: 3306
  }
};
```

## Step 5: Install Dependencies

```bash
npm install
```

## Step 6: Start the Server

```bash
npm start
```

You should see:
```
✅ MySQL database initialized successfully
📊 Database: burger_knight
🚀 Favorites API server running on http://localhost:3000
🔌 MySQL Host: localhost:3306
```

## Step 7: Test the Server

Open your browser and visit:
```
http://localhost:3000/health
```

You should see:
```json
{
  "status": "ok",
  "message": "Favorites API is running",
  "database": "connected"
}
```

## Step 8: Update Flutter App API URL

Update `lib/core/config/api_config.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

**For Physical Device:**
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - macOS/Linux: `ifconfig` or `ip addr`
2. Update the URL:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api/v1'; // Replace with your IP
```

**For Web:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

## Troubleshooting

### MySQL Connection Refused

1. **Check if MySQL is running:**
   ```bash
   # Windows
   net start MySQL
   
   # macOS
   brew services list
   brew services start mysql
   
   # Linux
   sudo systemctl status mysql
   sudo systemctl start mysql
   ```

2. **Verify credentials** in `.env` or `config.js`

3. **Test MySQL connection manually:**
   ```bash
   mysql -u root -p -h localhost
   ```

### Access Denied Error

Grant permissions to your MySQL user:
```sql
GRANT ALL PRIVILEGES ON burger_knight.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### Port Already in Use

Change the port in `.env`:
```env
PORT=3001
```

### Database Connection Timeout

- Check firewall settings
- Verify MySQL is listening on the correct port (usually 3306)
- For remote connections, ensure MySQL allows remote access

### Table Creation Failed

The server will try to create the table automatically. If it fails, create it manually:

```sql
USE burger_knight;

CREATE TABLE IF NOT EXISTS favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
  productId VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Next Steps

1. ✅ Server is running
2. ✅ Database is connected
3. ✅ Flutter app API URL is configured
4. 🎉 Test favorites functionality in your app!
