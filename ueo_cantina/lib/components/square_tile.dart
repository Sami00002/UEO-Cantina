import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  // Declaration of a variable to hold the path of the image
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), 
        color: Colors.grey[200], 
      ),
      child: Image.asset(
        imagePath, 
        height: 200,
        ),
    );
  }
}