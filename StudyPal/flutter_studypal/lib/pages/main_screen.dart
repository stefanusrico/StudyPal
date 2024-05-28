import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_studypal/components/nav_model.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'insight_page.dart';
import 'group_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<_MainScreenState> mainScreenKey =
      GlobalKey<_MainScreenState>();
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> homeNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> insightNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> groupNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> profileNavKey = GlobalKey<NavigatorState>();

  final StreamController<int> _timerStreamController =
      StreamController<int>.broadcast();
  final ValueNotifier<int> _timerValueNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _accumulatedTimeNotifier = ValueNotifier<int>(0);

  int selectedTab = 0;
  List<NavModel> items = [];
  final List<Map<String, dynamic>> _latestStudyList = [];

  bool timerStarted = false;
  bool timerRunning = false;
  bool isTimerRunning = false;
  String? email;
  String? token;
  int stoppedTimerValue = 0;
  String selectedSubject = '';
  String selectedMethod = '';
  String latestSubject = '';
  String latestTime = '';
  int accumulatedTime = 0;

  // StopWatchTimer instance
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) {
      print('Timer Value: $value');
    },
  );

  void navigateToProfilePage() {
    print('Navigating to ProfilePage');
    setState(() {
      selectedTab = 3;
      print('Selected tab updated to $selectedTab');
      items[selectedTab]
          .navKey
          .currentState
          ?.popUntil((route) => route.isFirst);
      print('Navigation completed');
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

  Future<void> sendAccumulatedTime(int accumulatedTime) async {
    final url =
        Uri.parse('http://10.0.2.2:4000/users/$email/send-accumulated-time');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'accumulatedTime': accumulatedTime,
        }),
      );

      if (response.statusCode == 200) {
        print('Accumulated time sent successfully');
      } else {
        print(
            'Failed to send accumulated time. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending accumulated time: $e');
    }
  }

  Future<void> _sendAccumulatedTime() async {
    await _getEmailandToken();
    sendAccumulatedTime(accumulatedTime);
  }

  void _handleLatestStudyAdded(Map<String, dynamic> data) {
    setState(() {
      _latestStudyList.add(data);
    });
  }

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(
        page: HomePage(
          stopWatchTimer: _stopWatchTimer,
          timerValueNotifier: _timerValueNotifier,
          timerStreamController: _timerStreamController,
          isTimerRunning: isTimerRunning,
          selectedSubject: selectedSubject,
          selectedMethod: selectedMethod,
          updateSelectedSubject: updateSelectedSubject,
          updateSelectedMethod: updateSelectedMethod,
          latestStudyList: _latestStudyList,
          onLatestStudyAdded: _handleLatestStudyAdded,
          accumulatedTimeNotifier:
              _accumulatedTimeNotifier, // Tambahkan parameter ini
        ),
        navKey: homeNavKey,
      ),
      NavModel(
        page: const InsightPage(),
        navKey: insightNavKey,
      ),
      NavModel(
        page: const GroupPage(),
        navKey: groupNavKey,
      ),
      NavModel(
        page: const ProfilePage(),
        navKey: profileNavKey,
      ),
    ];
  }

  void updateSelectedSubject(String subject) {
    setState(() {
      selectedSubject = subject;
      debugPrint('Selected Subject: $subject');
    });
  }

  void updateSelectedMethod(String method) {
    setState(() {
      selectedMethod = method;
      debugPrint('Selected Method: $method');
    });
  }

  @override
  void dispose() {
    _timerStreamController.close();
    super.dispose();
  }

  List<SpeedDialChild> _getSpeedDialChildren() {
    if (timerStarted && timerRunning) {
      return [
        SpeedDialChild(
          child: const Icon(Icons.pause,
              color: Color.fromARGB(255, 204, 157, 255)),
          label: 'Pause',
          onTap: () {
            _stopWatchTimer.onStopTimer();
            _timerValueNotifier.value = _stopWatchTimer.rawTime.value;
            _timerStreamController.add(_stopWatchTimer.rawTime.value);
            setState(() {
              timerRunning = false;
              isTimerRunning = false;
              accumulatedTime += _stopWatchTimer
                  .rawTime.value; // Tambahkan waktu saat ini ke accumulatedTime
              _accumulatedTimeNotifier.value = accumulatedTime;
              debugPrint('Adding data to latestStudyList');
              debugPrint('Subject: $selectedSubject');
            });
            _sendAccumulatedTime();
            // (items[selectedTab].page as HomePage).addToLatestStudyList(
            //   {
            //     'subject': selectedSubject,
            //     'time': 'Paused ${DateTime.now().toString().substring(0, 16)}',
            //   },
            // );
          },
        ),
      ];
    } else if (timerStarted && !timerRunning) {
      return [
        SpeedDialChild(
          child: const Icon(Icons.play_arrow_rounded,
              color: Color.fromARGB(255, 236, 130, 248)),
          label: 'Resume',
          onTap: () {
            _stopWatchTimer.onStartTimer();
            _stopWatchTimer.rawTime.listen((value) {
              _timerStreamController.add(value);
            });
            setState(() {
              timerRunning = true;
              isTimerRunning = true;
            });
          },
        ),
        SpeedDialChild(
          child:
              const Icon(Icons.stop, color: Color.fromARGB(255, 146, 54, 244)),
          label: 'Stop',
          onTap: () {
            _timerValueNotifier.value = _stopWatchTimer.rawTime.value;
            _timerStreamController.add(_stopWatchTimer.rawTime.value);
            _stopWatchTimer.onResetTimer();
            setState(() {
              timerStarted = false;
              isTimerRunning = false;
            });
          },
        ),
      ];
    } else {
      if (selectedSubject.isEmpty || selectedMethod.isEmpty) {
        return [
          SpeedDialChild(
            child: const Icon(Icons.timer,
                color: Color.fromARGB(255, 196, 141, 255)),
            label: 'Select Subject and Method',
            onTap: () {
              // Tampilkan pesan atau lakukan tindakan lain
              print(
                  'Please select a subject and method before starting the timer.');
            },
          ),
        ];
      } else {
        return [
          SpeedDialChild(
            child: const Icon(Icons.timer,
                color: Color.fromARGB(255, 196, 141, 255)),
            label: 'Timer start',
            onTap: () {
              _stopWatchTimer.onStartTimer();
              _stopWatchTimer.rawTime.listen((value) {
                _timerStreamController.add(value);
              });
              setState(() {
                timerStarted = true;
                timerRunning = true;
                isTimerRunning = true;
                debugPrint('Clearing latestStudyList');
                for (var data in _latestStudyList) {
                  debugPrint(
                      'Subject: ${data['subject']}, Time: ${data['time']}');
                }
                // latestStudyList.clear();
              });
            },
          ),
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Current selectedTab: $selectedTab');
    return WillPopScope(
      onWillPop: () {
        if (items[selectedTab].navKey.currentState?.canPop() ?? false) {
          items[selectedTab].navKey.currentState?.pop();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        key: MainScreen.mainScreenKey,
        body: IndexedStack(
          index: selectedTab,
          children: items.map((page) {
            return Navigator(
              key: page.navKey,
              onGenerateInitialRoutes: (navigator, initialRoute) {
                return [
                  MaterialPageRoute(
                    builder: (context) => page.page,
                  ),
                ];
              },
            );
          }).toList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SpeedDial(
          icon: timerStarted
              ? (timerRunning ? Icons.pause : Icons.play_arrow_rounded)
              : Icons.timer_outlined,
          activeIcon: Icons.close,
          foregroundColor: Colors.white,
          backgroundColor: timerStarted
              ? (timerRunning
                  ? const Color.fromARGB(255, 186, 188, 252)
                  : const Color.fromARGB(255, 145, 112, 255))
              : const Color.fromARGB(255, 192, 193, 255),
          overlayOpacity: 0.5, // Transparansi overlay saat SpeedDial aktif
          children: _getSpeedDialChildren(),
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: const [
            Icons.home_outlined,
            Icons.insert_chart_outlined_rounded,
            Icons.group_outlined,
            Icons.person_outline,
          ],
          activeIndex: selectedTab,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            if (index == selectedTab) {
              items[index]
                  .navKey
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                selectedTab = index;
              });
            }
          },
          activeColor: const Color.fromARGB(255, 150, 180, 254),
          inactiveColor: Colors.grey,
        ),
      ),
    );
  }
}
