import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haryanaassociationofkenya/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

void _downloadUserDetails(BuildContext context) async {
  final users =
      await FirebaseFirestore.instance.collection('haryana_users').get();

  final pdf = pw.Document();
  final tableHeaders = [
    'No.',
    'Name',
    'Phone Number',
    'Email',
    'Residence Status',
    'Business/Organisation',
    'Business Type'
  ]; // Add more headers if needed

  // Add table headers to the PDF
  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Table.fromTextArray(
        headers: tableHeaders,
        data: List<List<String>>.generate(
          users.docs.length,
          (index) {
            final user = users.docs[index].data() as Map<String, dynamic>;
            return [
              (index + 1).toString(),
              user['name'],

              user['mobile'],
              user['email'],
              user['residentStatus'],
              user['business'],
              user['businessType'],
              // Add more fields as needed
            ];
          },
        ),
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.center,
        headerAlignment: pw.Alignment.center,
      );
    },
  ));

  // Save the PDF file
  final output = await getTemporaryDirectory();
  final outputFile = File('${output.path}/user_details.pdf');
  await outputFile.writeAsBytes(await pdf.save());

  // Show a dialog with the download link
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Download Complete',
          style: TextStyle(color: Colors.black87),
        ),
        content: Text(
          'User details downloaded as PDF.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text(
              'Open PDF',
              style: TextStyle(color: Colors.black87),
            ),
            onPressed: () {
              // Open the PDF using the device's default PDF viewer
              OpenFile.open(outputFile.path);
            },
          ),
          TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.black87),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _UserListPageState extends State<UserListPage> {
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream =
        FirebaseFirestore.instance.collection('haryana_users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            darkModeProvider.isDarkModeEnabled ? Colors.black87 : Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Registered Users',
          style: TextStyle(
            color: darkModeProvider.isDarkModeEnabled
                ? Colors.white
                : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _downloadUserDetails(context);
            },
            icon: Icon(
              Icons.download,
              color: darkModeProvider.isDarkModeEnabled
                  ? Colors.white
                  : Colors.black87,
              size: fontSizeProvider.getTextSize(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!.docs;

            return DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    'No.',
                    style: TextStyle(
                      color: darkModeProvider.isDarkModeEnabled
                          ? Colors.white
                          : Colors.black,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(
                      color: darkModeProvider.isDarkModeEnabled
                          ? Colors.white
                          : Colors.black,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Email',
                    style: TextStyle(
                      color: darkModeProvider.isDarkModeEnabled
                          ? Colors.white
                          : Colors.black,
                      fontSize: fontSizeProvider.getTextSize(),
                    ),
                  ),
                ),
                // Add more columns as needed
              ],
              rows: List<DataRow>.generate(
                users.length,
                (index) {
                  final user = users[index].data() as Map<String, dynamic>;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled
                                ? Colors.white
                                : Colors.black,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          user['name'],
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled
                                ? Colors.white
                                : Colors.black,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          user['email'],
                          style: TextStyle(
                            color: darkModeProvider.isDarkModeEnabled
                                ? Colors.white
                                : Colors.black,
                            fontSize: fontSizeProvider.getTextSize(),
                          ),
                        ),
                      ),
                      // Add more cells as needed
                    ],
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
