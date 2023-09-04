import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  void _sendEmail() async {
    final smtpServer = gmail('danielndungo68@gmail.com', 'lbpayiusnubygozj');
    String name="${_nameController.text.trim()}";
    String email=_emailController.text.trim();
    String msg= _messageController.text.trim();

    final message = Message()
      ..from =  Address('danielndungo68@gmail.com', 'Admin')
      ..recipients.add('danielndungo68@gmail.com')
      ..subject = 'New Message'
      ..html = '''
        <h1>New Message</h1>
        <p>I Hope this Email Finds You well.My name is $name.</p>
        <p>$msg</p>
        <p>Kindly contact me via Email:<b> $email</b></p>
       
        
          
        
      ''';
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });
      await send(message, smtpServer);
      // addUserDetails(_firstNameController.text.trim(), _lastNameController.text.trim(), _emailController.text.trim(), _phoneController.text.trim(),_professionController.text.trim(),_organizationController.text.trim(),_courseNameController.text.trim());
      print('Email sent successfully!');

      //Navigator.pop(context);
      Navigator.pushNamed(
          context,
          '/success');

    } catch (e) {
      print('Error sending email: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Contact Us..',
              textStyle: const TextStyle(
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
      //bottomNavigationBar: MyBottomNavigationBar(),
      body: Container(

        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
             Image(
               image: AssetImage("images/contact.jpg"),
             ),
              SizedBox(
                height: 3,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Name',

                            hintText: 'Enter your name',

                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',

                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Message',

                            hintText: 'Enter your message',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: null,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your message';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32.0),
                        Center(
                          child: ElevatedButton(
                            child: Text('Submit',style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                              fontSize: fontSizeProvider.getTextSize(),
                            ),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                              // You can also set other properties of the button style here, such as padding, shape, etc.
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Send the message
                                _sendEmail();

                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 205,
              ),
              Center(
                child: Container(
                  width: 390,
                  height:200,
                  padding: const EdgeInsets.all(1),
                  margin: const EdgeInsets.only(bottom: 5, top: 5),
                  decoration: BoxDecoration(
                    color: darkModeProvider.isDarkModeEnabled ? Colors.black87 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkModeProvider.isDarkModeEnabled ? Colors.black87 : Colors.white,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Text(
                        'Contact Us',
                        style: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                          fontSize: fontSizeProvider.getTextSize(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                       Center(
                        child: Text(
                          'Eco Bank Towers, 4th Floor Muindi Mbingu Street\nP. O. Box 21857 - 00100 Nairobi\nPhone:+254 780 342 333, +254 202 246145 \nEmail: info@learnovate.co.ke',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
