import 'package:flutter/material.dart';
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

// Fungsi untuk menggelapkan warna
Color darkenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class JoinedGroupsPage extends StatelessWidget {
  final List<Map<String, String>> joinedGroups = [
    {'name': 'Group 1', 'description': 'Description 1'},
    {'name': 'Group 2', 'description': 'Description 2'},
  ];

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
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: isDarkMode
            //         ? [Colors.black, Colors.black54]
            //         : [
            //             darkenColor(themeProvider.primaryColor),
            //             lightenColor(themeProvider.primaryColor),
            //           ],
            //   ),
            // ),
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
                                  color: isDarkMode ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PopupMenuButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  icon: const Icon(
                                    Icons.menu,
                                  ),
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
                                                const SettingsPage(),
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
                                'Joined Groups',
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                  ? Colors.black
                                  : Colors.white,
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
                                        // Navigator.push(
                                        // context,
                                        // MaterialPageRoute(builder: (context) => NotificationPage1()),
                                        // );
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
                          const SizedBox(height: 16),
                          Expanded(
  child: ListView.builder(
    itemCount: joinedGroups.length,
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
                joinedGroups[index]['name']!,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              subtitle: Text(
                joinedGroups[index]['description']!,
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white70 : Colors.black54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupPage(group: joinedGroups[index]),
                  ),
                );
              },
            ),
            // const Divider(
            //   thickness: 1,
            //   color: Colors.grey,
            // ),
          ],
        ),
      );
    },
  ),
)

                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: themeProvider.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GlobalGroupsPage(),
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
