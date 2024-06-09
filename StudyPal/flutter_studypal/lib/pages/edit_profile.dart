import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late DateTime _selectedDate;
  String? email;
  String? token;
  File? _imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _selectedDate = DateTime.now();
    _getEmailandToken().then((_) {
      getProfileData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> saveProfileChanges() async {
    final url = Uri.parse('http://10.0.2.2:4000/users/$email');

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = "Bearer $token";

    if (_imageFile != null) {
      var stream = http.ByteStream(_imageFile!.openRead());
      var length = await _imageFile!.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: _imageFile!.path.split('/').last);
      request.files.add(multipartFile);
    }

    request.fields['first_name'] = _firstNameController.text;
    request.fields['last_name'] = _lastNameController.text;
    request.fields['birth_date'] = _selectedDate.toIso8601String();

    var response = await request.send();

    print(response.statusCode);

    if (response.statusCode == 200) {
      print('Profile updated successfully');
      Navigator.pop(context);
    } else {
      print('Failed to update profile: ${response.reasonPhrase}');
      print('Response body: ${await response.stream.bytesToString()}');
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

    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final firstName = data['first_name'];
      final lastName = data['last_name'];
      final birthDate = DateTime.parse(data['birth_date']);
      final fetchedImageUrl = data['image'];

      setState(() {
        _firstNameController.text = firstName ?? '';
        _lastNameController.text = lastName ?? '';
        _selectedDate = birthDate;
        if (fetchedImageUrl != null) {
          _imageFile = null; // Reset _imageFile jika ada gambar dari API
          imageUrl = fetchedImageUrl; // Simpan URL gambar ke variabel imageUrl
        }
      });
    } else {
      print('Failed to fetch user data: ${response.body}');
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
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
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null && imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          imageUrl ?? '',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : 0,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
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
              onPressed: saveProfileChanges,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
