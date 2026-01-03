# Quick Setup Guide

## Step 1: Install Node.js

If you don't have Node.js installed, download it from: https://nodejs.org/

Verify installation:
```bash
node --version
npm --version
```

## Step 2: Install Dependencies

Navigate to the backend folder and install:
```bash
cd backend
npm install
```

## Step 3: Start the Server

```bash
npm start
```

The server will start on `http://localhost:3000`

## Step 4: Update Flutter App API URL

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
1. Find your computer's IP address (e.g., `192.168.1.100`)
2. Update the URL:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

**For Web:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

## Step 5: Test the API

Open your browser and visit:
```
http://localhost:3000/health
```

You should see: `{"status":"ok","message":"Favorites API is running"}`

## Troubleshooting

### Port Already in Use
If port 3000 is busy, change it in `server.js`:
```javascript
const PORT = process.env.PORT || 3001; // Change to 3001 or any available port
```

### Database Issues
The database file `favorites.db` will be created automatically. If you need to reset it, just delete the file and restart the server.

### CORS Errors
Make sure CORS is enabled in `server.js` (it should be by default).

### Connection Refused
- Make sure the server is running
- Check firewall settings
- Verify the IP address/URL is correct for your platform

