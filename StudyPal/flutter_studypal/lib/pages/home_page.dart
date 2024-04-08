import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class IconMenu {
  final IconData iconName;
  final String titleIcon;
  IconMenu({required this.iconName, required this.titleIcon});
}

List<IconMenu> iconList = [
  IconMenu(iconName: Icons.book, titleIcon: "Pomodoro"),
  IconMenu(iconName: Icons.lock_clock_outlined, titleIcon: "52/17"),
  IconMenu(iconName: Icons.bookmark, titleIcon: "50/10"),
  IconMenu(iconName: Icons.no_sim_outlined, titleIcon: "None"),
];

List<String> subjectList = [
  "Math",
  "English",
  "Science",
  "Economy",
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = -1;
  int selectedIndexSubject = -1;
  List<bool> switchValues = [false, false, false];
  String selectedSubject = '';

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('E, d MMM').format(now);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255,150,180,254),
        body: SafeArea(
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
                            // padding: EdgeInsets.all(16),
                            child: Icon(
                              Icons.menu,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.white),
                          ),
                          Container(
                            width: 45,
                            height: 45, 
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // padding: EdgeInsets.all(16),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Mengatur posisi teks di tengah
                    children: [
                      Expanded(
                        child: Text(
                          '00:00:00',
                          textAlign: TextAlign.center, // Mengatur teks menjadi rata tengah
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 55), // Memberikan padding 10.0 di atas dan 20.0 di bawah
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Break 20m 17s',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subject',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showEditSubjectDialog(context);
                        },
                        child: const Text(
                          'Edit Subject',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 10), // Tambahkan padding untuk memberikan jarak antar kartu
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndexSubject = position;
                          });
                        },
                        child: Container(
                          width: 90, // Atur lebar kartu menjadi lebih kecil
                          margin: EdgeInsets.symmetric(horizontal: 5), // Tambahkan margin horizontal untuk memberikan jarak antar kartu
                          child: Card(
                            color: (selectedIndexSubject == position) ? const Color.fromARGB(255,157,158,251) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: (selectedIndexSubject == position) ? const Color.fromARGB(255,136,146,237): Colors.transparent,
                                width: 4,
                              ),
                            ),
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  subjectList[position],
                                  style: TextStyle(
                                    color: (selectedIndexSubject == position) ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Method',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ),
                ),
                Container(
                  height: 110,
                  padding: const EdgeInsets.only(left: 10), // Tambahkan padding untuk memberikan jarak antar kartu
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: iconList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = position;
                          });
                        },
                        child: Container(
                          width: 90,
                          margin: EdgeInsets.symmetric(horizontal: 5), // Tambahkan margin horizontal untuk memberikan jarak antar kartu
                          child: Card(
                            color: (selectedIndex == position) ? const Color.fromARGB(255,157,158,251) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: (selectedIndex == position) ? const Color.fromARGB(255,136,146,237): Colors.transparent,
                                width: 4,
                              ),
                            ),
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Icon(iconList[position].iconName),
                                Text(
                                  iconList[position].titleIcon,
                                  style: TextStyle(
                                    color: (selectedIndex == position) ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configuration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ),
                ),
                Container(
                    height: 55,
                    padding: const EdgeInsets.only(left: 10), // Atur padding untuk memberikan jarak antar kartu
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildActionCard('Keep Screen On', 0), // Indeks 0 untuk switch pertama
                        buildActionCard('Hide Other Tabs', 1), // Indeks 1 untuk switch kedua
                        buildActionCard('Silent Mode', 2), // Indeks 2 untuk switch ketiga
                      ],
                    ),
                  ),
              ],
            ),
            bottomDetailsSheet(),
          ],
          ),
        ),
      ),
    );
  }
  
  Widget buildActionCard(String text, int index) { // Tambahkan parameter index untuk mengetahui switch mana yang diubah
    return Container(
      width: 200, // Atur lebar kartu
      margin: EdgeInsets.symmetric(horizontal: 5), // Atur margin horizontal untuk memberikan jarak antar kartu
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Switch.adaptive(
                value: switchValues[index], // Gunakan nilai switch sesuai dengan indeksnya
                onChanged: (bool newValue) {
                  setState(() {
                    switchValues[index] = newValue; // Perbarui nilai switch sesuai dengan nilai baru
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context) {
  String initialValue = selectedSubject.isNotEmpty ? selectedSubject : subjectList[0];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Subject'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedSubject.isNotEmpty ? selectedSubject : subjectList[0],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue ?? '';
                    });
                  },
                  items: subjectList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextField(
                  onChanged: (value) {
                    // Saat pengguna mengetik, perbarui nilai selectedSubject
                    selectedSubject = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'New Subject Name',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Perbarui nama subjek yang dipilih saat tombol "Done" ditekan
                  if (selectedSubject.isNotEmpty && !subjectList.contains(selectedSubject)) {
                    setState(() {
                      int selectedIndex = subjectList.indexOf(initialValue);
                      if (selectedIndex != -1) {
                        subjectList[selectedIndex] = selectedSubject;
                      }
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget bottomDetailsSheet() {
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
          child: SingleChildScrollView( // Menggunakan SingleChildScrollView sebagai ganti ListView
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
                    color: const Color.fromARGB(255,234,240,255),
                  ),
                  child: ListTile(
                    title: Text(
                      'Today target',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Add your navigation logic here
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255,150,180,254)), // Mengatur warna latar belakang tombol
                        minimumSize: MaterialStateProperty.all<Size>(Size(10, 30)), // Atur ukuran tombol
                      ),
                      child: Text(
                        'Check',
                        style: TextStyle(
                          color: Colors.white, // Mengatur warna teks menjadi putih
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(32, 15, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Based on your activity...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 80,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255,234,240,255),
                  ),
                  child: ListTile(
                    title: Text(
                      'Recommendation',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      'Pomodoro method', // Teks tambahan di bawah tombol
                      style: TextStyle(
                        color: Color.fromARGB(255,150,180,254),
                        fontSize: 20,
                        fontWeight: FontWeight.bold, // Atur teks menjadi sangat tebal
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // Kartu pertama (kiri)
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 5,
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            // Isi kartu pertama disini
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Dua kartu lainnya (kanan)
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Card(
                              elevation: 5,
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                // Isi kartu kedua disini
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              elevation: 5,
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                // Isi kartu ketiga disini
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(32, 15, 32, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Study',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Text(
                          'See more',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
