import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global_group_detail_page.dart';
import 'create_group_page.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_studypal/models/groups.dart';

class GlobalGroupsPage extends StatefulWidget {
  const GlobalGroupsPage({super.key});

  @override
  _GlobalGroupsPageState createState() => _GlobalGroupsPageState();
}

class _GlobalGroupsPageState extends State<GlobalGroupsPage> {
  List<Group> groups = [];
  String? email;
  String? token;

  @override
  void initState() {
    super.initState();
    _getEmailandToken().then((_) {
      fetchGroups();
    });
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<void> fetchGroups() async {
    final apiUrl = Uri.parse('http://10.0.2.2:4000/groups/$email');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final validGroups = data.where((item) =>
            item['groupname'] != null &&
            item['initiatedBy'] != null &&
            item['participantIds'] != null);

        setState(() {
          groups = validGroups.map((item) => Group.fromJson(item)).toList();
        });
      } else {
        throw Exception(
            'Failed to fetch groups. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching groups: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Global Groups',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
      ),
      body: RefreshIndicator(
        onRefresh: fetchGroups, // Pass the function reference here
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final participantIds = group.participantIds != null
                ? List<String>.from(group.participantIds)
                : [];
            final maxParticipants = group.maxParticipants ?? 0;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.group,
                        color: isDarkMode ? Colors.white : Colors.black),
                    title: Text(
                      group.name,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Member ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${participantIds.length}/$maxParticipants person',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GlobalGroupDetailDialog(group: group),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
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
              builder: (context) => const CreateGroupPage(),
            ),
          );
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
