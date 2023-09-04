import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeProvider with ChangeNotifier {
  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  set isDarkModeEnabled(bool value) {
    _isDarkModeEnabled = value;
    notifyListeners();
  }
}

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 16.0;

  double get fontSize => _fontSize;

  set fontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  double getTextSize() {
    if (_fontSize == 14.0) {
      return 12.0;
    } else if (_fontSize == 16.0) {
      return 16.0;
    } else if (_fontSize == 18.0) {
      return 18.0;
    } else {
      return 17.0; // Default font size
    }
  }
}

class NotificationProvider with ChangeNotifier {
  bool _areNotificationsEnabled = false;

  bool get areNotificationsEnabled => _areNotificationsEnabled;

  set areNotificationsEnabled(bool value) {
    _areNotificationsEnabled = value;
    notifyListeners();
  }
}
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    void showSnackbar(BuildContext context, bool value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Notifications are enabled.' : 'Notifications are disabled.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkModeProvider.isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkModeProvider.isDarkModeEnabled ? Colors.black : Colors.white,
        title: Consumer<DarkModeProvider>(
          builder: (context, provider, child) {
            return Text(
              'Settings',
              style: TextStyle(
                color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                fontSize: fontSizeProvider.getTextSize(),
              ),
            );
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(
              Icons.nights_stay_sharp,
              color: Colors.grey,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                fontSize: fontSizeProvider.getTextSize(),
              ),
            ),
            trailing: Switch(
              value: darkModeProvider.isDarkModeEnabled,
              onChanged: (value) {
                darkModeProvider.isDarkModeEnabled = value;
              },
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.text_fields,
              color: Colors.grey,
            ),
            title: Consumer<DarkModeProvider>(
              builder: (context, provider, child) {
                return Text(
                  'Font Size',
                  style: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                );
              },
            ),
            trailing: DropdownButton<double>(
              value: fontSizeProvider.fontSize,
              onChanged: (value) {
                fontSizeProvider.fontSize = value!;
              },
              items: [
                DropdownMenuItem<double>(
                  value: 14.0,
                  child: Consumer<DarkModeProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Small',
                        style: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                          fontSize: fontSizeProvider.getTextSize(),
                        ),
                      );
                    },
                  ),
                ),
                DropdownMenuItem<double>(
                  value: 16.0,
                  child: Consumer<DarkModeProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Medium',
                        style: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                          fontSize: fontSizeProvider.getTextSize(),
                        ),
                      );
                    },
                  ),
                ),
                DropdownMenuItem<double>(
                  value: 18.0,
                  child: Consumer<DarkModeProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Large',
                        style: TextStyle(
                          color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                          fontSize: fontSizeProvider.getTextSize(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: Colors.grey,
            ),
            title: Consumer<DarkModeProvider>(
              builder: (context, provider, child) {
                return Text(
                  'Notifications',
                  style: TextStyle(
                    color: darkModeProvider.isDarkModeEnabled ? Colors.white : Colors.black,
                    fontSize: fontSizeProvider.getTextSize(),
                  ),
                );
              },
            ),
            trailing: Switch(
              value: notificationProvider.areNotificationsEnabled,
              onChanged: (value) {
                notificationProvider.areNotificationsEnabled = value;
                showSnackbar(context, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

