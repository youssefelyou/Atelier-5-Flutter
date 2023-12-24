import 'package:atelier4/addProduit.dart';
import 'package:atelier4/login_ecran.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState== ConnectionState.waiting){
            return const CircularProgressIndicator();
          } else{
            if (snapshot.hasData){
              return const AddProduit();

            }else{
              return const login_ecran();
            }
          }
        },
      ),

    );
  }
}