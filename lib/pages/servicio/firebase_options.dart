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
    apiKey: 'AIzaSyAvNKFrovz5P_GqDV0R3wl8lKSZTxi5e44',
    appId: '1:525520989408:web:7860ba7b954c6b01f17485',
    messagingSenderId: '525520989408',
    projectId: 'hormibloque-99c7b',
    authDomain: 'hormibloque-99c7b.firebaseapp.com',
    storageBucket: 'hormibloque-99c7b.appspot.com',
    measurementId: 'G-1X9TVJDJXF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDa4n7BTxEXY_kJs_AMiS6Efb-SDCWOUV0',
    appId: '1:525520989408:android:34adee3ff9486165f17485',
    messagingSenderId: '525520989408',
    projectId: 'hormibloque-99c7b',
    storageBucket: 'hormibloque-99c7b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7Bt5COA5s_iIFKvgF6d4sI5Jg5AoitRg',
    appId: '1:525520989408:ios:e4007409b98aac4af17485',
    messagingSenderId: '525520989408',
    projectId: 'hormibloque-99c7b',
    storageBucket: 'hormibloque-99c7b.appspot.com',
    iosBundleId: 'com.example.hormi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7Bt5COA5s_iIFKvgF6d4sI5Jg5AoitRg',
    appId: '1:525520989408:ios:c401f9b596f09014f17485',
    messagingSenderId: '525520989408',
    projectId: 'hormibloque-99c7b',
    storageBucket: 'hormibloque-99c7b.appspot.com',
    iosBundleId: 'com.example.hormi.RunnerTests',
  );
}
