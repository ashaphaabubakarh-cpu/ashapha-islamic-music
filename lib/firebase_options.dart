// Auto-filled from google-services.json for the Ashapha Islamic Music
// Firebase project. Android values are real; iOS is left as a placeholder
// since this project currently targets Android only.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for this project.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzPjWcudmzy7cR_5-t7aVaSboI1TIzpco',
    appId: '1:983491143829:android:77862e1a21a0eb30b2139c',
    messagingSenderId: '983491143829',
    projectId: 'ashapha-islamic-music-8425e',
    storageBucket: 'ashapha-islamic-music-8425e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.ashsphaislamicmusic',
  );
}
