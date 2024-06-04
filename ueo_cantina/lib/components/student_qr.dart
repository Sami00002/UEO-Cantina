import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentQRCode extends StatelessWidget {
  const StudentQRCode({super.key});

  Future<Map<String, bool>> checkTodayLunchDinner() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'lunch': false, 'dinner': false};
    }

    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    DateTime endOfToday = startOfToday.add(const Duration(days: 1));

    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('selectedDays');
    var querySnapshot = await collection
        .where('date', isGreaterThanOrEqualTo: startOfToday)
        .where('date', isLessThan: endOfToday)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return {'lunch': false, 'dinner': false};
    }

    var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
    bool isLunchSelected = data['lunch'] >= 1;
    bool isDinnerSelected = data['dinner'] >= 1;

    return {'lunch': isLunchSelected, 'dinner': isDinnerSelected};
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text('No data available'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final qrCodeUrl = userData['qr_code_url'];

        if (qrCodeUrl == null) {
          return const Center(child: Text('QR code not available'));
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Uint8List>(
              future: _fetchQRCode(qrCodeUrl),
              builder: (context, qrSnapshot) {
                if (qrSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (qrSnapshot.hasError) {
                  return Text('Error: ${qrSnapshot.error}');
                }

                final qrCodeBytes = qrSnapshot.data;

                if (qrCodeBytes == null || qrCodeBytes.isEmpty) {
                  return const Text('Failed to load QR code');
                }

                return Image.memory(qrCodeBytes);
              },
            ),
            FutureBuilder<Map<String, bool>>(
              future: checkTodayLunchDinner(),
              builder: (context, mealSnapshot) {
                if (mealSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (mealSnapshot.hasError) {
                  return Text('Error: ${mealSnapshot.error}');
                } else {
                  bool hasLunch = mealSnapshot.data!['lunch'] ?? false;
                  bool hasDinner = mealSnapshot.data!['dinner'] ?? false;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          hasLunch
                              ? 'You have lunch selected for today.'
                              : 'You have no lunch selected for today.',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        Text(
                          hasDinner
                              ? 'You have dinner selected for today.'
                              : 'You have no dinner selected for today.',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List> _fetchQRCode(String qrCodeUrl) async {
    final response = await http.get(Uri.parse(qrCodeUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to fetch QR code');
    }
  }
}




// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class StudentQRCode extends StatefulWidget {
//   const StudentQRCode({Key? key}) : super(key: key);

//   @override
//   _StudentQRCodeState createState() => _StudentQRCodeState();
// }

// class _StudentQRCodeState extends State<StudentQRCode> {
//   late Future<Map<String, bool>> _mealSelectionFuture;

//   @override
//   void initState() {
//     super.initState();
//     _mealSelectionFuture = checkTodayLunchDinner();
//   }

//   void _updateMealSelection() {
//     setState(() {
//       _mealSelectionFuture = checkTodayLunchDinner();
//     });
//   }

//   Future<Map<String, bool>> checkTodayLunchDinner() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return {'lunch': false, 'dinner': false};
//     }

//     DateTime today = DateTime.now();
//     DateTime startOfToday = DateTime(today.year, today.month, today.day);
//     DateTime endOfToday = startOfToday.add(const Duration(days: 1));

//     var collection = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('selectedDays');
//     var querySnapshot = await collection
//         .where('date', isGreaterThanOrEqualTo: startOfToday)
//         .where('date', isLessThan: endOfToday)
//         .get();

//     if (querySnapshot.docs.isEmpty) {
//       return {'lunch': false, 'dinner': false};
//     }

//     var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
//     bool isLunchSelected = data['lunch'] >= 1;
//     bool isDinnerSelected = data['dinner'] >= 1;

//     return {'lunch': isLunchSelected, 'dinner': isDinnerSelected};
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Center(child: Text('User not logged in'));
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || snapshot.data!.data() == null) {
//           return const Center(child: Text('No data available'));
//         }

//         final userData = snapshot.data!.data() as Map<String, dynamic>;
//         final qrCodeUrl = userData['qr_code_url'];

//         if (qrCodeUrl == null) {
//           return const Center(child: Text('QR code not available'));
//         }

//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FutureBuilder<Uint8List>(
//               future: _fetchQRCode(qrCodeUrl),
//               builder: (context, qrSnapshot) {
//                 if (qrSnapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 }

//                 if (qrSnapshot.hasError) {
//                   return Text('Error: ${qrSnapshot.error}');
//                 }

//                 final qrCodeBytes = qrSnapshot.data;

//                 if (qrCodeBytes == null || qrCodeBytes.isEmpty) {
//                   return const Text('Failed to load QR code');
//                 }

//                 return GestureDetector(
//                   onTap: _updateMealSelection, // Call _updateMealSelection() on tap
//                   child: Image.memory(qrCodeBytes),
//                 );
//               },
//             ),
//             FutureBuilder<Map<String, bool>>(
//               future: _mealSelectionFuture, // Use the Future from state variable
//               builder: (context, mealSnapshot) {
//                 if (mealSnapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (mealSnapshot.hasError) {
//                   return Text('Error: ${mealSnapshot.error}');
//                 } else {
//                   bool hasLunch = mealSnapshot.data!['lunch'] ?? false;
//                   bool hasDinner = mealSnapshot.data!['dinner'] ?? false;
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           hasLunch
//                               ? 'You have lunch selected for today.'
//                               : 'You have no lunch selected for today.',
//                           style: TextStyle(fontSize: 16, color: Colors.green),
//                         ),
//                         Text(
//                           hasDinner
//                               ? 'You have dinner selected for today.'
//                               : 'You have no dinner selected for today.',
//                           style: TextStyle(fontSize: 16, color: Colors.blue),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<Uint8List> _fetchQRCode(String qrCodeUrl) async {
//     final response = await http.get(Uri.parse(qrCodeUrl));
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception('Failed to fetch QR code');
//     }
//   }
// }