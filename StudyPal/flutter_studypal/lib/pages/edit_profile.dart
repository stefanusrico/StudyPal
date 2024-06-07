import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  String? email;
  String? token;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedDate = DateTime.now();
    _getEmailandToken().then((_) {
      getProfileData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<void> saveProfileChanges(
    String firstName,
    String lastName,
    DateTime birthDate,
  ) async {
    final url = Uri.parse('http://10.0.2.2:4000/users/$email');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      // Profil berhasil diperbarui
      print('Profile updated successfully');
    } else {
      // Terjadi kesalahan saat memperbarui profil
      print('Failed to update profile: ${response.body}');
    }
  }

  Future<void> getProfileData() async {
    final url = Uri.parse('http://10.0.2.2:4000/users/$email');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fullName = data['fullName'];
      final birthDate = DateTime.parse(data['birth_date']);

      setState(() {
        _nameController.text = fullName;
        _selectedDate = birthDate;
      });
    } else {
      print('Failed to fetch user data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                // Implement logic to select and update profile picture
              },
              child: const CircleAvatar(
                radius: 50,
                // backgroundImage:
                //     NetworkImage('https://example.com/profile.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final nameParts = _nameController.text.split(' ');
                final firstName =
                    nameParts.sublist(0, nameParts.length - 1).join(' ');
                final lastName = nameParts.length > 1 ? nameParts.last : '';
                saveProfileChanges(firstName, lastName, _selectedDate);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
