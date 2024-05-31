import 'package:flutter/material.dart';
import 'package:ueo_cantina/screens/login_page.dart';
import 'package:ueo_cantina/responsive.dart';
import 'package:ueo_cantina/components/side_menu.dart';
import 'package:ueo_cantina/components/studentTable.dart'; // Import QR generator component
import 'package:ueo_cantina/components/student_qr.dart'; // Import student table widget
import 'package:ueo_cantina/components/ginving_bon.dart';
import 'package:ueo_cantina/components/setting_page.dart';


class HomePage2 extends StatefulWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  int _selectedIndex = 0; // Initially selected index is 1 for the QR generator page

  static const List<Widget> _widgetOptions = <Widget>[
    StudentQRCode(),
    StudentTable(),
    Users(),
    RootApp(), // Display the student's QR code
     // QR code generator component
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: SideMenu(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SideMenu(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
          Expanded(
            flex: 5,
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }
}