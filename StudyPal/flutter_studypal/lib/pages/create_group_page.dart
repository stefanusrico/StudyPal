import 'package:flutter/material.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
            title: Text(
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
              child: 
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Group Name'),
                ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: 
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to create a new group
              },
              child: Text(
                'Create Group',
                style: TextStyle( color: themeProvider.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
