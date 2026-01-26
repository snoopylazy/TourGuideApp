# Tour Guide App (Updated)

This project is a Flutter tour guide app scaffold with Firebase Auth, Firestore, and GetX for state management and navigation. It includes:

- Email/password auth (register, login, logout, reset password)
- Firestore user profiles (`users` collection)
- Admin CRUD for `places` (hard-coded admin credentials in app: `admin` / `123`)
- Image handling via URL (no Firebase Storage required)
- Map picker using `google_maps_flutter` for selecting coordinates
- Simple favorites collection for logged-in users

Requirements
- Flutter SDK (>= 3.10)
- Firebase project configured; `firebase_options.dart` already present in `lib/`

Run the app

```bash
flutter pub get
flutter run
```

Google Maps setup
- You must add an API key for Google Maps to Android, iOS and optionally web.

Android
- Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder `YOUR_GOOGLE_MAPS_API_KEY` with your API key (the file already contains a placeholder meta-data entry).

Web (optional)
- If you want maps on web, open `web/index.html` and replace `YOUR_GOOGLE_MAPS_API_KEY` in the script include.

iOS
- Follow the `google_maps_flutter` documentation. Typically add the API key to `AppDelegate` or `Info.plist` as described in the official guide.

Tip: keep API keys out of source control. For Android you can inject the key at build time (e.g. via `local.properties` or CI secrets) and reference it using manifest placeholders.

Firestore rules
- A sample `firestore.rules` is included. It requires a custom `admin` claim for write access to `places`.

Security note
- The in-app admin login (`admin`/`123`) is intentionally simple per request. For production, grant admin privileges via Firebase Authentication custom claims or a role in Firestore.

Next steps
- Wire app-level admin claims and remove hard-coded admin credentials.
- Improve UI polish and add tests.
- Integrate device location and permissions if you want "navigate to" functionality.
 
Session behavior
- This app can optionally clear any persisted Firebase auth session on startup (useful for web refresh or when you want to force a fresh login). Toggle the behavior in `lib/config/app_config.dart` by setting `signOutOnStart` to `true` or `false`.
# tourguideapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
