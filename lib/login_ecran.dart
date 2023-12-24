import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class login_ecran extends StatelessWidget {
  const login_ecran({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen();
        }
        if (snapshot.hasData) {
          return Container(
            color: Colors.white, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  'Email: ${snapshot.data!.email}',
                  textAlign: TextAlign.center, 
                   style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black, 
                    decoration: TextDecoration.none,
                    fontFamily: 'Times New Roman',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Text('Se déconnecter'),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
