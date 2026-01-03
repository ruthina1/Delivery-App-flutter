# Burger Knight Backend - Favorites API

A simple Node.js/Express backend server for managing user favorites in the Burger Knight delivery app.

## Features

- ✅ SQLite database for persistent storage
- ✅ RESTful API endpoints for favorites
- ✅ CORS enabled for Flutter app
- ✅ Error handling and validation

## Setup

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

The server will start on `http://localhost:3000`

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

## Database

The server uses SQLite with a `favorites.db` file that is automatically created in the backend directory.

**Schema:**
```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId TEXT NOT NULL DEFAULT 'default_user',
  productId TEXT NOT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(userId, productId)
)
```

## Configuration

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
# Get favorites
curl http://localhost:3000/api/v1/favorites

# Add favorite
curl -X POST http://localhost:3000/api/v1/favorites \
  -H "Content-Type: application/json" \
  -d '{"productId": "product_1"}'

# Remove favorite
curl -X DELETE http://localhost:3000/api/v1/favorites/product_1
```

## Production Deployment

For production:
1. Use a proper database (PostgreSQL, MySQL, MongoDB)
2. Add authentication middleware
3. Use environment variables for configuration
4. Enable HTTPS
5. Add rate limiting
6. Add logging and monitoring

