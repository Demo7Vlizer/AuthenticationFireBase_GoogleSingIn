// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCVTDMr-bDCDv2BgDKVgzNfL5D3VqKEruk',
    appId: '1:658575231015:web:d48d1e1953d0f7d7532602',
    messagingSenderId: '658575231015',
    projectId: 'myapp-d299c',
    authDomain: 'myapp-d299c.firebaseapp.com',
    storageBucket: 'myapp-d299c.firebasestorage.app',
    measurementId: 'G-NHYF4ZYVE6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBID2zC2J-W171WdkQIS8SirNdShy-cQlM',
    appId: '1:658575231015:android:dc229e8c9e95ae6d532602',
    messagingSenderId: '658575231015',
    projectId: 'myapp-d299c',
    storageBucket: 'myapp-d299c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDylU7jO3oodoU2bbmwZ3So7TBQT51jvCw',
    appId: '1:658575231015:ios:93fbfa061369fdfb532602',
    messagingSenderId: '658575231015',
    projectId: 'myapp-d299c',
    storageBucket: 'myapp-d299c.firebasestorage.app',
    iosBundleId: 'com.example.my',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDylU7jO3oodoU2bbmwZ3So7TBQT51jvCw',
    appId: '1:658575231015:ios:93fbfa061369fdfb532602',
    messagingSenderId: '658575231015',
    projectId: 'myapp-d299c',
    storageBucket: 'myapp-d299c.firebasestorage.app',
    iosBundleId: 'com.example.my',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVTDMr-bDCDv2BgDKVgzNfL5D3VqKEruk',
    appId: '1:658575231015:web:8612be274eea0ee9532602',
    messagingSenderId: '658575231015',
    projectId: 'myapp-d299c',
    authDomain: 'myapp-d299c.firebaseapp.com',
    storageBucket: 'myapp-d299c.firebasestorage.app',
    measurementId: 'G-6BF5GMNQYR',
  );
}
