import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _businessType = TextEditingController();
  final List<String> _residentStatuses = [
    'Citizen',
    'Resident 2',
    'Resident 3'
  ];
  String? _selectedResidentStatus;
 // final List<String> _businessTypes = ['Type 1', 'Type 2', 'Type 3'];
 // String? _selectedBusinessType;
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  bool _isButtonHovered = false;
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final selectedDate = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  Future<void> _uploadImageToStorage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final firebase_storage.UploadTask uploadTask =
          ref.putFile(File(_selectedImage!.path));
      final firebase_storage.TaskSnapshot storageSnapshot =
          await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });
    } catch (error) {
      setState(() {
        _isUploading = false;
      });
      print('Error uploading image: $error');
    }
  }

  void SignUpUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          builder: (context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        if (passwordController.text == passwordConfirmController.text) {
          // Check if the email is already in use
          bool isEmailInUse = await isEmailAlreadyInUse(_emailController.text);

          if (isEmailInUse) {
            Navigator.pop(context);
            showErrorMessage("Email is already in use");
          } else {
            UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: passwordController.text,
            );

            if (userCredential.user != null) {
              _registerUser(
                _nameController.text.trim(),
                _dobController.text.trim(),
                _emailController.text.trim(),
                _mobileController.text.trim(),
                _selectedResidentStatus!.trim(),
                _businessController.text.trim(),
                _businessType.text.trim(),
                _uploadedImageUrl!.trim(),
                passwordController.text.trim(),
              );
            } else {
              // User creation failed
              Navigator.pop(context);
              showErrorMessage("Failed to create user");
            }
          }
        } else {
          Navigator.pop(context);
          showErrorMessage("Passwords Don't Match");
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showErrorMessage(e.code);
      }
    }
  }

// Function to check if the email is already in use
  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('haryana_users');
      final QuerySnapshot snapshot =
          await usersCollection.where('email', isEqualTo: email).limit(1).get();

      // If a document is found with the given email, it means the email is already in use
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors that occur during the query
      print('Error checking email availability: $e');
      throw e;
    }
  }

  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            errorMessage,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        );
      },
    );
  }

  Future<void> _registerUser(
      String name,
      String dob,
      String email,
      String mobile,
      String residentStatus,
      String business,
      String businessType,
      String profileImageUrl,
      String pass) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('haryana_users');
      await usersCollection.add({
        'name': name,
        'dob': dob,
        'email': email,
        'mobile': mobile,
        'residentStatus': residentStatus,
        'business': business,
        'businessType': businessType,
        'profileImageUrl': profileImageUrl,
        'password': pass,
      });

      // Registration successful, display a success message or navigate to a new screen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Registration Successful',
              style: TextStyle(color: Colors.green),
            ),
            content: Text(
              'User registered successfully.',
              style: TextStyle(color: Colors.green),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      // Clear form fields after successful registration
      _nameController.clear();
      _dobController.clear();
      _emailController.clear();
      _mobileController.clear();
      _businessController.clear();
      _selectedResidentStatus = null;
     // _selectedBusinessType = null;
      _businessType.clear();
      _selectedImage = null;
      _uploadedImageUrl = null;
    } catch (error) {
      print('Error registering user: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Registration Failed',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'Failed to register user. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _businessController.dispose();
    passwordConfirmController.dispose();
    passwordController.dispose();
    _businessType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Haryana Association Of Kenya',
                  textStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.white,
                    fontSize: fontSizeProvider.getTextSize(),
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 70),
                ),
              ],
              totalRepeatCount: 1000,
              pause: const Duration(milliseconds: 100),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          )),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dobController,
                      style: TextStyle(
                        color: darkModeProvider.isDarkModeEnabled
                            ? Colors.white
                            : Colors.black87,
                        fontSize: fontSizeProvider.getTextSize(),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        labelStyle: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled
                              ? Colors.white
                              : Colors.black87,
                          fontSize: fontSizeProvider.getTextSize(),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: darkModeProvider.isDarkModeEnabled
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: "e.g sam@gmail.com",
                  hintStyle:TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12,
                  ) ,
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _mobileController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',

                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (!isValidMobileNumber(value)) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordConfirmController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedResidentStatus,
                items: _residentStatuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: darkModeProvider.isDarkModeEnabled
                            ? Colors.white
                            : Colors.black87,
                        fontSize: fontSizeProvider.getTextSize(),
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Resident Status',
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your resident status';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedResidentStatus = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _businessController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Business/Organisation',
                  hintText: "e.g safaricom",
                  hintStyle:TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12,
                  ) ,
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your business/organisation name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // DropdownButtonFormField<String>(
              //   value: _selectedBusinessType,
              //   items: _businessTypes.map((String type) {
              //     return DropdownMenuItem<String>(
              //       value: type,
              //       child: Text(
              //         type,
              //         style: TextStyle(
              //           color: darkModeProvider.isDarkModeEnabled
              //               ? Colors.white
              //               : Colors.black87,
              //           fontSize: fontSizeProvider.getTextSize(),
              //         ),
              //       ),
              //     );
              //   }).toList(),
              //   decoration: InputDecoration(
              //     labelText: 'Business Type',
              //     labelStyle: TextStyle(
              //       color: darkModeProvider.isDarkModeEnabled
              //           ? Colors.white
              //           : Colors.black87,
              //       fontSize: fontSizeProvider.getTextSize(),
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null) {
              //       return 'Please select your business type';
              //     }
              //     return null;
              //   },
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedBusinessType = value!;
              //     });
              //   },
              // ),
              TextFormField(
                controller: _businessType,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Business Type/Vertical',
                  hintText: "e.g retail",
                  hintStyle:TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12,
                  ) ,
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your business/organisation Type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  await _selectImage();
                  await _uploadImageToStorage();
                },
                child: Text(
                  'Select Profile Image',
                  style: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              _isUploading
                  ? CircularProgressIndicator()
                  : _uploadedImageUrl != null
                      ? Image.network(
                          _uploadedImageUrl!,
                          height: 200,
                        )
                      : SizedBox(),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: SignUpUser,
                child: Text('Register'),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: darkModeProvider.isDarkModeEnabled
                          ? Colors.white
                          : Colors.black87,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login Now",
                      style: TextStyle(
                        color: darkModeProvider.isDarkModeEnabled
                            ? Colors.white
                            : Colors.green,
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
    );
  }

  bool isValidEmail(String value) {
    final pattern =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';
    final regex = RegExp(pattern);
    return regex.hasMatch(value);
  }

  bool isValidMobileNumber(String value) {
    if (value.length >= 14) {
      return false;
    }

    return true;
  }
}
