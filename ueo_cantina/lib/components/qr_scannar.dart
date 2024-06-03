import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String scannedData = '';
  bool isScannerActive = true;
  bool isPopupActive = false; // Track popup state

  @override
  void initState() {
    super.initState();
    // Listen for keyboard events
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent && isScannerActive && !isPopupActive) {
      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          // Process the scanned data
          _processScannedData(scannedData);
          scannedData = ''; // Reset after processing
        } else {
          // Check if event.character is not null before adding
          if (event.character != null) {
            scannedData += event.character!;
          }
        }
      });
    }
  }

  void _processScannedData(String data) {
    if (data.isNotEmpty) {
      // Here, handle the scanned data. For example, check student meals.
      print('Scanned Data: $data');
      checkStudentMeals(data);
    }
  }

  Future<void> checkStudentMeals(String userId) async {
    try {
      // Fetch student's name and surname from Firestore
      DocumentSnapshot studentSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      String studentNume = studentSnapshot['nume'];
      String studentPrenume = studentSnapshot['prenume'];

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      int hour = now.hour;

      var lunch = false;
      var dinner = false;

      if (hour >= 8 && hour < 16 && hour < 30) {
        lunch = await hasMeal(userId, today, 'lunch');
        if (lunch) {
          await decrementMeal(userId, today, 'lunch');
        }
      } else if (hour >= 16 && hour < 21) {
        dinner = await hasMeal(userId, today, 'dinner');
        if (dinner) {
          await decrementMeal(userId, today, 'dinner');
        }
      }

      String message = 'Studentul/a $studentNume $studentPrenume ';

      if (lunch) {
        message += 'are prânz ';
      } else if (hour >= 8 && hour < 16 && hour < 15) {
        message += 'nu are prânz ';
      }

      if (dinner) {
        message += 'are cină ';
      } else if (hour >= 16 && hour < 21) {
        message += 'nu are cină ';
      }

      message += 'pe data de ${today.day}/${today.month}';

      Color backgroundColor = lunch || dinner ? Colors.green : Colors.red; // Set background color based on meals

      // Set popup state
      isPopupActive = true;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Informații despre mese"),
            content: Text(message),
            backgroundColor: backgroundColor, // Set background color
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Reset popup state after closing
                  isPopupActive = false;
                },
                child: Text("Închide"),
              ),
            ],
          );
        },
      );

      // Delayed close of popup and reset popup state
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            isPopupActive = false;
          });
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> decrementMeal(String userId, DateTime date, String mealType) async {
    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('selectedDays');

    var querySnapshot = await collection
        .where('date', isEqualTo: date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      var mealValue = doc[mealType] ?? 0;
      if (mealValue > 0) {
        await collection.doc(doc.id).update({mealType: mealValue - 1});
      }
    }
  }

  Future<bool> hasMeal(String userId, DateTime date, String mealType) async {
    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('selectedDays');

    var querySnapshot = await collection
        .where('date', isEqualTo: date)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return (doc[mealType] ?? 0) >= 1;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Scan QR code with your USB scanner'),
      ),
    );
  }
}