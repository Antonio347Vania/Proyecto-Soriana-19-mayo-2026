import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, kIsWeb, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAReAiTm7nGUDlQfVNlFpy5fJPto1YpS3k',
    appId: '1:721230522050:web:aa1683eab256b6957ebd5b',
    messagingSenderId: '721230522050',
    projectId: 'dbsoriana',
    authDomain: 'dbsoriana.firebaseapp.com',
    storageBucket: 'dbsoriana.firebasestorage.app',
    measurementId: 'G-ZN8M818N1K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBN5Y0FQoBkTpBxGk4aSM9ZS85fmTR1_Nw',
    appId: '1:721230522050:android:cdf85886170d320c7ebd5b',
    messagingSenderId: '721230522050',
    projectId: 'dbsoriana',
    storageBucket: 'dbsoriana.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAReAiTm7nGUDlQfVNlFpy5fJPto1YpS3k',
    appId: '1:721230522050:ios:aa1683eab256b6957ebd5b',
    messagingSenderId: '721230522050',
    projectId: 'dbsoriana',
    storageBucket: 'dbsoriana.firebasestorage.app',
    iosBundleId: 'com.example.sorianaVania',
  );
}