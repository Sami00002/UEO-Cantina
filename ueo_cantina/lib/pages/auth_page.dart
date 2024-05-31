import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ueo_cantina/screens/home_page1.dart';
import 'package:ueo_cantina/screens/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //user is logged in
          if(snapshot.hasData){
            return HomePage1();
          }
          else{
          // If the user is not logged in, navigate to the LoginPage.
            return LoginScreen();
          }
        } ,
        ),

    );
  }
}