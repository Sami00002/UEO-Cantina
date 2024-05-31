import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  final ImagePicker _picker = ImagePicker();

  late String _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = "https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=386&q=80"; // Initialize with a default image URL
    _fetchProfileImageUrl();
  }

  Future<void> _fetchProfileImageUrl() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      setState(() {
        _profileImageUrl = snapshot.get('profileImageUrl') ?? _profileImageUrl;
      });
    } catch (error) {
      print('Error fetching profile image URL: $error');
    }
  }

  Future<void> _changeProfileImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Upload the picked image to Firebase Storage
      try {
        final File imageFile = File(pickedImage.path);
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String imagePath = 'profile_images/$userId.jpg';

        TaskSnapshot snapshot =
            await FirebaseStorage.instance.ref().child(imagePath).putFile(imageFile);

        // Get the download URL of the uploaded image
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Update the user's profile image URL in Firestore
        await FirebaseFirestore.instance.collection('user').doc(userId).update({
          'profileImageUrl': imageUrl,
        });

        // Update the profile image URL in the widget
        setState(() {
          _profileImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile image updated successfully'),
        ));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error updating profile image: $error'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("PROFILE"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PROFILE SECTION
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  _profileImageUrl, // Use the updated profile image URL
                ),
              ),
              SizedBox(height: 10),
              Text(
                "User Name", // Update with user's name from Firestore
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "User Specialization", // Update with user's specialization from Firestore
              ),
              Text(
                "An 2024", // Update with user's year from Firestore
              ),
              SizedBox(height: 20),
            ],
          ),
          // EDIT PROFILE SECTION
          Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Change Profile Image'),
                  onTap: () => _changeProfileImage(),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Change Name'),
                  onTap: () {
                    // Navigate to Change Name screen
                  },
                ),
              ],
            ),
          ),
          // SETTINGS SECTION
          Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Change Password'),
                  onTap: () {
                    // Navigate to Change Password screen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.nightlight_round),
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: false, // Replace with actual value for dark mode
                    onChanged: (value) {
                      // Toggle dark mode
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    // Perform logout action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}