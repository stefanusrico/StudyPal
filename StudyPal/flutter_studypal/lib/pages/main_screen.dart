import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
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
import 'joined_groups_page.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static _MainScreenState? get currentState {
    return _MainScreenState();
  }

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<_MainScreenState> mainScreenKey =
      GlobalKey<_MainScreenState>();
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
  int pausedAccumulatedTime = 0;

  DateTime? startTime;
  DateTime? finishTime;

  Map<String, int> dailyAccumulatedTime = {};

  // StopWatchTimer instance
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) {
      print('Timer Value: $value');
    },
  );

  void printDailyAccumulatedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String key =
        '$email:$currentDate'; // Buat kunci unik untuk user saat ini dan tanggal
    int currentDailyAccumulatedTime = prefs.getInt(key) ?? 0;
    print(currentDailyAccumulatedTime);
    String formattedTime = formatDuration(currentDailyAccumulatedTime);
    print('Daily Accumulated Time for $email on $currentDate: $formattedTime');
  }

  String formatDuration(int accumulatedTime) {
    final duration = Duration(seconds: accumulatedTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<int> sendDailyAccumulatedTime(
      int accumulatedTime, DateTime startTime, DateTime finishTime) async {
    final url =
        Uri.parse('http://10.0.2.2:4000/users/$email/daily-accumulated-time');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'accumulatedTime': accumulatedTime,
          'startTime': startTime.toIso8601String(),
          'finishTime': finishTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('Accumulated time sent successfully');
        return accumulatedTime;
      } else {
        print(
            'Failed to send accumulated time. Status code: ${response.statusCode}');
        return 0; // Return a default value in case of failure
      }
    } catch (e) {
      print('Error sending accumulated time: $e');
      return 0; // Return a default value in case of an exception
    }
  }

  Future<int> sendWeeklyAccumulatedTime(
      int accumulatedTime, String week) async {
    final url =
        Uri.parse('http://10.0.2.2:4000/users/$email/weekly-accumulated-time');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'accumulatedTime': accumulatedTime,
          'week': week,
        }),
      );

      if (response.statusCode == 200) {
        print('Weekly accumulated time sent successfully');
        return accumulatedTime;
      } else {
        print(
            'Failed to send weekly accumulated time. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error sending weekly accumulated time: $e');
      return 0;
    }
  }

  Future<int> sendMonthlyAccumulatedTime(
      int accumulatedTime, String month) async {
    final url =
        Uri.parse('http://10.0.2.2:4000/users/$email/monthly-accumulated-time');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'accumulatedTime': accumulatedTime,
          'month': month,
        }),
      );

      if (response.statusCode == 200) {
        print('Monthly accumulated time sent successfully');
        return accumulatedTime;
      } else {
        print(
            'Failed to send monthly accumulated time. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error sending monthly accumulated time: $e');
      return 0;
    }
  }

  String getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();
    return '${date.year}-${weekOfYear.toString().padLeft(2, '0')}';
  }

  Future<void> _sendAccumulatedTime(int sendDurationInSeconds) async {
    await _getEmailandToken();
    int sentAccumulatedTime = await sendDailyAccumulatedTime(
        sendDurationInSeconds, startTime ?? DateTime.now(), DateTime.now());

    if (sentAccumulatedTime > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String dailyKey = '$email:$currentDate';

      int currentDailyAccumulatedTime = prefs.getInt(dailyKey) ?? 0;

      currentDailyAccumulatedTime += sentAccumulatedTime;

      await prefs.setInt(dailyKey, currentDailyAccumulatedTime);
    }
    printDailyAccumulatedTime();
  }

  void _handleLatestStudyAdded(Map<String, dynamic> data) {
    setState(() {
      _latestStudyList.add(data);
    });
  }

  @override
  void initState() {
    super.initState();
    _getEmailandToken().then((_) {
      SharedPreferences.getInstance().then((prefs) {
        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String key =
            '$email:$currentDate'; // Buat kunci unik untuk user saat ini dan tanggal
        int currentDailyAccumulatedTime = prefs.getInt(key) ?? 0;
        setState(() {
          accumulatedTime = currentDailyAccumulatedTime;
        });
      });
    });
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
          accumulatedTimeNotifier: _accumulatedTimeNotifier,
        ),
        navKey: homeNavKey,
      ),
      NavModel(
        page: const InsightPage(),
        navKey: insightNavKey,
      ),
      NavModel(
        page: const JoinedGroupsPage(),
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
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;
    if (timerStarted && timerRunning) {
      return [
        SpeedDialChild(
          child: Icon(Icons.pause, color: themeProvider.primaryColor),
          label: 'Pause',
          onTap: () {
            _stopWatchTimer.onStopTimer();
            _timerValueNotifier.value = _stopWatchTimer.rawTime.value;
            _timerStreamController.add(_stopWatchTimer.rawTime.value);

            int durationInMillis =
                _stopWatchTimer.rawTime.value - pausedAccumulatedTime;
            int durationInSeconds = (durationInMillis / 1000).floor();
            setState(() {
              timerRunning = false;
              isTimerRunning = false;
              pausedAccumulatedTime = _stopWatchTimer.rawTime.value;
              finishTime = DateTime.now();
              debugPrint('Adding data to latestStudyList');
              debugPrint('Subject: $selectedSubject');
            });
            int sendDurationInSeconds = (pausedAccumulatedTime / 1000)
                .floor(); // Hitung durasi dalam detik
            _sendAccumulatedTime(sendDurationInSeconds);
          },
        ),
      ];
    } else if (timerStarted && !timerRunning) {
      return [
        SpeedDialChild(
          child:
              Icon(Icons.play_arrow_rounded, color: themeProvider.primaryColor),
          label: 'Resume',
          onTap: () {
            _stopWatchTimer.onStartTimer();
            _stopWatchTimer.rawTime.listen((value) {
              _timerStreamController.add(value);
            });

            setState(() {
              timerRunning = true;
              isTimerRunning = true;
              startTime = DateTime.now();
            });

            // int durationInSeconds = (pausedAccumulatedTime / 1000).floor();
            // _sendAccumulatedTime(durationInSeconds);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.stop, color: themeProvider.primaryColor),
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
            child: Icon(Icons.timer, color: themeProvider.primaryColor),
            label: 'Timer Start',
            onTap: () {
              // Show an alert dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Incomplete Selection'),
                    content: const Text(
                        'Please select a subject and method before starting the timer.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ];
      } else {
        return [
          SpeedDialChild(
            child: Icon(Icons.timer, color: themeProvider.primaryColor),
            label: 'Timer start',
            onTap: () {
              _stopWatchTimer.onStartTimer();
              _stopWatchTimer.rawTime.listen((value) {
                _timerStreamController.add(value);
                startTime = DateTime.now();
                debugPrint('Start Time: $startTime');
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
              });
            },
          ),
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;
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
        key: mainScreenKey,
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
                  ? themeProvider.primaryColor
                  : themeProvider.primaryColor)
              : themeProvider.primaryColor,
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
          activeColor: themeProvider.primaryColor,
          inactiveColor: Colors.grey,
          backgroundColor: isDarkMode
              ? Colors.black
              : Colors.white, // Ubah warna latar belakang berdasarkan mode
        ),
      ),
    );
  }
}
