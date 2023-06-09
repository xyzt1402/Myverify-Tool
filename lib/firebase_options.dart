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
    apiKey: 'AIzaSyA88ziai5NymFT4BDbeQdQp0uqwvdR8_Wo',
    appId: '1:61657563349:web:b5bfff6fd44039930fa25c',
    messagingSenderId: '61657563349',
    projectId: 'myverifytool-project',
    authDomain: 'myverifytool-project.firebaseapp.com',
    storageBucket: 'myverifytool-project.appspot.com',
    measurementId: 'G-QDETKX6567',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjniTFBmdIquQTJgfY27C6W0zStmHKz9I',
    appId: '1:61657563349:android:62bcf83712d579af0fa25c',
    messagingSenderId: '61657563349',
    projectId: 'myverifytool-project',
    storageBucket: 'myverifytool-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpH4JDlSokk14an5liyqOspdqfyYmeoZw',
    appId: '1:61657563349:ios:38faf6af051b823b0fa25c',
    messagingSenderId: '61657563349',
    projectId: 'myverifytool-project',
    storageBucket: 'myverifytool-project.appspot.com',
    iosClientId: '61657563349-jdpji0ic3mkum4sejfcotjq3q9tjnb9d.apps.googleusercontent.com',
    iosBundleId: 'com.example.learningdart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDpH4JDlSokk14an5liyqOspdqfyYmeoZw',
    appId: '1:61657563349:ios:38faf6af051b823b0fa25c',
    messagingSenderId: '61657563349',
    projectId: 'myverifytool-project',
    storageBucket: 'myverifytool-project.appspot.com',
    iosClientId: '61657563349-jdpji0ic3mkum4sejfcotjq3q9tjnb9d.apps.googleusercontent.com',
    iosBundleId: 'com.example.learningdart',
  );
}
