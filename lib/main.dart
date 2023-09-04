import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/indexPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haryanaassociationofkenya/screens/authService.dart';
import 'package:haryanaassociationofkenya/screens/login.dart';
import 'package:haryanaassociationofkenya/screens/register.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkModeProvider>(
          create: (context) => DarkModeProvider(),
        ),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (context) => FontSizeProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],

      child: MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return MaterialApp(
      theme: darkModeProvider.isDarkModeEnabled
          ? ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      )
          : ThemeData.light().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: AuthPage()),
    );
  }
}

