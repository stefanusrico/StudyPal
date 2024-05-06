import 'package:flutter/material.dart';
import 'package:flutter_studypal/components/line_chart.dart';
import 'package:flutter_studypal/components/pie_chart.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({Key? key}) : super(key: key);

  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  int selectedTile = 0;
  String _selectedOption = 'Daily'; // Variabel untuk menyimpan pilihan

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.fromLTRB(17, 25, 17, 25),
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
                                      Icon(Icons
                                          .logout_rounded), // Tambahkan ikon
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
                          Spacer(),
                          Spacer(),
                          Spacer(),
                          Text(
                            'Activity Tracker',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: 95,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              icon: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    _selectedOption, // Tampilkan opsi yang dipilih
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(Icons.expand_more_rounded,
                                      color:
                                          Colors.black), // Ikon panah ke bawah
                                ],
                              ),
                              onSelected: (value) {
                                setState(() {
                                  _selectedOption =
                                      value; // Ubah pilihan saat opsi dipilih
                                });
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'Daily', // Nilai untuk opsi "daily"
                                  child: Text('Daily'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Weekly', // Nilai untuk opsi "weekly"
                                  child: Text('Weekly'),
                                ),
                                PopupMenuItem<String>(
                                  value:
                                      'Monthly', // Nilai untuk opsi "monthly"
                                  child: Text('Monthly'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                LineChartSample1(),
              ],
            ),
            bottomDetailsSheet(),
          ],
        ),
      ),
    );
  }

  Widget bottomDetailsSheet() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('E, d MMM').format(now);

    return DraggableScrollableSheet(
      initialChildSize: .63,
      minChildSize: .08,
      maxChildSize: .63,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView sebagai ganti ListView
            controller: scrollController,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10), // Beri sedikit jarak di bagian atas
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 4, 10,
                        30), // Atur padding dengan nilai berbeda untuk setiap sisi
                    child: Container(
                      width: 55, // Atur lebar kotak kecil
                      height: 6, // Atur tinggi kotak kecil
                      color: Colors.grey[200],
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
                            padding: EdgeInsets.fromLTRB(0, 24, 0, 10),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Row pertama
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Atur jarak antar-kartu
                              children: [
                                buildCustomCard(
                                    "02:10:47", "Time Total"), // Kartu pertama
                                buildCustomCard(
                                    "00:20:43", "Max Focus"), // Kartu kedua
                              ],
                            ),
                          ),
                          SizedBox(height: 2), // Jarak antar-baris
                          // Row kedua
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Atur jarak antar-kartu
                              children: [
                                buildCustomCard(
                                    "12h 20m", "Start Time"), // Kartu ketiga
                                buildCustomCard(
                                    "14h 30m", "Finish Time"), // Kartu keempat
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                    child: Card(
                      color: Color.fromARGB(255, 236, 240, 249),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          PieChartSample1(),
                        ],
                      ),
                    ),
                  ),
                ]),
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
                  color: Color.fromARGB(255, 136, 146, 237),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle, // Teks kecil
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
