# Firebase Console Setup Guide for Notifications

This guide will help you configure Firebase Console for the notification system.

## 1. Firestore Database - Rules

### Step 1: Update Firestore Rules
1. Go to Firebase Console → Firestore Database → Rules
2. The rules file (`firestore.rules`) has been updated with notification rules
3. Deploy the rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
   Or manually copy the rules from `firestore.rules` to the Firebase Console

### Step 2: Verify Rules
Make sure these collections are accessible:
- ✅ `notifications` - for storing notifications
- ✅ `places/{placeId}/reviews` - for storing reviews
- ✅ `users` - for storing FCM tokens

## 2. Firebase Cloud Messaging (FCM) Setup

### For Android:

1. **Enable FCM in Firebase Console:**
   - Go to Firebase Console → Project Settings → Cloud Messaging
   - Make sure "Cloud Messaging API (Legacy)" is enabled
   - Note: You'll need the Server Key later (see step 3)

2. **Verify google-services.json:**
   - Your `android/app/google-services.json` should already be configured
   - If not, download it from Firebase Console → Project Settings → Your apps → Android app

3. **Android Manifest (Already configured):**
   - The app should already have necessary permissions
   - If not, ensure these are in `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
     ```

### For iOS:

1. **Enable Push Notifications:**
   - Go to Firebase Console → Project Settings → Cloud Messaging
   - Upload your APNs Authentication Key or Certificate
   - Download `GoogleService-Info.plist` and add it to your iOS project

2. **Xcode Configuration:**
   - Enable Push Notifications capability in Xcode
   - Add Background Modes → Remote notifications

### For Web:

1. **Enable FCM for Web:**
   - Go to Firebase Console → Project Settings → Cloud Messaging
   - Web Push certificates (optional, for web push notifications)

## 3. Get FCM Server Key (For Push Notifications)

**Important:** This is needed if you want to send actual push notifications from a backend server.

1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Under "Cloud Messaging API (Legacy)", find the "Server key"
3. Copy this key (keep it secret!)
4. You'll use this in your backend server or Cloud Functions

**Note:** The current implementation creates notifications in Firestore. To send actual push notifications, you'll need to:
- Set up Firebase Cloud Functions, OR
- Use a backend server with the FCM Server Key

## 4. Firestore Indexes (If Needed)

If you see index errors, create these composite indexes in Firestore:

1. Go to Firebase Console → Firestore Database → Indexes
2. Create these indexes if they don't exist:

   **For notifications:**
   - Collection: `notifications`
   - Fields: `type` (Ascending), `isRead` (Ascending), `createdAt` (Descending)

   **For user notifications:**
   - Collection: `notifications`
   - Fields: `userId` (Ascending), `type` (Ascending), `createdAt` (Descending)

## 5. Test the Setup

### Test Firestore Rules:
1. Try creating a notification from the app
2. Check Firestore Console → Data → `notifications` collection
3. You should see new notification documents

### Test FCM Token:
1. Login to the app
2. Check Firestore Console → Data → `users` collection
3. Your user document should have an `fcmToken` field

## 6. Optional: Set Up Cloud Functions for Push Notifications

If you want actual push notifications (not just in-app), you'll need Cloud Functions:

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Initialize Functions:
   ```bash
   firebase init functions
   ```

3. Create a function to send notifications when reviews are created
4. Deploy:
   ```bash
   firebase deploy --only functions
   ```

## 7. Security Checklist

- ✅ Firestore rules are properly configured
- ✅ FCM Server Key is kept secret (not in app code)
- ✅ User FCM tokens are stored securely
- ✅ Only admins can see review notifications
- ✅ Users can only see their own response notifications

## Troubleshooting

### Notifications not appearing?
- Check Firestore rules are deployed
- Verify user has proper authentication
- Check browser/app console for errors

### FCM token not saving?
- Check internet connection
- Verify Firebase project is properly configured
- Check app permissions (especially for notifications)

### Push notifications not working?
- Verify FCM is enabled in Firebase Console
- Check device has internet connection
- For Android: Check google-services.json is correct
- For iOS: Verify APNs is configured

## Next Steps

1. ✅ Firestore rules updated
2. ✅ FCM enabled in Firebase Console
3. ⏳ (Optional) Set up Cloud Functions for push notifications
4. ⏳ (Optional) Configure APNs for iOS push notifications
5. ⏳ Test the notification flow end-to-end

