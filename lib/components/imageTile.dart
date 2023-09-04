import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final String imagePath;
  Function()? onTap;
  ImageTile({super.key, required this.imagePath,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Image.asset(imagePath,height: 40,),

      ),
    );
  }
}
