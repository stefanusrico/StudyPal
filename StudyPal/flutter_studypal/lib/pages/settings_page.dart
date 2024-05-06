import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
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
                            value: _isDark,
                            onChanged: (value) {
                              setState(() {
                                _isDark = value;
                              });
                            })),
                    const _CustomListTile(
                        title: "Notifications",
                        icon: Icons.notifications_none_rounded),
                    const _CustomListTile(
                        title: "Security Status",
                        icon: CupertinoIcons.lock_shield),
                  ],
                ),
                const SizedBox(height: 16.0), // Beri ruang antara bagian
                const _CardSection(
                  title: "Organization",
                  children: [
                    _CustomListTile(
                        title: "Profile", icon: Icons.person_outline_rounded),
                    _CustomListTile(
                        title: "Messaging", icon: Icons.message_outlined),
                    _CustomListTile(
                        title: "Calling", icon: Icons.phone_outlined),
                    _CustomListTile(
                        title: "People", icon: Icons.contacts_outlined),
                    _CustomListTile(
                        title: "Calendar", icon: Icons.calendar_today_rounded),
                  ],
                ),
                const SizedBox(height: 16.0), // Beri ruang antara bagian
                const _CardSection(
                  children: [
                    _CustomListTile(
                        title: "Help & Feedback",
                        icon: Icons.help_outline_rounded),
                    _CustomListTile(
                        title: "About", icon: Icons.info_outline_rounded),
                    _CustomListTile(
                        title: "Sign out", icon: Icons.exit_to_app_rounded),
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
      color: Colors.white,
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
