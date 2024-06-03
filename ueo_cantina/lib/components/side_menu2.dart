import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Users",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => onItemTapped(0),
            isSelected: selectedIndex == 0,
          ),
          DrawerListTile(
            title: "Second Component",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () => onItemTapped(1),
            isSelected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.isSelected,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: isSelected ? Colors.blue : null, // Change color based on selection
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : null, // Change text color based on selection
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold font for selected item
        ),
      ),
    );
  }
}