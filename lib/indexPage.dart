import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haryanaassociationofkenya/screens/authService.dart';
import 'package:haryanaassociationofkenya/screens/contact.dart';
import 'package:haryanaassociationofkenya/screens/createEvent.dart';
import 'package:haryanaassociationofkenya/screens/facebookPage.dart';
import 'package:haryanaassociationofkenya/screens/profile.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:haryanaassociationofkenya/screens/usersPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;
  //User? _user;
  String name = '';
  String _name='';
  String _email = '';
  String _profileImageUrl = '';
  String img='';

  String _documentID = '';




  List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Text('Facebook Page'),
  ];

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _email = user!.email!;
  }
  final User? user = FirebaseAuth.instance.currentUser;




  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }
  void _getUserDetails() async {

    try {
      await FirebaseFirestore.instance
          .collection('haryana_users')
          .where('email', isEqualTo: user?.email)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((document) {
          _documentID = document.id;
          final data = document.data() as Map<String, dynamic>;

          img = data!['profileImageUrl'].toString();
          _name = data!['name'].toString();
        });
        setState(() {
          _profileImageUrl = img;
          name = _name;
        });
      });
    } catch (error) {
      print('Error getting image URL: $error');
    }
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingPage()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Profile()),
    );
  }

  void _navigateToContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage()),
    );
  }
  void _viewUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserListPage()),
    );
  }
  void _createEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEventPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: darkModeProvider.isDarkModeEnabled ? Colors.black87: Colors.white,
      appBar: AppBar(
        backgroundColor: darkModeProvider.isDarkModeEnabled ? Colors.black87: Colors.black,
        title: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  const SizedBox(width: 5.0),
                 Text(
                    "Welcome Back!",
                   style: TextStyle(
                     color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                     fontSize: fontSizeProvider.getTextSize(),
                   ),

                  ),
                  Text(
                    name.isNotEmpty ? name : 'Guest',
                    style: TextStyle(
                      color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 10.0),
                IconButton(
                  icon:  Icon(Icons.exit_to_app,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.white,),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: darkModeProvider.isDarkModeEnabled ? Colors.black87 : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                    color: darkModeProvider.isDarkModeEnabled ? Colors.grey : Colors.grey,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageUrl.isNotEmpty
                            ? NetworkImage(_profileImageUrl) as ImageProvider
                            : AssetImage('images/apple.png'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      name.isNotEmpty ? name : 'Guest',
                      style: TextStyle(
                        color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                        fontSize: fontSizeProvider.getTextSize(),
                      ),
                    ),
                    Text(
                      _email,
                      style: TextStyle(
                        color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                        fontSize: fontSizeProvider.getTextSize(),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                    ),
                title: Text('Settings',  style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                  fontSize: fontSizeProvider.getTextSize(),
                ),),
                onTap: _navigateToSettings,
              ),
              ListTile(
                leading: Icon(Icons.person,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,),
                title: Text('Profile',  style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                  fontSize: fontSizeProvider.getTextSize(),
                ),),
                onTap: _navigateToProfile,
              ),
              ListTile(
                leading: Icon(Icons.contact_mail,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,),
                title: Text('Contact',  style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                  fontSize: fontSizeProvider.getTextSize(),
                ),),
                onTap: _navigateToContact,
              ),
              ListTile(
                leading: Icon(Icons.contact_mail,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,),
                title: Text('Admin',  style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                  fontSize: fontSizeProvider.getTextSize(),
                ),),
                onTap: _createEvent,
              ),
              ListTile(
                leading: Icon(Icons.contact_mail,color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,),
                title: Text('Admin Users',  style: TextStyle(
                  color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                  fontSize: fontSizeProvider.getTextSize(),
                ),),
                onTap: _viewUsers,
              ),
            ],
          ),
        ),
      ),
      body:StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Event(
                id: doc.id,
                name: data['name'],
                description: data['description'],
                date: data['date'],
                imageUrl: data['imageUrl'],
              );
            }).toList();
          return _selectedIndex == 0
              ?  ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black87,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          event.date,
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black87,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          ):
          FaceBookPage();
        }
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',


          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.facebook),
            label: 'Facebook',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}







