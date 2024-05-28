import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/leaderboard_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'calendar_page.dart';
import 'main_screen.dart';
import 'home_page.dart';
import 'insight_page.dart';
import 'group_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  "",
  "Math",
  "English",
  "Science",
  "Economy",
];

class HomePage extends StatefulWidget {
  final StopWatchTimer stopWatchTimer;
  final ValueNotifier<int> timerValueNotifier;
  final StreamController<int> timerStreamController;
  final bool isTimerRunning;
  final String selectedSubject;
  final String selectedMethod;
  final Function(String) updateSelectedSubject;
  final Function(String) updateSelectedMethod;
  final List<Map<String, dynamic>> latestStudyList;
  final Function(Map<String, dynamic>) onLatestStudyAdded;
  final ValueNotifier<int> accumulatedTimeNotifier;

  const HomePage(
      {super.key,
      required this.stopWatchTimer,
      required this.timerValueNotifier,
      required this.timerStreamController,
      required this.isTimerRunning,
      required this.selectedSubject,
      required this.selectedMethod,
      required this.updateSelectedSubject,
      required this.updateSelectedMethod,
      required this.latestStudyList,
      required this.onLatestStudyAdded,
      required this.accumulatedTimeNotifier});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = -1;
  int selectedIndexSubject = -1;
  List<bool> switchValues = [false, false, false];
  String selectedSubject = '';
  String selectedMethod = '';
  String latestSubject = '';
  String latestTime = '';
  String? email;
  String? token;
  Map<String, dynamic>? userProfile;
  final List<Map<String, dynamic>> _latestStudyList = [];
  int accumulatedTime = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    selectedSubject = widget.selectedSubject;
    selectedMethod = widget.selectedMethod;
  }

  String getSelectedSubject() {
    return selectedSubject;
  }

  String getSelectedMethod() {
    return selectedMethod;
  }

  void updateSelectedSubject(String subject) {
    setState(() {
      selectedSubject = subject;
    });
  }

  void updateSelectedMethod(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

  void addToLatestStudyList(Map<String, dynamic> data) {
    setState(() {
      _latestStudyList.add(data);
      widget.onLatestStudyAdded(data);
    });
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Set nilai email dari SharedPreferences ke variabel email
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<Map<String, dynamic>> getUserProfile(
      String email, String token) async {
    final apiUrl = Uri.parse('http://10.0.2.2:4000/profile/$email');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Konversi respons menjadi map JSON
        final Map<String, dynamic> userData = json.decode(response.body);
        return userData;
      } else {
        // Tangani kesalahan jika status kode bukan 200
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      // Tangani kesalahan jaringan
      throw Exception('Network error: $error');
    }
  }

  Future<void> fetchData() async {
    try {
      // Panggil fungsi untuk mengambil email dan token
      await _getEmailandToken();

      // Pastikan email dan token tidak null
      if (email != null && token != null) {
        // Panggil getUserProfile dengan email dan token
        Map<String, dynamic> userProfileData =
            await getUserProfile(email!, token!);

        // Tetapkan hasil getUserProfile ke userProfile
        setState(() {
          userProfile = userProfileData;
        });
      } else {
        // Tangani jika email atau token null
        throw Exception('Email or token is null');
      }
    } catch (error) {
      // Tangani kesalahan
      throw Exception('Error fetching user profile: $error');
    }
  }

  void updateSubject() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('E, d MMM').format(now);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
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
                      padding: const EdgeInsets.fromLTRB(17, 16, 17, 30),
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
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.black,
                                  ),
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    PopupMenuItem(
                                      value: 'menu1',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person),
                                          const SizedBox(width: 10),
                                          Text(userProfile?['fullName'] ?? ''),
                                        ],
                                      ),
                                      onTap: () {
                                        debugPrint(
                                            '${userProfile?['fullName'] ?? ''}');
                                        print('Menu1 tapped');
                                        print(
                                            'Calling navigateToProfilePage()');
                                        final mainScreenState = MainScreen
                                            .mainScreenKey.currentState;
                                        mainScreenState
                                            ?.navigateToProfilePage();
                                        print(mainScreenState);
                                      },
                                    ),
                                    PopupMenuItem(
                                      value: 'menu2',
                                      onTap: () {
                                        debugPrint(
                                            '${userProfile?['fullName'] ?? ''}');
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons
                                              .logout_rounded), // Tambahkan ikon
                                          SizedBox(width: 10),
                                          Text('Sign Out'),
                                        ],
                                      ),
                                    ),

                                    const PopupMenuDivider(
                                        height: 1), // Garis pembatas
                                    const PopupMenuItem(
                                      value: 'menu3',
                                      child: Row(
                                        children: [
                                          Icon(Icons.settings), // Ikon tambahan
                                          SizedBox(width: 10),
                                          Text('Settings'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
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
                                                const SettingsPage(), // Arahkan ke SettingsPage
                                          ),
                                        );
                                        break;
                                      case 'menu4':
                                        // Tambahkan logika menu 4
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LeaderboardPage(), // Arahkan ke SettingsPage
                                          ),
                                        );
                                        break;
                                      // Add cases for more menu items as needed
                                    }
                                  },
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white),
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
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.black,
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationsPage()),
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
                    StreamBuilder<int>(
                      stream: widget.timerStreamController.stream,
                      initialData: 0,
                      builder: (context, snapshot) {
                        final value = snapshot.data ?? 0;
                        final displayTime = StopWatchTimer.getDisplayTime(
                          value,
                          hours: true,
                        );
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // ValueListenableBuilder<int>(
                    //   valueListenable: widget.accumulatedTimeNotifier,
                    //   builder: (context, accumulatedTime, child) {
                    //     return Padding(
                    //       padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    //       child: Text(
                    //         'Accumulated Time: ${StopWatchTimer.getDisplayTime(accumulatedTime)}',
                    //         style: const TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0,
                          55), // Memberikan padding 10.0 di atas dan 20.0 di bawah
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
                              showEditSubjectDialog(context, updateSubject);
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
                      padding: const EdgeInsets.only(left: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subjectList
                            .length, // Sesuaikan itemCount ke panjang asli subjectList
                        itemBuilder: (BuildContext context, int position) {
                          // Lewati item pertama dengan mengakses indeks dari posisi + 1
                          if (position == subjectList.length - 1) {
                            return GestureDetector(
                              onTap: () {
                                showAddSubjectDialog(context);
                              },
                              child: Container(
                                width: 120,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Card(
                                  color: Colors.grey[
                                      100], // Warna latar belakang untuk kartu tambahan
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  elevation: 5,
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons
                                              .add_circle_outline, // Tampilkan ikon tambah
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                            width:
                                                3), // Jarak antara ikon dan teks
                                        Flexible(
                                          child: Text(
                                            'Add New Subject',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Tampilkan kartu subjek seperti biasa dengan indeks posisi + 1
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndexSubject = position + 1;
                                  widget.updateSelectedSubject(
                                      subjectList[position + 1]);
                                  debugPrint(
                                      'Selected Subject: ${subjectList[position + 1]}');
                                });
                              },
                              child: Container(
                                width: 90,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Card(
                                  color: (selectedIndexSubject == position + 1)
                                      ? const Color.fromARGB(255, 157, 158, 251)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color:
                                          (selectedIndexSubject == position + 1)
                                              ? const Color.fromARGB(
                                                  255, 136, 146, 237)
                                              : Colors.transparent,
                                      width: 4,
                                    ),
                                  ),
                                  elevation: 5,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        subjectList[position + 1],
                                        style: TextStyle(
                                          color: (selectedIndexSubject ==
                                                  position + 1)
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
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
                          ]),
                    ),
                    Container(
                      height: 110,
                      padding: const EdgeInsets.only(
                          left:
                              10), // Tambahkan padding untuk memberikan jarak antar kartu
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: iconList.length,
                        itemBuilder: (BuildContext context, int position) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = position;
                                widget.updateSelectedMethod(
                                    iconList[position].titleIcon);
                                debugPrint(
                                    'Selected Method: ${iconList[position].titleIcon}');
                              });
                            },
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.symmetric(
                                  horizontal:
                                      5), // Tambahkan margin horizontal untuk memberikan jarak antar kartu
                              child: Card(
                                color: (selectedIndex == position)
                                    ? const Color.fromARGB(255, 157, 158, 251)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: (selectedIndex == position)
                                        ? const Color.fromARGB(
                                            255, 136, 146, 237)
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                                elevation: 5,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Icon(iconList[position].iconName),
                                    Text(
                                      iconList[position].titleIcon,
                                      style: TextStyle(
                                        color: (selectedIndex == position)
                                            ? Colors.white
                                            : Colors.black,
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
                          ]),
                    ),
                    Container(
                      height: 55,
                      padding: const EdgeInsets.only(
                          left:
                              10), // Atur padding untuk memberikan jarak antar kartu
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          buildActionCard('Keep Screen On',
                              0), // Indeks 0 untuk switch pertama
                          buildActionCard('Hide Other Tabs',
                              1), // Indeks 1 untuk switch kedua
                          buildActionCard(
                              'Silent Mode', 2), // Indeks 2 untuk switch ketiga
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
      ),
    );
  }

  Widget buildActionCard(String text, int index) {
    // Tambahkan parameter index untuk mengetahui switch mana yang diubah
    return Container(
      width: 200, // Atur lebar kartu
      margin: const EdgeInsets.symmetric(
          horizontal:
              5), // Atur margin horizontal untuk memberikan jarak antar kartu
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Switch.adaptive(
                value: switchValues[
                    index], // Gunakan nilai switch sesuai dengan indeksnya
                onChanged: (bool newValue) {
                  setState(() {
                    switchValues[index] =
                        newValue; // Perbarui nilai switch sesuai dengan nilai baru
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditSubjectDialog(
      BuildContext context, VoidCallback onSubjectUpdated) {
    String initialValue =
        selectedSubject.isNotEmpty ? selectedSubject : subjectList[0];
    String newSubject = selectedSubject;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: initialValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubject = newValue ?? initialValue;
                        newSubject = selectedSubject;
                      });
                    },
                    items: subjectList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    onChanged: (value) {
                      newSubject = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'New Subject Name',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (newSubject.isNotEmpty &&
                        !subjectList.contains(newSubject)) {
                      int selectedIndex = subjectList.indexOf(selectedSubject);
                      if (selectedIndex != -1) {
                        setState(() {
                          subjectList[selectedIndex] = newSubject;
                        });
                      }
                      selectedSubject = newSubject;
                      onSubjectUpdated(); // Panggil callback
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void addNewSubject(String newSubject) {
    setState(() {
      subjectList.add(newSubject);
    });
  }

  void showAddSubjectDialog(BuildContext context) {
    String newSubject = ''; // Variabel untuk menyimpan nama subjek baru

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Subject'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    newSubject =
                        value; // Simpan nilai subjek baru saat pengguna mengetik
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'New Subject Name',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Panggil fungsi untuk menambahkan subjek baru
                    addNewSubject(newSubject);
                    Navigator.of(context)
                        .pop(); // Tutup dialog setelah menambahkan subjek baru
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Tutup dialog jika pengguna membatalkan tindakan
                  },
                  child: const Text('Cancel'),
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
          decoration: const BoxDecoration(
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
                    color: const Color.fromARGB(255, 234, 240, 255),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Today target',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarPage()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 150, 180,
                                254)), // Mengatur warna latar belakang tombol
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(10, 30)), // Atur ukuran tombol
                      ),
                      child: const Text(
                        'Check',
                        style: TextStyle(
                          color:
                              Colors.white, // Mengatur warna teks menjadi putih
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
                      ]),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 80,
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 234, 240, 255),
                  ),
                  child: const ListTile(
                    title: Text(
                      'Recommendation',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      'Pomodoro method', // Teks tambahan di bawah tombol
                      style: TextStyle(
                        color: Color.fromARGB(255, 150, 180, 254),
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold, // Atur teks menjadi sangat tebal
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Row(
                    children: [
                      // Kartu pertama (kiri)
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: 5,
                          child: SizedBox(
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
                              child: SizedBox(
                                width: double.infinity,
                                height: 140,
                                // Isi kartu kedua disini
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              elevation: 5,
                              child: SizedBox(
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
                  padding: const EdgeInsets.fromLTRB(32, 15, 32, 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Activity History',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'See more',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ]),
                ),
                if (_latestStudyList.isNotEmpty)
                  Column(
                    children: _latestStudyList.map((data) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.book,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data['subject'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['time'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
