import 'package:flutter/material.dart';
import 'global_group_detail_page.dart';
import 'create_group_page.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class GlobalGroupsPage extends StatelessWidget {
  final List<Map<String, String>> globalGroups = [
    {'name': 'Global Group 1', 'description': 'Description 1'},
    {'name': 'Global Group 2', 'description': 'Description 2'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Global Groups',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
      ),
      body: ListView.builder(
        itemCount: globalGroups.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.group, color: isDarkMode ? Colors.white : Colors.black),
                  title: Text(
                    globalGroups[index]['name']!,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  subtitle: Text(
                    globalGroups[index]['description']!,
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white70 : Colors.black54),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GlobalGroupDetailDialog(group: globalGroups[index]),
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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: themeProvider.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGroupPage(),
            ),
          );
        },
        child: Icon(Icons.group_add),
      ),
    );
  }
}
