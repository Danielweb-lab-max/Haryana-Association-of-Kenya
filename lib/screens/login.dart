import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/authService.dart';
import 'package:haryanaassociationofkenya/components/button.dart';
import 'package:haryanaassociationofkenya/components/imageTile.dart';
import 'package:haryanaassociationofkenya/components/my_textfield.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:provider/provider.dart';

class loginPage extends StatefulWidget {
  final Function()? onTap;
  loginPage({super.key, required this.onTap});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  double _opacity = 0.4;
  void SignInUser() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return Center(child: CircularProgressIndicator());
          });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Invalid Email Address",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            );
          },
        );
      } else if (e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Invalid Password",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Invalid Details",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/login.jpg"), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),

                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 1)
                            .withOpacity(_opacity),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(30))),
                    //width: MediaQuery.of(context).size.width * 0.9,
                    // height: MediaQuery.of(context).size.height * 0.4,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Hi!,Welcome Back...',
                          textStyle:  TextStyle(
                    color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                          speed: const Duration(milliseconds: 120),
                        ),
                      ],
                      totalRepeatCount: 1000,
                      pause: const Duration(milliseconds: 120),
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",


                    obscureText: false,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  MyButton(
                    onTap: SignInUser,
                    text: "Sign In",
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "or continue with",
                            style: TextStyle(
                              color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                              fontSize: fontSizeProvider.getTextSize(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageTile(
                        onTap:(){
                          AuthService().signInWithGoogle();
                        },
                          imagePath: "images/google.png"),
                      SizedBox(
                        width: 14,
                      ),
                      ImageTile(
                        onTap: (){

                        },
                          imagePath: "images/apple.png",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not yet a member?",
                        style: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                          fontSize: fontSizeProvider.getTextSize(),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Register Now",
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.green,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
