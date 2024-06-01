import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _showThemeDialog(BuildContext context) {
    var theme = Provider.of<ThemeModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Theme Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Toggle Dark Mode:'),
              Switch(
                value: theme.isDarkMode,
                onChanged: (value) {
                  theme.toggleDarkMode(value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    var theme = Provider.of<ThemeModel>(context, listen: false);
    Color pickerColor = theme.primaryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Primary Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Select'),
              onPressed: () {
                theme.updatePrimaryColor(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;
    var theme = Provider.of<ThemeModel>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(16.0), // Tambahkan padding pada ListView
              children: [
                _CardSection(
                  title: "General",
                  children: [
                    _CustomListTile(
                      title: "Dark Mode",
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch(
                        activeColor: themeProvider.primaryColor,
                        value: theme.isDarkMode,
                        onChanged: (value) {
                          theme.toggleDarkMode(value);
                        },
                      ),
                    ),
                    _CustomListTile(
                      title: "Theme Color",
                      icon: Icons.color_lens_outlined,
                      trailing: GestureDetector(
                        onTap: () {
                          _showColorPickerDialog(context);
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const _CustomListTile(
                      title: "Notifications",
                      icon: Icons.notifications_none_rounded,
                    ),
                     _CustomListTile(
                      title: "Security Status",
                      icon: Icons.lock,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0), // Beri ruang antara bagian
                const _CardSection(
                  title: "Organization",
                  children: [
                    _CustomListTile(
                      title: "Profile",
                      icon: Icons.person_outline_rounded,
                    ),
                    _CustomListTile(
                      title: "Messaging",
                      icon: Icons.message_outlined,
                    ),
                    _CustomListTile(
                      title: "Calling",
                      icon: Icons.phone_outlined,
                    ),
                    _CustomListTile(
                      title: "People",
                      icon: Icons.contacts_outlined,
                    ),
                    _CustomListTile(
                      title: "Calendar",
                      icon: Icons.calendar_today_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0), // Beri ruang antara bagian
                const _CardSection(
                  children: [
                    _CustomListTile(
                      title: "Help & Feedback",
                      icon: Icons.help_outline_rounded,
                    ),
                    _CustomListTile(
                      title: "About",
                      icon: Icons.info_outline_rounded,
                    ),
                    _CustomListTile(
                      title: "Sign out",
                      icon: Icons.exit_to_app_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CardSection akan membungkus bagian dalam card
class _CardSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _CardSection({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.white,
      elevation: 4, // Untuk efek bayangan
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Jarak antar-card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Card dengan ujung bundar
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Ruang dalam card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0), // Jarak untuk judul
                child: Text(
                  title!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            Column(
              children: children, // Elemen bagian
            ),
          ],
        ),
      ),
    );
  }
}

// CustomListTile tetap sama
class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const _CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: () {}, // Tindakan pada saat ditekan
    );
  }
}
