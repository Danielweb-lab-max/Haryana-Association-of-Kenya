import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:provider/provider.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,

        style: TextStyle(
          color:  darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black87
        ),
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
        color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
          fontSize: fontSizeProvider.getTextSize(),
        ),
        ),
      ),
    );
  }
}
