import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String date;
  final String imageUrl;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
  });
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  File? _image;
  bool _uploadingImage = false;

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _createEvent() async {
    if (_image == null || _uploadingImage || _selectedDate == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            content: Text(
              'Please fill all fields and select a date.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _uploadingImage = true;
    });

    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String imageFileName =
          DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef =
          storage.ref().child('event_images/$imageFileName.jpg');
      final UploadTask uploadTask = storageRef.putFile(_image!);

      final TaskSnapshot uploadSnapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await uploadSnapshot.ref.getDownloadURL();

      final CollectionReference eventsRef =
          FirebaseFirestore.instance.collection('events');
      final eventDoc = await eventsRef.add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'date': _selectedDate!.toIso8601String(),
        'imageUrl': imageUrl,
      });

      final event = Event(
        id: eventDoc.id,
        name: _nameController.text,
        description: _descriptionController.text,
        date: _selectedDate!.toIso8601String(),
        imageUrl: imageUrl,
      );

      Navigator.of(context).pop(event);
    } catch (e) {
      print('Error uploading image and creating event: $e');
    } finally {
      setState(() {
        _uploadingImage = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Create Event...',
              textStyle: const TextStyle(
                fontSize: 24.0,
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(
              color: darkModeProvider.isDarkModeEnabled
                  ? Colors.white
                  : Colors.black87,
              fontSize: fontSizeProvider.getTextSize(),
            ),
            decoration: InputDecoration(
              labelText: 'Event Name',
              labelStyle: TextStyle(
                color: darkModeProvider.isDarkModeEnabled
                    ? Colors.white
                    : Colors.black87,
                fontSize: fontSizeProvider.getTextSize(),
              ),
            ),
          ),
          TextField(
            controller: _descriptionController,

            style: TextStyle(
              color: darkModeProvider.isDarkModeEnabled
                  ? Colors.white
                  : Colors.black87,
              fontSize: fontSizeProvider.getTextSize(),
            ),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: darkModeProvider.isDarkModeEnabled
                    ? Colors.white
                    : Colors.black87,
                fontSize: fontSizeProvider.getTextSize(),
              ),
            ),
            maxLines: null,
          ),
          InkWell(
            onTap: _selectDate,
            child: IgnorePointer(
              child: TextField(
                controller: _dateController,
                style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled
                      ? Colors.white
                      : Colors.black87,
                  fontSize: fontSizeProvider.getTextSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled
                        ? Colors.white
                        : Colors.black87,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildImagePicker(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createEvent,
            child: Text(
              'Create Event',
              style: TextStyle(
                color: darkModeProvider.isDarkModeEnabled
                    ? Colors.white
                    : Colors.black87,
                fontSize: fontSizeProvider.getTextSize(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_image != null) {
      return Image.file(
        _image!,
        height: 200,
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: _uploadingImage ? null : _uploadImage,
            child: Text('Select Event Image'),
          ),
          if (_uploadingImage)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    }
  }
}
