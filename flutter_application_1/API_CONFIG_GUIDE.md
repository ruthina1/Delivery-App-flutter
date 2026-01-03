# API Configuration Guide

## Quick Fix for Network Error

If you're getting network errors, update the API URL in `lib/core/config/api_config.dart` based on your platform:

### For Android Emulator:
```dart
defaultValue: 'http://10.0.2.2:3000/api/v1',
```

### For iOS Simulator:
```dart
defaultValue: 'http://localhost:3000/api/v1',
```

### For Web:
```dart
defaultValue: 'http://localhost:3000/api/v1',
```

### For Physical Device:
1. Find your computer's IP address:
   - Windows: Run `ipconfig` and look for IPv4 Address
   - macOS/Linux: Run `ifconfig` or `ip addr`
2. Update the URL:
```dart
defaultValue: 'http://192.168.1.100:3000/api/v1', // Replace with your IP
```

## Using Command Line (Alternative)

You can also set the URL when running the app:

```bash
# Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1

# iOS Simulator
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1

# Web
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## Verify Backend is Running

Before running the Flutter app, make sure your backend server is running:

```bash
cd backend
npm start
```

You should see:
```
🚀 Favorites API server running on http://localhost:3000
```

Test it in your browser:
```
http://localhost:3000/health
```

## Troubleshooting

### Still Getting Network Errors?

1. **Check backend is running** - Visit `http://localhost:3000/health` in browser
2. **Check firewall** - Make sure port 3000 is not blocked
3. **Check URL** - Verify the URL matches your platform (see above)
4. **Check MySQL** - Make sure MySQL is running and database exists
5. **Hot Restart** - After changing the API URL, do a hot restart (not just hot reload)

### Android Emulator Specific

If using Android emulator, you **MUST** use `10.0.2.2` instead of `localhost`:
```dart
defaultValue: 'http://10.0.2.2:3000/api/v1',
```

### Physical Device Specific

- Make sure your phone and computer are on the same WiFi network
- Use your computer's local IP address (not `localhost`)
- Make sure your firewall allows connections on port 3000

