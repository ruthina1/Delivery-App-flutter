# Burger Knight - Flutter Delivery App

A Flutter-based mobile application for burger delivery services.

## App Overview

Burger Knight is a comprehensive food delivery application that allows users to:
- Browse burger menu with categories
- Add items to shopping cart
- Place and track orders
- Manage user profile and preferences

## Features

- 🍔 **Menu Browsing**: Browse burgers, sides, drinks, and desserts
- 🛒 **Shopping Cart**: Add, remove, and manage cart items
- 📦 **Order Management**: Place orders and track delivery status
- 👤 **User Profile**: Manage account, addresses, and preferences
- 🔍 **Search**: Find products quickly
- 🎨 **Modern UI**: Clean and intuitive Material Design interface

## Getting Started

### Prerequisites
- Flutter SDK 3.10.3 or higher
- Android Studio / Android SDK
- Dart SDK (included with Flutter)

### Installation

1. Clone or download the project
2. Navigate to project directory:
   ```bash
   cd flutter_application_1
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Building APK

For release APK:
```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

See `../BUILD_INSTRUCTIONS.md` for detailed build setup.

## Project Structure

```
lib/
├── core/           # Core functionality (theme, constants)
├── data/           # Data models and mock data
├── features/       # Feature modules (screens, widgets)
├── presentation/   # UI components
└── main.dart      # App entry point
```

## Documentation

- **Usage Guide**: See `../USAGE_GUIDELINE.md`
- **Technical Docs**: See `../DOCUMENTATION.md`
- **Build Instructions**: See `../BUILD_INSTRUCTIONS.md`

## Technologies Used

- Flutter 3.10.3
- Dart
- Material Design 3
- Google Fonts (Poppins)

## Version

Current Version: 1.0.0+1

---

For more information, refer to the documentation files in the parent directory.
