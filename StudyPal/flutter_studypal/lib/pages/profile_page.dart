import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/auth/login_page.dart';
import 'package:flutter_studypal/pages/chat_screen.dart';
import 'package:flutter_studypal/pages/edit_profile.dart';
import 'package:flutter_studypal/pages/leaderboard_page.dart';
import 'package:intl/intl.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;

  String? token;

  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fungsi untuk mengambil email saat inisialisasi halaman
  }

  @override
  void dispose() {
    // Cancel or dispose of asynchronous operations here
    super.dispose();
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<void> _logout(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:4000/logout');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        await prefs.remove('email');
        await prefs.remove('token');

        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        throw Exception('Failed to logout');
      }
    } catch (error) {
      print('Error during logout: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout')),
      );
    }
  }

  Future<Map<String, dynamic>> getUserProfile(
      String email, String token) async {
    final apiUrl = Uri.parse('http://10.0.2.2:4000/profile/$email');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Konversi respons menjadi map JSON
        final Map<String, dynamic> userData = json.decode(response.body);
        return userData;
      } else {
        // Tangani kesalahan jika status kode bukan 200
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      // Tangani kesalahan jaringan
      throw Exception('Network error: $error');
    }
  }

  Future<void> fetchData() async {
    try {
      // Panggil fungsi untuk mengambil email dan token
      await _getEmailandToken();

      // Pastikan email dan token tidak null
      if (email != null && token != null && mounted) {
        // Check if the widget is mounted
        // Panggil getUserProfile dengan email dan token
        Map<String, dynamic> userProfileData =
            await getUserProfile(email!, token!);

        String birthDate = userProfileData['birth_date'] ?? '';
        DateTime birthDateTime = DateTime.parse(birthDate);
        String formattedBirthDate = DateFormat('dd MMM').format(birthDateTime);

        // Tambahkan birth_date yang sudah diformat ke userProfileData
        userProfileData['birth_date'] = formattedBirthDate;

        String userProfileDataString = jsonEncode(userProfileData);

        debugPrint(userProfileDataString);

        // Tetapkan hasil getUserProfile ke userProfile
        if (mounted) {
          // Check if the widget is mounted again before calling setState
          setState(() {
            userProfile = userProfileData;
          });
        }
      } else {
        // Tangani jika email atau token null
        throw Exception('Email or token is null');
      }
    } catch (error) {
      // Tangani kesalahan
      throw Exception('Error fetching user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchData();
          },
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 16, 17, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                // color: Colors.white, // Background color of the dropdown
                                icon: const Icon(
                                  Icons.menu,
                                  // color: Colors.black,
                                ),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 'menu1',
                                    child: Row(
                                      children: [
                                        Icon(Icons
                                            .person), // Tambahkan ikon di sebelah kiri teks
                                        SizedBox(
                                            width:
                                                10), // Beri jarak antara ikon dan teks
                                        Text('John Doe'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'menu2',
                                    child: Row(
                                      children: [
                                        Icon(Icons
                                            .logout_rounded), // Tambahkan ikon
                                        SizedBox(width: 10),
                                        Text('Sign Out'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(
                                      height: 1), // Garis pembatas
                                  const PopupMenuItem(
                                    value: 'menu3',
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings), // Ikon tambahan
                                        SizedBox(width: 10),
                                        Text('Settings'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'menu4',
                                    child: Row(
                                      children: [
                                        Icon(Icons.help), // Ikon tambahan
                                        SizedBox(width: 10),
                                        Text('Help'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  // Handle menu item selection here
                                  switch (value) {
                                    case 'menu1':
                                      // Tambahkan logika menu 1
                                      break;
                                    case 'menu2':
                                      // Tambahkan logika menu 2
                                      break;
                                    case 'menu3':
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsPage(), // Arahkan ke SettingsPage
                                        ),
                                      );
                                      break;
                                    case 'menu4':
                                      // Tambahkan logika menu 4
                                      break;
                                    // Add cases for more menu items as needed
                                  }
                                },
                              ),
                            ),
                            const Text(
                              "Profile",
                              style: TextStyle(
                                // color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                // color: Colors.white, // Background color of the dropdown
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  // color: Colors.black,
                                ),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 'notification1',
                                    child: Text('Notifications'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'notification2',
                                    child: Text('Challenges'),
                                  ),
                                  // Add more PopupMenuItems as needed
                                ],
                                onSelected: (value) {
                                  // Handle notification selection here
                                  switch (value) {
                                    case 'notification1':
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificationsPage()),
                                      );
                                      break;
                                    case 'notification2':
                                      // Navigator.push(
                                      // context,
                                      // MaterialPageRoute(builder: (context) => NotificationPage2()),
                                      // );
                                      break;
                                    // Add cases for more notifications as needed
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Ikon foto profil bulat
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: userProfile?['image'] != null
                                  ? NetworkImage(userProfile!['image'])
                                  : null,
                              child: userProfile?['image'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(
                                width: 16), // Jarak antara ikon dan teks
                            // Kolom untuk teks nama dan deskripsi
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // Teks rata kiri
                                children: [
                                  Text(
                                    userProfile?['fullName'] ??
                                        '', // Nama profil
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userProfile?['email'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35,
                                    vertical: 0,
                                  ),
                                  backgroundColor: themeProvider
                                      .primaryColor, // Warna latar belakang
                                  foregroundColor: Colors.white, // Warna teks
                                ),
                                child: SizedBox(
                                  width: 50,
                                  height: 40, // Atur lebar sesuai kebutuhan
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditProfilePage(), // Arahkan ke SettingsPage
                                          ));
                                    },
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        const SizedBox(
                            height: 32), // Jarak antara baris pertama dan kedua

                        // Baris kedua: Tiga kartu saling bersebelahan
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, // Sebar kartu secara merata
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70, // Atur tinggi kartu
                                child: _buildStatCard(
                                    '2024', 'Year joined'), // Kartu pertama
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 70, // Atur tinggi kartu
                                child: _buildStatCard(
                                    '48h 27m', 'Times used'), // Kartu kedua
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 70, // Atur tinggi kartu
                                child: _buildStatCard(
                                    userProfile?['birth_date'] ?? '',
                                    'Birthday'), // Kartu ketiga
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Tambahkan komponen AccountSection
                        const AccountSection(),

                        const SizedBox(height: 32),

                        // Tambahkan komponen NotificationSection
                        const NotificationSection(),

                        const SizedBox(height: 32),

                        // Tambahkan komponen OtherSection
                        const OtherSection(),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () {
                            // Aksi saat tombol logout ditekan
                            _logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat kartu stat di baris kedua
  Widget _buildStatCard(String title, String value) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Ujung bulat
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // Padding di seluruh sisi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Posisi teks
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Personal Data'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.stars),
                title: const Text('Ranking'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LeaderboardPage(), // Arahkan ke SettingsPage
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Activity History'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Study Progress'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Komponen NotificationSection
class NotificationSection extends StatefulWidget {
  const NotificationSection({super.key});

  @override
  _NotificationSectionState createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Pop-up Notification'),
            trailing: Switch(
              activeColor: themeProvider.primaryColor,
              value: _isNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  _isNotificationEnabled = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Komponen OtherSection
class OtherSection extends StatelessWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact Us'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Aksi saat item ditekan
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Aksi saat item ditekan
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Aksi saat item ditekan
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
