import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ueo_cantina/firebase_options.dart';
import 'common/strings.dart' as strings;
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const UEO_Cantina());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}


class UEO_Cantina extends StatelessWidget {
  const UEO_Cantina({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      home: LoginScreen(),
    );
  }
}