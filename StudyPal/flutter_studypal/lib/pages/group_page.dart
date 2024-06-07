import 'package:flutter/material.dart';
import 'chat_screen.dart';
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


class GroupPage extends StatefulWidget {
  final Map<String, String> group;
  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int selectedTile = 0;
  int currentPage = 1;
  int pageSize = 9;

  // Simulasikan daftar user dan status online/offline mereka
  final List<bool> onlineStatus = List.generate(
      20, (index) => index * 2 == 0); // Genap = online, ganjil = offline
  final List<String> data = List.generate(20, (index) => 'User $index');

  @override
  Widget build(BuildContext context) {
    final int totalItems = data.length;
    final int totalPages = (totalItems / pageSize).ceil();

    // Hitung jumlah pengguna yang online
    final int onlineCount = onlineStatus.where((status) => status).length;
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.group['name']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            centerTitle: true,
            leadingWidth: 56,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Colors.black, Colors.black54]
                    : [darkenColor(themeProvider.primaryColor), lightenColor(themeProvider.primaryColor),],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0,
                          10), // Kurangi jarak untuk lebih dekat dengan grid
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Studying ',
                              style: TextStyle(
                                  color: Colors.white), // Warna untuk teks "Studying"
                            ),
                            TextSpan(
                              text:
                                  '$onlineCount member${onlineCount > 1 ? "s" : ""}', // Tambahkan "s" jika lebih dari satu
                              style: TextStyle(
                                color: darkenColor(darkenColor(themeProvider.primaryColor)), // Warna untuk teks jumlah member
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 0), // Padding untuk GridView
                        child: GridView.builder(
                          itemCount: pageSize,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            final int itemIndex =
                                (currentPage - 1) * pageSize + index;
                            if (itemIndex >= totalItems) {
                              return const SizedBox.shrink();
                            }
      
                            bool isOnline =
                                onlineStatus[itemIndex]; // Status online pengguna
      
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isOnline
                                      ? darkenColor(themeProvider.primaryColor)
                                      : isDarkMode 
                                        ? Colors.black
                                        : Color.fromARGB(0, 255, 255, 255),
                                  width: isOnline ? 4 : 0,
                                ),
                              ),
                              color: isOnline
                                  ? themeProvider.primaryColor
                                  : isDarkMode 
                                        ? Color.fromARGB(255, 23, 23, 23)
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
                                          : themeProvider.primaryColor,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data[itemIndex],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isOnline
                                            ? Colors.white
                                            : themeProvider.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "00:00:00",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOnline
                                            ? Colors.white
                                            : themeProvider.primaryColor,
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
                      padding: const EdgeInsets.fromLTRB(
                          0, 0, 20, 18), // Ubah padding agar lebih rapi
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Ubah posisinya ke kanan
                        children: [
                          Text(
                            'Showing ${currentPage == totalPages ? totalItems - pageSize * (totalPages - 1) : pageSize} of $totalItems members',
                            style: const TextStyle(
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
                            icon: const Icon(Icons.chevron_left_rounded,
                                color: Colors.white),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5), // Beri jarak antar tombol
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    currentPage =
                                        i; // Navigasi ke halaman tertentu
                                  });
                                },
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size(40,
                                        40), // Ukuran minimum agar tombol simetris
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    currentPage == i
                                        ? themeProvider.primaryColor // Warna tombol saat halaman aktif
                                        : isDarkMode 
                                            ? Color.fromARGB(255, 23, 23, 23)
                                            : Colors.white, // Warna tombol saat halaman tidak aktif
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: currentPage == i
                                            ? darkenColor(themeProvider.primaryColor)// Border jika halaman aktif
                                            : isDarkMode 
                                                ? Colors.black
                                                : Colors.white,
                                        width: currentPage == i
                                            ? 4
                                            : 0, // Ketebalan border
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  i.toString(),
                                  style: TextStyle(
                                    color: currentPage == i
                                        ? Colors.white
                                        : themeProvider.primaryColor,
                                  ),
                                ),
                              ),
                            ),
      
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded,
                                color: Colors.white),
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
        ),
      ),
    );
  }

  Widget bottomDetailsSheet() {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return DraggableScrollableSheet(
      initialChildSize: .63,
      minChildSize: .08,
      maxChildSize: .70,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: isDarkMode 
          ? BoxDecoration(
            color: Color.fromARGB(255, 25, 25, 25),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          )

          : BoxDecoration(
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 30),
                  child: Container(
                    width: 55,
                    height: 6,
                    color: const Color.fromARGB(255, 189, 188, 188),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: lightenColor(themeProvider.primaryColor),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Today target',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Add logic here
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            darkenColor(themeProvider.primaryColor)),
                        minimumSize:
                            MaterialStateProperty.all<Size>(const Size(10, 30)),
                      ),
                      child: const Text(
                        'Check',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                  child: Card(
                    color: lightenColor(themeProvider.primaryColor),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Padding(
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
                        const SizedBox(height: 2), // Jarak antar-baris
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(32, 15, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Group Chat',
                        style: TextStyle(
                          // color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                  child: Card(
                    color: lightenColor(themeProvider.primaryColor),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "User 1",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                        ? Color.fromARGB(255, 41, 41, 41)
                                        : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "we r goin to c the lions",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode 
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ChatPage()),
                                );
                              },
                              
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkenColor(themeProvider.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Open',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      width: 140, // Ukuran lebar tetap untuk setiap kartu
      height: 80, // Ukuran tinggi tetap untuk setiap kartu
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Konten di tengah
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title, // Teks besar
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 136, 146, 237),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle, // Teks kecil
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
