# Build Instructions for Burger Knight APK

## Prerequisites

Before building the APK, ensure you have the following installed:

1. **Flutter SDK** (3.10.3 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your system PATH

2. **Android Studio**
   - Download from: https://developer.android.com/studio
   - Install Android SDK (API level 21 or higher)
   - Set up Android SDK Command-line Tools

3. **Java Development Kit (JDK)**
   - JDK 11 or higher
   - Set JAVA_HOME environment variable

## Setup Steps

### 1. Verify Flutter Installation
```bash
flutter doctor
```
Ensure all required components show a checkmark (✓).

### 2. Install Android SDK
- Open Android Studio
- Go to Tools → SDK Manager
- Install Android SDK Platform-Tools
- Install Android SDK Build-Tools
- Set ANDROID_HOME environment variable:
  - Windows: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`
  - Add to PATH: `%ANDROID_HOME%\platform-tools` and `%ANDROID_HOME%\tools`

### 3. Accept Android Licenses
```bash
flutter doctor --android-licenses
```
Accept all licenses when prompted.

## Building the APK

### Step 1: Navigate to Project Directory
```bash
cd "flutter_application_1"
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Clean Previous Builds (Optional)
```bash
flutter clean
```

### Step 4: Build Release APK
```bash
flutter build apk --release
```

### Step 5: Locate the APK
The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Alternative Build Commands

### Build Split APKs (Smaller file sizes per architecture)
```bash
flutter build apk --release --split-per-abi
```
This creates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### Build App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### Issue: "No Android SDK found"
**Solution**: 
1. Install Android Studio
2. Set ANDROID_HOME environment variable
3. Restart terminal/command prompt

### Issue: "Android licenses not accepted"
**Solution**:
```bash
flutter doctor --android-licenses
```
Accept all licenses.

### Issue: "Gradle build failed"
**Solution**:
1. Check internet connection (Gradle downloads dependencies)
2. Clear Gradle cache: `cd android && ./gradlew clean`
3. Try building again

### Issue: "Out of memory"
**Solution**:
Increase Gradle memory in `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx4096m
```

## Verification

After building, verify the APK:
1. Check file size (should be reasonable, typically 20-50 MB)
2. Install on a test device:
   ```bash
   flutter install
   ```
3. Test all major features

## Notes

- The first build may take 5-10 minutes as it downloads dependencies
- Subsequent builds are faster (1-2 minutes)
- Ensure you have at least 2GB free disk space
- Build process requires internet connection for first-time setup

---

**For Support**: Refer to Flutter documentation at https://flutter.dev/docs

