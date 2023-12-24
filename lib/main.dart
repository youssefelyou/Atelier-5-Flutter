import 'package:atelier4/Authentication.dart';
import 'package:atelier4/firebase_options.dart';
import 'package:atelier4/liste_produits.dart';
import 'package:atelier4/login_ecran.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: AuthenticationPage(),
    );
  }
}

