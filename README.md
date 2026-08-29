# Ashapa Music — Flutter Source Code

Cikakken source code na app ɗin **Ashapa Music** (Islamic Nasheed streaming app), an rubuta shi da **Flutter**, tare da **Firebase** a matsayin backend.

## Fasalolin da aka Ƙunsa (Features)

| Feature | Halin da yake ciki |
|---|---|
| ✅ Music Player | An gama — `just_audio`, play/pause/seek |
| ✅ Firebase | An gama — Auth, Firestore, Storage, Messaging |
| ✅ Login/Register | An gama — Firebase Auth (email/password) |
| ✅ Download (offline) | An gama — ana zazzage waƙoƙin **naka na Firebase Storage**, ba na YouTube ba |
| ✅ Search | An gama — bincike ta suna/mawaƙi |
| ✅ Favorites | An gama — kowane user na iya ajiye waƙoƙi |
| ✅ Notification | An gama — Firebase Cloud Messaging |
| ✅ Admin Panel | An gama — ƙara/goge waƙa, kariya ta `isAdmin` flag |
| ⚠️ APK/AAB | **Sai KA gina su** a kwamfutarka — duba Sashe na 4 |

> ⚠️ **Muhimmin bayani**: An gina wannan app ne don kunna/adana waƙoƙin da *kai kanka ka ɗora* zuwa Firebase Storage (ta Admin Panel). Ba a gina wani feature na "download daga YouTube" ba, domin hakan ya saɓa wa ka'idojin YouTube (Terms of Service) da haƙƙin mallaka.

---

## 1. Kayan da ake Bukata a Kwamfutarka

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable)
- [Android Studio](https://developer.android.com/studio) (don Android SDK + emulator)
- Node.js (don Firebase CLI)
- Account na Google (don Firebase)

Bincika cewa Flutter ya yi aiki daidai:
```bash
flutter doctor
```

---

## 2. Kafa Firebase Project

1. Je zuwa [Firebase Console](https://console.firebase.google.com) → **Add project** → sanya suna (misali `ashapa-music`).
2. A ciki project ɗin, kunna waɗannan services:
   - **Authentication** → Sign-in method → kunna **Email/Password**
   - **Firestore Database** → Create database (start in production mode)
   - **Storage** → Get started
   - **Cloud Messaging** → babu wani abu na musamman da za a yi anan, zai kunna ta atomatik
3. A cikin kwamfutarka, buɗe folder na wannan project (`ashapa_music`), sannan gudanar:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Wannan zai tambaye ka wane Firebase project za a haɗa, sannan ya sabunta `lib/firebase_options.dart` da kansa (maye gurbin placeholder da ke ciki yanzu).
4. Sanya security rules:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```
   (Ana amfani da fayilolin `firestore.rules` da `storage.rules` da ke cikin wannan folder.)

---

## 3. Sanya Admin Account

1. Yi rejista a cikin app ɗin (ko Firebase Console → Authentication → Add user) da email/password na admin.
2. Je Firestore Database → `users` collection → nemo document ɗin wannan user (uid ɗinsa).
3. Ƙara field: `isAdmin` (boolean) = `true`.
4. Yanzu wannan account zai iya shiga **Admin Panel** a cikin app (Profile tab → Admin Panel), ya ƙara/goge waƙoƙi.

---

## 4. Gina APK / AAB (Play Store)

Bayan ka gama saitin Firebase (Sashe 2):

```bash
cd ashapa_music
flutter pub get

# Don gwaji akan phone/emulator:
flutter run

# APK don rabawa kai tsaye (misali WhatsApp, direct install):
flutter build apk --release
# Sakamako: build/app/outputs/flutter-apk/app-release.apk

# AAB don Google Play Store:
flutter build appbundle --release
# Sakamako: build/app/outputs/bundle/release/app-release.aab
```

### Kafin ka gina release na gaske:
- Canza `applicationId` a `android/app/build.gradle` daga default zuwa naka (misali `com.ashapa.music`).
- Ƙirƙiri **signing key** (`keytool -genkey ...`) sannan ka saka bayanansa a `android/key.properties` — Flutter's [official signing guide](https://docs.flutter.dev/deployment/android) ya bayyana matakan daki-daki.
- Sauya icon na app (`assets/images/`) da launcher icon ta amfani da package kamar `flutter_launcher_icons`.

---

## 5. Tsarin Fayiloli (Project Structure)

```
lib/
  main.dart                    # Entry point
  firebase_options.dart        # Za a maye gurbinsa ta flutterfire configure
  models/song.dart
  services/
    auth_service.dart          # Login/Register/isAdmin check
    firestore_service.dart     # Songs, search, favorites
    audio_player_service.dart  # Playback + offline download
    notification_service.dart  # Firebase Cloud Messaging
  screens/
    splash_screen.dart
    login_screen.dart / register_screen.dart
    home_screen.dart / search_screen.dart / favorites_screen.dart
    player_screen.dart
    profile_screen.dart
    admin/
      admin_login_screen.dart      # Yana bincika isAdmin flag
      admin_dashboard_screen.dart  # Jerin waƙoƙi + delete
      add_song_screen.dart         # Upload sabon waƙa zuwa Firebase
  widgets/
    song_tile.dart / mini_player.dart
  theme/app_theme.dart           # Launin zinare/baƙi na Ashapa Music
firestore.rules
storage.rules
```

---

## 6. Aika Sanarwa (Notifications) don Sabon Waƙa

Domin aika "Sabon waƙa ya fito!" ga duk users, a Firebase Console:
1. Je **Cloud Messaging** → **New notification**
2. Rubuta title/body
3. A ƙarƙashin "Target", zaɓi **Topic** → `new_songs`
4. Aika — duk wanda app ɗinsa ya kasance a buɗe (ko a background) zai karɓi sanarwar.

---

## 7. Abin da Zai Biyo Baya (Optional Improvements)

- Ƙara Algolia ko Firestore full-text search extension don ingantaccen bincike.
- Ƙara payment (misali Paystack/Flutterwave) idan akwai shirin biyan kuɗi na premium content.
- Ƙara iOS build steps (App Store) idan ana buƙata — wannan README ya fi mayar da hankali kan Android/Play Store kamar yadda aka bayyana.
