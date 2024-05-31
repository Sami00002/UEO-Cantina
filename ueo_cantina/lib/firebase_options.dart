// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDMidtRu751y2XyH8JhOHHyPUeVbccejf8',
    appId: '1:58836799394:web:d9ffb99ddc05f442dc6cfb',
    messagingSenderId: '58836799394',
    projectId: 'ueodatabase',
    authDomain: 'ueodatabase.firebaseapp.com',
    storageBucket: 'ueodatabase.appspot.com',
    measurementId: 'G-ELFNTG92S7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgsAA0ikjvZEmZfZRAmKdpwXRzJgXgbaM',
    appId: '1:58836799394:android:528474505cb98cbcdc6cfb',
    messagingSenderId: '58836799394',
    projectId: 'ueodatabase',
    storageBucket: 'ueodatabase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYRMFjgmHiOiSybVDVUlFJt7gN_1jGuZg',
    appId: '1:58836799394:ios:972547c53eb9be4adc6cfb',
    messagingSenderId: '58836799394',
    projectId: 'ueodatabase',
    storageBucket: 'ueodatabase.appspot.com',
    iosBundleId: 'com.example.ueoCantina',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYRMFjgmHiOiSybVDVUlFJt7gN_1jGuZg',
    appId: '1:58836799394:ios:464d8b6a7b1af5dedc6cfb',
    messagingSenderId: '58836799394',
    projectId: 'ueodatabase',
    storageBucket: 'ueodatabase.appspot.com',
    iosBundleId: 'com.example.ueoCantina.RunnerTests',
  );
}