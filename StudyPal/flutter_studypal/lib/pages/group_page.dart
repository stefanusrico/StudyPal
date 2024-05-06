import 'package:flutter/material.dart';
import 'settings_page.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}
class _GroupPageState extends State<GroupPage> {
  int selectedTile = 0;
  int currentPage = 1;
  int pageSize = 9;

  // Simulasikan daftar user dan status online/offline mereka
  final List<bool> onlineStatus = List.generate(20, (index) => index * 2 == 0); // Genap = online, ganjil = offline
  final List<String> data = List.generate(20, (index) => 'User $index');

  @override
  Widget build(BuildContext context) {
    final int totalItems = data.length;
    final int totalPages = (totalItems / pageSize).ceil();

    // Hitung jumlah pengguna yang online
    final int onlineCount = onlineStatus.where((status) => status).length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 174, 196, 250), // Warna awal
              Color.fromARGB(255, 115, 155, 255), // Warna akhir
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(17, 25, 17, 12),
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
                              color: Colors.white, // Background color of the dropdown
                              icon: Icon(
                                Icons.menu,
                                color: Colors.black,
                              ),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                PopupMenuItem(
                                  value: 'menu1',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person), // Tambahkan ikon di sebelah kiri teks
                                      SizedBox(width: 10), // Beri jarak antara ikon dan teks
                                      Text('John Doe'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'menu2',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout_rounded), // Tambahkan ikon
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
                                            builder: (context) => SettingsPage(), // Arahkan ke SettingsPage
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
                            "Group",
                            style: TextStyle(
                              color: Colors.white,
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
                            color: Colors.white, // Background color of the dropdown
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.black,
                            ),
                            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
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
                              switch(value) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0), // Kurangi jarak untuk lebih dekat dengan grid
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Studying ',
                          style: TextStyle(color: Colors.white), // Warna untuk teks "Studying"
                        ),
                        TextSpan(
                          text: '$onlineCount member${onlineCount > 1 ? "s" : ""}', // Tambahkan "s" jika lebih dari satu
                          style: TextStyle(
                            color: Color.fromARGB(255, 94, 108, 237) , // Warna untuk teks jumlah member
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0), // Padding untuk GridView
                    child: GridView.builder(
                      itemCount: pageSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final int itemIndex = (currentPage - 1) * pageSize + index;
                        if (itemIndex >= totalItems) {
                          return SizedBox.shrink();
                        }

                        bool isOnline = onlineStatus[itemIndex]; // Status online pengguna

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isOnline
                                  ? Color.fromARGB(255, 136, 146, 237)
                                  : Colors.transparent, 
                              width: isOnline ? 4 : 0,
                            ),
                          ),
                          color: isOnline
                              ? Color.fromARGB(255, 157, 158, 251)
                              : Colors.white, 
                          child: InkWell(
                            onTap: () {
                              // Aksi saat kartu ditekan
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 50,
                                  color: isOnline
                                      ? Colors.white
                                      : Color.fromARGB(255, 157, 158, 251),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  data[itemIndex],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isOnline
                                        ? Colors.white
                                        : Color.fromARGB(255, 157, 158, 251),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "00:00:00",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOnline ? Colors.white : Color.fromARGB(255, 157, 158, 251),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 18), // Ubah padding agar lebih rapi
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Ubah posisinya ke kanan
                    children: [
                      Text(
                        'Showing ${currentPage == totalPages ? totalItems - pageSize * (totalPages - 1) : pageSize} of $totalItems members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
                        onPressed: currentPage > 1
                            ? () {
                                setState(() {
                                  currentPage--; // Navigasi ke halaman sebelumnya
                                });
                              }
                            : null, // Jika halaman pertama, tombol dinonaktifkan
                      ),

                      // Tombol angka-angka halaman
                      for (int i = 1; i <= totalPages; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5), // Beri jarak antar tombol
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentPage = i; // Navigasi ke halaman tertentu
                              });
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all<Size>(
                                Size(40, 40), // Ukuran minimum agar tombol simetris
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                currentPage == i
                                    ? Color.fromARGB(255, 157, 158, 251) // Warna tombol saat halaman aktif
                                    : Colors.white, // Warna tombol saat halaman tidak aktif
                              ),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: currentPage == i 
                                        ? Color.fromARGB(255, 136, 146, 237) // Border jika halaman aktif
                                        : Colors.transparent,
                                    width: currentPage == i ? 4 : 0, // Ketebalan border
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              i.toString(), 
                              style: TextStyle(
                                color: currentPage == i 
                                    ? Colors.white 
                                    : Color.fromARGB(255, 157, 158, 251),
                              ),
                            ),
                          ),
                        ),

                      IconButton(
                        icon: Icon(Icons.chevron_right_rounded, color: Colors.white),
                        onPressed: currentPage < totalPages
                            ? () {
                                setState(() {
                                  currentPage++; // Navigasi ke halaman berikutnya
                                });
                              }
                            : null, // Jika halaman terakhir, tombol dinonaktifkan
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomDetailsSheet(), // Jika diperlukan, tetap tampilkan bagian bawah
          ],
        ),
      ),
    );
  }

  Widget bottomDetailsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: .63,
      minChildSize: .08,
      maxChildSize: .63,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 4, 10, 30),
                  child: Container(
                    width: 55,
                    height: 6,
                    color: Colors.grey[200],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 234, 240, 255),
                  ),
                  child: ListTile(
                    title: Text(
                      'Today target',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Add logic here
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 150, 180, 254)), 
                        minimumSize: MaterialStateProperty.all<Size>(Size(10, 30)), 
                      ),
                      child: Text(
                        'Check',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                  child: Card(
                    color: Color.fromARGB(255, 214, 225, 255),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 24, 0, 6),
                          child: Text(
                            "Group Stats",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Row pertama
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Atur jarak antar-kartu
                            children: [
                              buildCustomCard("02:10:47", "Time Total"), // Kartu pertama
                              buildCustomCard("00:20:43", "Max Focus"), // Kartu kedua
                            ],
                          ),
                        ),
                        SizedBox(height: 2), // Jarak antar-baris
                        // Row kedua
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Atur jarak antar-kartu
                            children: [
                              buildCustomCard("12h 20m", "Start Time"), // Kartu ketiga
                              buildCustomCard("14h 30m", "Finish Time"), // Kartu keempat
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(32, 15, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Group Chat',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCustomCard(String title, String subtitle) {
    return Container(
      // margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
      padding: EdgeInsets.symmetric(horizontal: 0),
      width: 140, // Ukuran lebar tetap untuk setiap kartu
      height: 80, // Ukuran tinggi tetap untuk setiap kartu
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Konten di tengah
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title, // Teks besar
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255,136,146,237),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle, // Teks kecil
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
