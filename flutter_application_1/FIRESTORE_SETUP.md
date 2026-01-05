# Firestore Security Rules Setup

## Problem
You're getting `permission-denied` errors when trying to write to Firestore. This is because Firestore security rules need to be configured.

## Solution

### Option 1: Deploy Rules via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `burger-knight-d4d60`
3. Click on **Firestore Database** in the left menu
4. Go to the **Rules** tab
5. Replace the default rules with the content from `firestore.rules` file
6. Click **Publish**

### Option 2: Deploy Rules via Firebase CLI

If you have Firebase CLI installed and logged in:

```powershell
cd flutter_application_1
firebase deploy --only firestore:rules
```

### Option 3: Temporary Development Rules (NOT FOR PRODUCTION)

For testing only, you can temporarily use these permissive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ WARNING:** These rules allow any authenticated user to read/write all documents. Only use for development/testing!

## What the Rules Do

The provided `firestore.rules` file includes:

1. **Users Collection**: Users can only read/write their own user document
2. **Orders Collection**: Users can only access their own orders
3. **Products/Categories**: Public read access, authenticated write
4. **Cart/Favorites/Addresses**: Users can only access their own data

## After Setting Up Rules

1. The rules take effect immediately after publishing
2. Try signing up again - it should work now
3. Check Firebase Console → Firestore Database → Data tab to see your user document

## Troubleshooting

If you still get permission errors:
1. Make sure you're logged in to Firebase Console
2. Verify the rules were published successfully
3. Check that Email/Password authentication is enabled
4. Try signing out and signing in again

