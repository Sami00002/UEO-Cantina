import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ueo_cantina/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:ueo_cantina/screens/login_page.dart';
import 'common/strings.dart' as strings;
import 'components/ThemeNotifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(),
        child: const UEO_Cantina(),
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class UEO_Cantina extends StatelessWidget {
  const UEO_Cantina({Key? key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: LoginScreen(),
    );
  }
}