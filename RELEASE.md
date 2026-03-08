# Android release guide

## 1. Generate a keystore
Run this once per project (replace `parkalert` passwords):

```bash
keytool -genkey -v -keystore parkalert.keystore -alias parkalert -keyalg RSA -keysize 2048 -validity 10000
```

## 2. Configure Gradle signing
1. Create `android/key.properties` (keep it out of version control):

   ```properties
   storePassword=yourStorePassword
   keyPassword=yourKeyPassword
   keyAlias=parkalert
   storeFile=parkalert.keystore
   ```

2. Keep `parkalert.keystore` in `android/` and verify `android/app/build.gradle.kts` is reading `key.properties` (already wired).

## 3. Build the release APK

```bash
flutter pub get
flutter build apk --release
```

Verify the generated APK under `build/app/outputs/flutter-apk/app-release.apk`.

## 4. Post-build checks
- Confirm Firebase Analytics events appear in the DebugView after exercising the flows.
- Open Firebase Crashlytics (Dashboard → Crashlytics) to ensure no unresolved issues.
- Roll out the APK to a test device and exercise the scan + alerts path.

## Pilot Build Checklist
- Firebase project assigned and `google-services.json` / `GoogleService-Info.plist` deployed.
- Phone authentication enabled in Firebase Console for India phone numbers.
- Firebase Cloud Messaging configured and `firebase_messaging` permission flows validated.
- Cloud Functions deployed (`firebase deploy --only functions`).
- Firestore security rules deployed (`firebase deploy --only firestore:rules`).
