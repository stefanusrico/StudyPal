import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'notifications_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [
          //       Color.fromARGB(255, 174, 196, 250), // Warna awal
          //       Color.fromARGB(255, 115, 155, 255), // Warna akhir
          //     ],
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(17, 16, 17, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors
                                .white, // Background color of the dropdown
                            icon: Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              PopupMenuItem(
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
                              PopupMenuItem(
                                value: 'menu2',
                                child: Row(
                                  children: [
                                    Icon(
                                        Icons.logout_rounded), // Tambahkan ikon
                                    SizedBox(width: 10),
                                    Text('Sign Out'),
                                  ],
                                ),
                              ),
                              PopupMenuDivider(height: 1), // Garis pembatas
                              PopupMenuItem(
                                value: 'menu3',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings), // Ikon tambahan
                                    SizedBox(width: 10),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
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
                                          SettingsPage(), // Arahkan ke SettingsPage
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
                        Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PopupMenuButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors
                                .white, // Background color of the dropdown
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.black,
                            ),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              PopupMenuItem(
                                child: Text('Notifications'),
                                value: 'notification1',
                              ),
                              PopupMenuItem(
                                child: Text('Challenges'),
                                value: 'notification2',
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
                                            NotificationsPage()),
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
                    // Baris pertama: Profil dengan ikon, nama, dan tombol edit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ikon foto profil bulat
                        CircleAvatar(
                          radius: 30, // Ukuran ikon
                          // backgroundImage: AssetImage('assets/profile_picture.jpg'), // Contoh gambar
                        ),
                        SizedBox(width: 16), // Jarak antara ikon dan teks
                        // Kolom untuk teks nama dan deskripsi
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Teks rata kiri
                            children: [
                              Text(
                                'John Doe', // Nama profil
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'john@example.com', // Deskripsi pekerjaan
                                style: TextStyle(
                                  color: Colors.grey, // Warna abu-abu
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tombol Edit dengan border circle
                        ElevatedButton(
                          onPressed: () {
                            // Aksi saat tombol Edit ditekan
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Sudut melengkung
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 0,
                            ), // Padding untuk tombol
                            backgroundColor: Color.fromARGB(
                                255, 166, 172, 254), // Warna latar belakang
                            foregroundColor: Colors.white, // Warna teks
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 32), // Jarak antara baris pertama dan kedua

                    // Baris kedua: Tiga kartu saling bersebelahan
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Sebar kartu secara merata
                      children: [
                        Expanded(
                          child: Container(
                            height: 70, // Atur tinggi kartu
                            child: _buildStatCard(
                                '2024', 'Year joined'), // Kartu pertama
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 70, // Atur tinggi kartu
                            child: _buildStatCard(
                                '48h 27m', 'Times used'), // Kartu kedua
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 70, // Atur tinggi kartu
                            child: _buildStatCard(
                                '24 Jan', 'Birthday'), // Kartu ketiga
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32), // Jarak antara baris kedua dan ketiga

                    // Baris ketiga: Kartu berisi pengaturan profil
                    Card(
                      elevation: 2, // Bayangan di seluruh tepi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Ujung bulat
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                                Icons.account_circle), // Ikon pengaturan akun
                            title: Text('Account Settings'), // Teks utama
                            trailing:
                                Icon(Icons.arrow_forward_ios), // Tombol panah
                            onTap: () {
                              // Aksi saat item ditekan
                            },
                          ),
                          Divider(), // Garis pemisah
                          ListTile(
                            leading: Icon(Icons.security), // Ikon keamanan
                            title: Text('Security'), // Teks keamanan
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Aksi saat item keamanan ditekan
                            },
                          ),
                          Divider(),
                          ListTile(
                            leading:
                                Icon(Icons.notifications), // Ikon notifikasi
                            title: Text('Notifications'), // Teks notifikasi
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Aksi saat item notifikasi ditekan
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat kartu stat di baris kedua
  Widget _buildStatCard(String title, String value) {
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
                color: Color.fromARGB(255, 180, 152, 255), // Warna biru
              ),
            ),
            SizedBox(height: 2), // Jarak antara teks atas dan bawah
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey, // Warna abu-abu
              ),
            ),
          ],
        ),
      ),
    );
  }
}
