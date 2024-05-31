import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentTable extends StatefulWidget {
  const StudentTable({Key? key}) : super(key: key);

  @override
  State<StudentTable> createState() => _StudentTableState();
}

class _StudentTableState extends State<StudentTable> {
  final user = FirebaseAuth.instance.currentUser!; // Get the currently signed-in user
  late Future<List<DocumentSnapshot>> selectedDays; // Future to hold the list of selected days fetched from Firestore
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDays = getSelectedDays(); // Fetch selected days when the widget is initialized
  }

  // Function to fetch selected days from Firestore
  Future<List<DocumentSnapshot>> getSelectedDays() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 1);

    var collection = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('selectedDays');
    var querySnapshot = await collection
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: endOfMonth)
        .get();

    return querySnapshot.docs;
  }

  // Function to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Do something based on the selected index
    switch (index) {
      case 0:
        break;
      case 1:
        // Add your desired functionality here
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Welcome', style: Theme.of(context).textTheme.headline4),
            ),
            // FutureBuilder to wait for and display the fetched selected days
            FutureBuilder<List<DocumentSnapshot>>(
              future: selectedDays,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for data
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true, // Allows the ListView to size itself according to its children
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data![index];
                      DateTime date = (doc['date'] as Timestamp).toDate();
                      int lunch = doc['lunch'] ?? 0; // Changed to integer type
                      int dinner = doc['dinner'] ?? 0; // Changed to integer type

                      // Each item in the list shows the date, and whether lunch and/or dinner was selected
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${date.day}/${date.month}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('$lunch', style: TextStyle(color: lunch == 1 ? Colors.green : Colors.grey)), // Using integer values
                              Text('$dinner', style: TextStyle(color: dinner == 1 ? Colors.blue : Colors.grey)), // Using integer values
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}