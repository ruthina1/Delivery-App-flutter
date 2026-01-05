# Firebase Authentication Setup Guide

This guide will help you complete the Firebase Authentication setup for your Flutter app.

## Prerequisites

1. **Firebase CLI installed** ✅ (Already installed)
2. **Node.js installed** ✅ (v22.21.1)
3. **FlutterFire CLI installed** ✅ (Already installed)

## Step 1: Login to Firebase

Open your terminal and run:

```powershell
firebase login
```

This will open a browser window for you to authenticate with your Google account.

## Step 2: Generate Firebase Configuration

After logging in, navigate to your project directory and run:

```powershell
cd "C:\projects\flutter\flutter project\Delivery-App-flutter - Copy\flutter_application_1"
dart pub global run flutterfire_cli:flutterfire configure --project=burger-knight-d4d60
```

This command will:
- Connect to your Firebase project
- Generate `firebase_options.dart` with your actual Firebase credentials
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS

## Step 3: Install Dependencies

Run the following command to install the Firebase packages:

```powershell
flutter pub get
```

## Step 4: Verify Setup

1. Check that `firebase_options.dart` has been updated with real values (not placeholders)
2. Verify `android/app/google-services.json` exists
3. Verify `ios/Runner/GoogleService-Info.plist` exists (if building for iOS)

## Step 5: Test Firebase Connection

Run your app:

```powershell
flutter run
```

Check the console for:
- ✅ `Firebase initialized successfully` - means Firebase is working
- 🔴 `Firebase initialization error` - means there's an issue

## Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `burger-knight-d4d60`
3. Enable Authentication:
   - Go to **Authentication** → **Get Started**
   - Enable **Email/Password** sign-in method
   - Optionally enable **Google** sign-in, **Phone**, etc.

## Android Configuration

The Android setup is already configured:
- ✅ Google Services plugin added to `build.gradle.kts`
- ✅ Firebase dependencies added to `pubspec.yaml`

After running `flutterfire configure`, the `google-services.json` file will be automatically placed in `android/app/`.

## iOS Configuration (if needed)

If building for iOS:
1. After running `flutterfire configure`, `GoogleService-Info.plist` will be added to `ios/Runner/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. The Firebase configuration should be automatically linked

## Troubleshooting

### Firebase CLI not found
If you get "firebase command not found", add npm's global bin to your PATH:
- Add `C:\Users\WelCome\nvm\v22.21.1` to your system PATH

### Firebase initialization fails
- Make sure `firebase_options.dart` has real values (not placeholders)
- Verify `google-services.json` exists in `android/app/`
- Check that your Firebase project has Authentication enabled

### Build errors
- Run `flutter clean` then `flutter pub get`
- For Android: Make sure `minSdk` is at least 21 (Firebase requirement)

## Next Steps

After Firebase is configured, you can:
1. Update `AuthService` to use Firebase Authentication
2. Implement email/password authentication
3. Add social authentication (Google, Facebook, etc.)
4. Set up user profile management with Firestore

## Current Status

✅ Firebase dependencies added
✅ Android build configuration updated
✅ Firebase initialization code added to main.dart
⏳ Waiting for `flutterfire configure` to generate actual credentials

