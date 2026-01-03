# Burger Knight Backend - Favorites API

A simple Node.js/Express backend server for managing user favorites in the Burger Knight delivery app.

## Features

- ✅ MySQL database for persistent storage
- ✅ RESTful API endpoints for favorites
- ✅ CORS enabled for Flutter app
- ✅ Error handling and validation
- ✅ Connection pooling for better performance

## Prerequisites

- Node.js (v14 or higher)
- MySQL Server (v5.7 or higher, or MariaDB 10.2+)
- npm or yarn

## Setup

### 1. Install MySQL

If you don't have MySQL installed:
- **Windows**: Download from [MySQL Downloads](https://dev.mysql.com/downloads/mysql/)
- **macOS**: `brew install mysql` or download from MySQL website
- **Linux**: `sudo apt-get install mysql-server` (Ubuntu/Debian) or `sudo yum install mysql-server` (CentOS/RHEL)

### 2. Create Database

Login to MySQL and create the database:

```sql
CREATE DATABASE burger_knight;
```

Or the server will create it automatically on first run.

### 3. Configure Database Connection

Copy `.env.example` to `.env` and update with your MySQL credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=burger_knight
DB_PORT=3306
```

Or update `config.js` directly with your credentials.

### 4. Install Dependencies

```bash
cd backend
npm install
```

### 5. Start the Server

```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

The server will start on `http://localhost:3000` and automatically create the `favorites` table if it doesn't exist.

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Get Favorites
```
GET /favorites?userId=default_user
```
Returns an array of favorite product IDs.

**Response:**
```json
{
  "data": ["product_1", "product_2", "product_3"]
}
```

### Add Favorite
```
POST /favorites
Content-Type: application/json

{
  "productId": "product_1",
  "userId": "default_user" // optional, defaults to "default_user"
}
```

**Response:**
```json
{
  "data": {
    "userId": "default_user",
    "productId": "product_1",
    "message": "Favorite added successfully"
  }
}
```

### Remove Favorite
```
DELETE /favorites/:productId?userId=default_user
```

**Response:**
```json
{
  "data": {
    "userId": "default_user",
    "productId": "product_1",
    "message": "Favorite removed successfully"
  }
}
```

## Database Schema

The server automatically creates the `favorites` table with the following structure:

```sql
CREATE TABLE favorites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId VARCHAR(255) NOT NULL DEFAULT 'default_user',
  productId VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_product (userId, productId),
  INDEX idx_userId (userId),
  INDEX idx_productId (productId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
```

## Configuration

### Environment Variables

You can set these environment variables or update `config.js`:

- `DB_HOST` - MySQL host (default: localhost)
- `DB_USER` - MySQL username (default: root)
- `DB_PASSWORD` - MySQL password (default: empty)
- `DB_NAME` - Database name (default: burger_knight)
- `DB_PORT` - MySQL port (default: 3306)
- `PORT` - Server port (default: 3000)

### Flutter App Configuration

Update the API base URL in your Flutter app:

`lib/core/config/api_config.dart`
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

**Note:** For Android emulator, use `http://10.0.2.2:3000/api/v1`
**Note:** For iOS simulator, use `http://localhost:3000/api/v1`
**Note:** For physical device, use your computer's IP address: `http://192.168.x.x:3000/api/v1`

## Testing

You can test the API using curl or Postman:

```bash
# Health check
curl http://localhost:3000/health

# Get favorites
curl http://localhost:3000/api/v1/favorites

# Add favorite
curl -X POST http://localhost:3000/api/v1/favorites \
  -H "Content-Type: application/json" \
  -d '{"productId": "product_1"}'

# Remove favorite
curl -X DELETE http://localhost:3000/api/v1/favorites/product_1
```

## Troubleshooting

### MySQL Connection Error

1. Make sure MySQL is running:
   ```bash
   # Windows
   net start MySQL
   
   # macOS/Linux
   sudo systemctl start mysql
   # or
   brew services start mysql
   ```

2. Verify credentials in `.env` or `config.js`

3. Check MySQL user permissions:
   ```sql
   GRANT ALL PRIVILEGES ON burger_knight.* TO 'your_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

### Port Already in Use

Change the port in `.env`:
```env
PORT=3001
```

### Database Doesn't Exist

The server will create the database automatically, but you can create it manually:
```sql
CREATE DATABASE burger_knight CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Production Deployment

For production:
1. Use environment variables for all sensitive data
2. Add authentication middleware
3. Enable HTTPS
4. Add rate limiting
5. Add logging and monitoring
6. Use a managed MySQL service (AWS RDS, Google Cloud SQL, etc.)
7. Set up database backups
8. Configure connection pooling appropriately
