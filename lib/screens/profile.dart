import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:haryanaassociationofkenya/screens/authService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import 'settings.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController aboutImage = TextEditingController();
  String imgUrl = '';
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late String _currentPassword;
  late String _newPassword;
  String _firstName = '';
  String _email = '';
  String _lastName = '';
  String _documentID = '';
  String imgDescription = '';
  String img = '';
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  void addDetails() async {
    String imgText = aboutImage.text.trim();
    await FirebaseFirestore.instance.collection('images').add({
      'imgText': imgText,
      'img': imgUrl,
    });
  }

  @override
  void initState() {
    super.initState();

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    FirebaseFirestore.instance
        .collection('haryana_users')
        .where('email', isEqualTo: user?.email)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        _documentID = document.id;
        final data = document.data() as Map<String, dynamic>;
        _firstNameController = TextEditingController(text: data['name']);
        //  _lastNameController = TextEditingController(text: data['name']);
        _emailController = TextEditingController(text: data['email']);
        aboutImage = TextEditingController(text: data['profileImageUrl']);
        img = data!['profileImageUrl'];
      });
      setState(() {});
    });
  }

  void updateDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    try {
      final credential = EmailAuthProvider.credential(
        email: email!,
        password: _currentPassword,
      );

      await user?.reauthenticateWithCredential(credential);

      await user?.updatePassword(_newPassword);
      await user?.updateEmail(_email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
        ),
      );
      _logout();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wrong current password'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final users = FirebaseFirestore.instance.collection('haryana_users');

    return Scaffold(
      backgroundColor:
          darkModeProvider.isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Center(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Update Profile',
                textStyle: TextStyle(
                  fontSize: fontSizeProvider.getTextSize(),
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
      ),
      //bottomNavigationBar: MyBottomNavigationBar(),
      body: Container(
        child: _documentID == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkModeProvider.isDarkModeEnabled ? Colors.grey : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: darkModeProvider.isDarkModeEnabled ? Colors.grey : Colors.white,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundImage: img != null
                                  ? NetworkImage(img)
                                  : const Icon(Icons.account_circle)
                                      as ImageProvider,
                              radius: 135.0,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker imagePicker = ImagePicker();

                              final XFile? file = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (file == null) return;

                              final String uniqueFileName =
                                  user!.uid.toString();
                              final Reference referenceRoot =
                                  FirebaseStorage.instance.ref();
                              final Reference referenceDirImages =
                                  referenceRoot.child('profile');
                              final Reference referenceImageToUpload =
                                  referenceDirImages.child(uniqueFileName);

                              try {
                                await referenceImageToUpload
                                    .putFile(File(file.path));
                                imgUrl = await referenceImageToUpload
                                    .getDownloadURL();
                              } catch (error) {
                                // handle error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating Image'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.camera_alt_sharp,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          TextFormField(
                            controller: _firstNameController,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 19,
                            ),
                            decoration: InputDecoration(
                              // labelText: 'First Name',
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                              ),
                              hintText: 'Enter your first name',
                              hintStyle: TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _firstName = value!;
                            },
                          ),
                          SizedBox(height: 32.0),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(color: Colors.black, fontSize: 19),
                            decoration: InputDecoration(
                              // labelText: 'Email',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 19),
                              hintText: 'Enter your Email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Email Address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _currentPasswordController,
                            style:
                                TextStyle(color: Colors.orange, fontSize: 19),
                            decoration: InputDecoration(
                              //labelText: 'Current Password',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 19),
                              hintText: "Current Password",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _currentPassword = value;
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _newPasswordController,
                            style:
                                TextStyle(color: Colors.orange, fontSize: 19),
                            decoration: InputDecoration(
                              //labelText: 'New Password',
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 19),
                              hintText: "New Password",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your new password';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _newPassword = value;
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (imgUrl.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Upload Image!"),
                                ));
                                return;
                              }
                              updateDetails();
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                users.doc(_documentID).update({
                                  'name': _firstName,
                                  //'lname': _lastName,
                                  'email': _email,
                                  'profileImageUrl': imgUrl,
                                }).then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Profile updated successfully'),
                                    ),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error updating profile'),
                                    ),
                                  );
                                });
                              }
                            },
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.white),
                                ),
                              ),
                              elevation: MaterialStateProperty.all<double>(5),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
