import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();

  Future<void> createGroup(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? initiatedBy = prefs.getString('email');
    String? token = prefs.getString('token');

    if (initiatedBy == null || token == null) {
      print('User not logged in');
      return;
    }

    final apiUrl = Uri.parse('http://10.0.2.2:4000/create-group');
    final groupName = nameController.text;
    final description = descriptionController.text;
    final maxParticipants = int.tryParse(maxParticipantsController.text);

    if (maxParticipants == null ||
        maxParticipants < 2 ||
        maxParticipants > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Max participants must be between 2 and 50')),
      );
      return;
    }

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupName': groupName,
          'initiatedBy': initiatedBy,
          'description': description,
          'maxParticipants': maxParticipants,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Group created successfully: ${responseData['groupId']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')),
        );
        Navigator.pop(context); // Navigate back after group creation
      } else {
        print('Failed to create group. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create group')),
        );
      }
    } catch (error) {
      print('Error creating group: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Group',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: TextField(
                controller: maxParticipantsController,
                decoration:
                    const InputDecoration(labelText: 'Max Participants'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => createGroup(context),
              child: Text(
                'Create Group',
                style: TextStyle(color: themeProvider.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
