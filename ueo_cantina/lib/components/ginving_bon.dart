import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectedDay {
  final DateTime date;
  final int lunchCount;
  final int dinnerCount;

  SelectedDay({
    required this.date,
    required this.lunchCount,
    required this.dinnerCount,
  });
}

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final user = FirebaseAuth.instance.currentUser!;

  Future<Map<String, bool>> checkTodayLunchDinner() async {
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    DateTime endOfToday = startOfToday.add(Duration(days: 1));

    var collection = _firestore.collection('users').doc(user.uid).collection('selectedDays');
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

  Future<void> _handleSendDinner(String recipientUserId) async {
    await _handleSendMeal(recipientUserId, 'dinner');
  }

  Future<void> _handleSendLunch(String recipientUserId) async {
    await _handleSendMeal(recipientUserId, 'lunch');
  }

  Future<void> _handleSendMeal(String recipientUserId, String mealType) async {
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    DateTime endOfToday = startOfToday.add(Duration(days: 1));

    var senderCollection = _firestore.collection('users').doc(user.uid).collection('selectedDays');
    var recipientCollection = _firestore.collection('users').doc(recipientUserId).collection('selectedDays');

    var senderSnapshot = await senderCollection
        .where('date', isGreaterThanOrEqualTo: startOfToday)
        .where('date', isLessThan: endOfToday)
        .get();

    var recipientSnapshot = await recipientCollection
        .where('date', isGreaterThanOrEqualTo: startOfToday)
        .where('date', isLessThan: endOfToday)
        .get();

    if (senderSnapshot.docs.isEmpty || recipientSnapshot.docs.isEmpty) {
      return;
    }

    var senderData = senderSnapshot.docs.first.data() as Map<String, dynamic>;
    var recipientData = recipientSnapshot.docs.first.data() as Map<String, dynamic>;

    if (senderData[mealType] >= 1) {
      await senderCollection.doc(senderSnapshot.docs.first.id).update({
        mealType: FieldValue.increment(-1),
      });
      await recipientCollection.doc(recipientSnapshot.docs.first.id).update({
        mealType: FieldValue.increment(1),
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
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
          FutureBuilder<Map<String, bool>>(
            future: checkTodayLunchDinner(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                bool hasLunch = snapshot.data!['lunch'] ?? false;
                bool hasDinner = snapshot.data!['dinner'] ?? false;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        hasLunch ? 'You have lunch selected for today.' : 'You have no lunch selected for today.',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      Text(
                        hasDinner ? 'You have dinner selected for today.' : 'You have no dinner selected for today.',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('user').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Compact view for small screens
                      return ListView(
                        children: filteredDocs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          String profileImageUrl = data['profileImageUrl'] ?? 'lib/common/images/profile.png';
                          String fullName = '${data['nume']} ${data['prenume']}';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              title: Text(fullName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _handleSendLunch(document.id);
                                    },
                                    child: Text('Send Lunch'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _handleSendDinner(document.id);
                                    },
                                    child: Text('Send Dinner'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      // DataTable view for larger screens
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Photo')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Send Lunch')),
                            DataColumn(label: Text('Send Dinner')),
                          ],
                          rows: filteredDocs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            String profileImageUrl = data['profileImageUrl'] ?? 'lib/common/images/profile.png';
                            String fullName = '${data['nume']} ${data['prenume']}';

                            return DataRow(cells: [
                              DataCell(
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(profileImageUrl),
                                ),
                              ),
                              DataCell(Text(fullName)),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    _handleSendLunch(document.id);
                                  },
                                  child: Text('Send Lunch'),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    _handleSendDinner(document.id);
                                  },
                                  child: Text('Send Dinner'),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}