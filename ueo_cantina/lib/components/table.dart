import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ueo_cantina/components/custom_calendar.dart'; 


class SelectedDay {
  final DateTime date;
  final bool isLunchSelected;
  final bool isDinnerSelected;

  SelectedDay({
    required this.date,
    required this.isLunchSelected,
    required this.isDinnerSelected,
  });
}

class UserTable extends StatefulWidget {
  const UserTable({Key? key}) : super(key: key);

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('user').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['email']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      data['nume']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      data['prenume']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      data['specializare']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      data['an']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text('No users found.'),
                  );
                }

                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Photo')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Nume')),
                    DataColumn(label: Text('Prenume')),
                    DataColumn(label: Text('Specializare')),
                    DataColumn(label: Text('An')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String profileImageUrl = data['profileImageUrl'] ??
                        'lib/common/images/profile.png'; // Default image if profile image is not available

                    return DataRow(cells: [
                      DataCell(
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                      ),
                      DataCell(Text(data['email'] ?? 'No email')),
                      DataCell(Text(data['nume'] ?? 'No name')),
                      DataCell(Text(data['prenume'] ?? 'No surname')),
                      DataCell(Text(data['specializare'] ?? 'No specializare')),
                      DataCell(Text(data['an']?.toString() ?? 'No year')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(document),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteUser(document),
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _showCustomCalendar(document.id),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showAddDialog(),
              child: Text('Add User'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomCalendar(String userId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CustomCalendar(userId: userId)));
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _numeController,
                  decoration: InputDecoration(labelText: 'Nume'),
                ),
                TextField(
                  controller: _prenumeController,
                  decoration: InputDecoration(labelText: 'Prenume'),
                ),
                TextField(
                  controller: _specializareController,
                  decoration: InputDecoration(labelText: 'Specializare'),
                ),
                TextField(
                  controller: _anController,
                  decoration: InputDecoration(labelText: 'An'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addUser();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Generate QR code URL
      String qrCodeUrl = await _generateQRCodeUrl(userId);

      // Save user data along with the QR code URL in Firestore
      await _firestore.collection('user').doc(userId).set({
        'nume': _numeController.text,
        'prenume': _prenumeController.text,
        'specializare': _specializareController.text,
        'an': int.parse(_anController.text),
        'email': email,
        'qr_code_url': qrCodeUrl, // Save QR code URL here
      });

      _clearControllers();
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  Future<String> _generateQRCodeUrl(String userId) async {
    // Constructing QR code data with user ID
    String qrCodeData =
        'http://api.qrserver.com/v1/create-qr-code/?data=$userId&size=150x150';

    // You can directly return the URL if you're not uploading to Firebase Storage
    return qrCodeData;
  }

  void _showEditDialog(DocumentSnapshot document) {
    String tempNume = document['nume'];
    String tempPrenume = document['prenume'];
    String tempSpecializare = document['specializare'];
    int tempAn = document['an'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: tempNume),
                  onChanged: (value) => tempNume = value,
                  decoration: InputDecoration(labelText: 'Nume'),
                ),
                TextField(
                  controller: TextEditingController(text: tempPrenume),
                  onChanged: (value) => tempPrenume = value,
                  decoration: InputDecoration(labelText: 'Prenume'),
                ),
                TextField(
                  controller: TextEditingController(text: tempSpecializare),
                  onChanged: (value) => tempSpecializare = value,
                  decoration: InputDecoration(labelText: 'Specializare'),
                ),
                TextField(
                  controller: TextEditingController(text: tempAn.toString()),
                  onChanged: (value) => tempAn = int.tryParse(value) ?? tempAn,
                  decoration: InputDecoration(labelText: 'An'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Dismiss the dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Save Changes'),
                      content:
                          Text('Are you sure you want to save these changes?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .pop(), // Dismiss the confirmation dialog
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Dismiss the confirmation dialog
                            Navigator.of(context)
                                .pop(); // Dismiss the edit dialog

                            Map<String, dynamic> updatedData = {
                              'nume': tempNume,
                              'prenume': tempPrenume,
                              'specializare': tempSpecializare,
                              'an': tempAn,
                            };
                            _updateUser(document.id, updatedData);
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateUser(String documentId, Map<String, dynamic> data) {
    _firestore.collection('user').doc(documentId).update(data);
  }

  void _deleteUser(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Dismiss the dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog before deleting
                try {
                  String userId = document.id;

                  // Delete user document in 'users' collection
                  await _firestore.collection('users').doc(userId).delete();

                  // Delete user document in 'user' collection
                  await _firestore.collection('user').doc(userId).delete();

                  // Delete associated data in 'user_selected_days' collection
                  QuerySnapshot selectedDaysSnapshot = await _firestore
                      .collection('users')
                      .doc(userId)
                      .collection('selectedDays')
                      .get();
                  for (DocumentSnapshot ds in selectedDaysSnapshot.docs) {
                    await ds.reference.delete();
                  }

                  // Delete the 'selectedDays' subcollection
                  await _firestore
                      .collection('users')
                      .doc(userId)
                      .collection('selectedDays')
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot doc in snapshot.docs) {
                      doc.reference.delete();
                    }
                  });

                  // Delete authentication account
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null && user.uid == userId) {
                    // Delete user authentication account
                    await user.delete();
                  }

                  // Trigger UI update
                  setState(() {});

                  // Additional cleanup if necessary, such as deleting QR code data
                } catch (e) {
                  print("Error deleting user: $e");
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _saveSelectedDay(String userId, DateTime date, bool isLunchSelected,
      bool isDinnerSelected) async {
    try {
      await _firestore
          .collection('user_selected_days')
          .doc(userId)
          .collection('days')
          .doc(date.toString())
          .set({
        'date': date,
        'isLunchSelected': isLunchSelected,
        'isDinnerSelected': isDinnerSelected,
      });
    } catch (error) {
      //print('Error saving selected day: $error');
    }
  }

  void _clearControllers() {
    _numeController.clear();
    _prenumeController.clear();
    _specializareController.clear();
    _anController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  final TextEditingController _numeController = TextEditingController();
  final TextEditingController _prenumeController = TextEditingController();
  final TextEditingController _specializareController = TextEditingController();
  final TextEditingController _anController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
}
