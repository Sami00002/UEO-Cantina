import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentQRCode extends StatelessWidget {
  const StudentQRCode({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not logged in
      return Text('User not logged in');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Text('No data available');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final qrCodeUrl = userData['qr_code_url'];

        if (qrCodeUrl == null) {
          return Text('QR code not available');
        }

        print('QR Code URL: $qrCodeUrl'); // Add this line for debugging

        return FutureBuilder<Uint8List>(
          future: _fetchQRCode(qrCodeUrl),
          builder: (context, qrSnapshot) {
            if (qrSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (qrSnapshot.hasError) {
              return Text('Error: ${qrSnapshot.error}');
            }

            final qrCodeBytes = qrSnapshot.data;

            if (qrCodeBytes == null || qrCodeBytes.isEmpty) {
              return Text('Failed to load QR code');
            }

            return Image.memory(qrCodeBytes);
          },
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