import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_studypal/models/groups.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global_groups_page.dart';
import 'group_page.dart';
import 'settings_page.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

Color lightenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

Color darkenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class JoinedGroupsPage extends StatefulWidget {
  const JoinedGroupsPage({super.key});

  @override
  _JoinedGroupsPageState createState() => _JoinedGroupsPageState();
}

class _JoinedGroupsPageState extends State<JoinedGroupsPage> {
  late Future<List<Group>> _joinedGroupsFuture;
  String? email;
  String? token;

  @override
  void initState() {
    super.initState();
    _getEmailandToken().then((_) {
      setState(() {
        _joinedGroupsFuture = fetchJoinedGroups(email!);
      });
    });
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      token = prefs.getString('token') ?? '';
    });
  }

  Future<List<Group>> fetchJoinedGroups(String email) async {
    if (email.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/groups/joined/$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch joined groups');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            child: Stack(
              children: [
                Column(
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
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PopupMenuButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  icon: const Icon(Icons.menu),
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    const PopupMenuItem(
                                      value: 'menu1',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person),
                                          SizedBox(width: 10),
                                          Text('John Doe'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'menu2',
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout_rounded),
                                          SizedBox(width: 10),
                                          Text('Sign Out'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(height: 1),
                                    const PopupMenuItem(
                                      value: 'menu3',
                                      child: Row(
                                        children: [
                                          Icon(Icons.settings),
                                          SizedBox(width: 10),
                                          Text('Settings'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'menu4',
                                      child: Row(
                                        children: [
                                          Icon(Icons.help),
                                          SizedBox(width: 10),
                                          Text('Help'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'menu1':
                                        // Add logic for menu 1
                                        break;
                                      case 'menu2':
                                        // Add logic for menu 2
                                        break;
                                      case 'menu3':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SettingsPage(),
                                          ),
                                        );
                                        break;
                                      case 'menu4':
                                        // Add logic for menu 4
                                        break;
                                    }
                                  },
                                ),
                              ),
                              const Text(
                                'Joined Groups',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PopupMenuButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  icon:
                                      const Icon(Icons.notifications_outlined),
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
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'notification1':
                                        break;
                                      case 'notification2':
                                        break;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _joinedGroupsFuture = fetchJoinedGroups(email!);
                          });
                        },
                        child: FutureBuilder<List<Group>>(
                          future: _joinedGroupsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Failed to fetch joined groups'));
                            } else {
                              final joinedGroups = snapshot.data!;
                              return ListView.builder(
                                itemCount: joinedGroups.length,
                                itemBuilder: (context, index) {
                                  final group = joinedGroups[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: Column(
                                      children: [
                                        ListTile(
                                            leading: Icon(Icons.group,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                            title: Text(
                                              group.name,
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                            subtitle: Text(
                                              group.description,
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54),
                                            ),
                                            trailing: Icon(
                                                Icons.arrow_forward_ios,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      GroupPage(
                                                    group: joinedGroups[index],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: themeProvider.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GlobalGroupsPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
