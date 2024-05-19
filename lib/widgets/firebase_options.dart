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
      apiKey: "AIzaSyCmlExUHuuDafch9vGLGmsjXK2bmITJ4IU",
  authDomain: "task-management-96ba9.firebaseapp.com",
  databaseURL: "https://task-management-96ba9-default-rtdb.firebaseio.com",
  projectId: "task-management-96ba9",
  storageBucket: "task-management-96ba9.appspot.com",
  messagingSenderId: "745775452168",
  appId: "1:745775452168:web:d20e6b4122f480a39b01bd",
  measurementId: "G-HN4RQ1RZ8R"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCmlExUHuuDafch9vGLGmsjXK2bmITJ4IU",
  authDomain: "task-management-96ba9.firebaseapp.com",
  databaseURL: "https://task-management-96ba9-default-rtdb.firebaseio.com",
  projectId: "task-management-96ba9",
  storageBucket: "task-management-96ba9.appspot.com",
  messagingSenderId: "745775452168",
  appId: "1:745775452168:web:d20e6b4122f480a39b01bd",
  measurementId: "G-HN4RQ1RZ8R"
  );

  static const FirebaseOptions ios = FirebaseOptions(apiKey: "AIzaSyCmlExUHuuDafch9vGLGmsjXK2bmITJ4IU",
  authDomain: "task-management-96ba9.firebaseapp.com",
  databaseURL: "https://task-management-96ba9-default-rtdb.firebaseio.com",
  projectId: "task-management-96ba9",
  storageBucket: "task-management-96ba9.appspot.com",
  messagingSenderId: "745775452168",
  appId: "1:745775452168:web:d20e6b4122f480a39b01bd",
  measurementId: "G-HN4RQ1RZ8R"
  );

  static const FirebaseOptions macos = FirebaseOptions(
     apiKey: "AIzaSyCmlExUHuuDafch9vGLGmsjXK2bmITJ4IU",
  authDomain: "task-management-96ba9.firebaseapp.com",
  databaseURL: "https://task-management-96ba9-default-rtdb.firebaseio.com",
  projectId: "task-management-96ba9",
  storageBucket: "task-management-96ba9.appspot.com",
  messagingSenderId: "745775452168",
  appId: "1:745775452168:web:d20e6b4122f480a39b01bd",
  measurementId: "G-HN4RQ1RZ8R"
  );
}
