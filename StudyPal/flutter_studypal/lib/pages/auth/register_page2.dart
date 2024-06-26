import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/auth/login_page.dart';
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:flutter_studypal/utils/global_colors.dart';
import 'package:flutter_studypal/utils/global_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class RegisterPage2 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterPage2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterPage2> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage2> {
  bool value = false;
  bool isObscureText = true;
  String? _gender;
  DateTime? _birthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SvgPicture.asset("lib/assets/stain.svg"),
                  Positioned(
                    left: 50,
                    top: 120,
                    child: SvgPicture.asset("lib/assets/book.svg"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Let's complete your profile",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "It will help us to know more about you!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: GlobalText.grayPrimaryPoppinsTextStyle,
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  hint: const Text(
                    "Select Gender",
                    style: TextStyle(color: Colors.black12),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "male",
                      child: Text(
                        "Male",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "female",
                      child: Text(
                        "Female",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != _birthDate) {
                      setState(() {
                        _birthDate = picked;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.grey),
                      controller: TextEditingController(
                        text: _birthDate == null
                            ? ''
                            : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                      ),
                      decoration: InputDecoration(
                        labelText: "Birth Date",
                        hintText: "Select Your Birth Date",
                        hintStyle: const TextStyle(color: Colors.black26),
                        prefixIcon: const Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    gradient: GlobalColors.buttonGradient,
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_gender != null && _birthDate != null) {
                        register(
                          widget.firstName,
                          widget.lastName,
                          widget.email,
                          widget.password,
                          _gender!,
                          _birthDate!,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please select gender and birth date'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right_sharp,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register(String firstName, String lastName, String email,
      String password, String gender, DateTime birthDate) async {
    Uri apiUrl = Uri.parse('http://10.0.2.2:4000/register');

    // Konversi tanggal menjadi string tanpa waktu
    String birthDateString = birthDate.toIso8601String().substring(0, 10);

    // Konversi requestData menjadi JSON
    String jsonData = json.encode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'gender': gender,
      'birth_date': birthDateString,
    });

    try {
      final response = await http.post(
        apiUrl,
        body: jsonData,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Data sent successfully');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        debugPrint('Failed to send data: ${response.statusCode}');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginPage()),
        // );
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
  }
}
