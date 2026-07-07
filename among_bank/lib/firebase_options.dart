import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0L0PxaSflWXmR9y04ZmLWVvIujqSXW_s',
    appId: '1:978016019039:web:e73105571141b0893af1ea',
    messagingSenderId: '978016019039',
    projectId: 'among-bank',
    authDomain: 'among-bank.firebaseapp.com',
    storageBucket: 'among-bank.firebasestorage.app',
    measurementId: 'G-YF33B943YL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6todpMVx3-5HgXKOsYddUQyAsMKJbL-g',
    appId: '1:978016019039:android:67833ac193d488d03af1ea',
    messagingSenderId: '978016019039',
    projectId: 'among-bank',
    storageBucket: 'among-bank.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0L0PxaSflWXmR9y04ZmLWVvIujqSXW_s',
    appId: '1:978016019039:web:e73105571141b0893af1ea',
    messagingSenderId: '978016019039',
    projectId: 'among-bank',
    storageBucket: 'among-bank.firebasestorage.app',
  );
}
