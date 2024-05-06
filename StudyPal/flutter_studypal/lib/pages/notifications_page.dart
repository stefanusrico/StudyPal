import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.circle,
      'title': 'New Message from John',
      'subtitle': '5 minutes ago',
    },
    {
      'icon': Icons.circle,
      'title': 'Meeting Reminder',
      'subtitle': '10 minutes ago',
    },
    {
      'icon': Icons.circle,
      'title': 'Project Deadline',
      'subtitle': '1 hour ago',
    },
    {
      'icon': Icons.circle,
      'title': 'App Update Available',
      'subtitle': '2 hours ago',
    },
    {
      'icon': Icons.circle,
      'title': 'Friend Request',
      'subtitle': '1 day ago',
    },
  ];

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(notification['icon'], size: 48, color: Color.fromARGB(255, 229, 200, 255)), // Ikon di sebelah kiri
            title: Text(
              notification['title'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Teks utama
            ),
            subtitle: Text(
              notification['subtitle'], // Teks tambahan
              style: TextStyle(fontSize: 14), // Ukuran teks lebih kecil
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert), // Tombol tiga titik di sebelah kanan
              onSelected: (value) {
                if (value == 'delete') {
                  deleteNotification(index); // Hapus notifikasi
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'), // Opsi untuk menghapus
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
