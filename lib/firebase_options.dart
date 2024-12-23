// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBZdN7AuMkwZFSFwKWLy6QzVCx8vGMuK68',
    appId: '1:511504403783:web:b68aceed008d0627195062',
    messagingSenderId: '511504403783',
    projectId: 'fitformula-27ac5',
    authDomain: 'fitformula-27ac5.firebaseapp.com',
    storageBucket: 'fitformula-27ac5.firebasestorage.app',
    measurementId: 'G-LWXSJJKPQ9',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjfWRKk33I56eePtE8avZVdf1S18Na0vA',
    appId: '1:511504403783:ios:f39956c2ec767af3195062',
    messagingSenderId: '511504403783',
    projectId: 'fitformula-27ac5',
    storageBucket: 'fitformula-27ac5.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjfWRKk33I56eePtE8avZVdf1S18Na0vA',
    appId: '1:511504403783:ios:f39956c2ec767af3195062',
    messagingSenderId: '511504403783',
    projectId: 'fitformula-27ac5',
    storageBucket: 'fitformula-27ac5.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBZdN7AuMkwZFSFwKWLy6QzVCx8vGMuK68',
    appId: '1:511504403783:web:5c04b0a293f43d65195062',
    messagingSenderId: '511504403783',
    projectId: 'fitformula-27ac5',
    authDomain: 'fitformula-27ac5.firebaseapp.com',
    storageBucket: 'fitformula-27ac5.firebasestorage.app',
    measurementId: 'G-9KX660KKMG',
  );

}

