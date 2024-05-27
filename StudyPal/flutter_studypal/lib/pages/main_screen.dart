import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_studypal/components/nav_model.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'home_page.dart';
import 'insight_page.dart';
import 'group_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final homeNavKey = GlobalKey<NavigatorState>();
  final insightNavKey = GlobalKey<NavigatorState>();
  final groupNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  final StreamController<int> _timerStreamController =
      StreamController<int>.broadcast();
  final ValueNotifier<int> _timerValueNotifier = ValueNotifier<int>(0);
  int selectedTab = 0;
  List<NavModel> items = [];

  bool timerStarted = false;
  bool timerRunning = false;
  bool isTimerRunning = false;
  int stoppedTimerValue = 0;
  String selectedSubject = '';
  String selectedMethod = '';

  // StopWatchTimer instance
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) {
      print('Timer Value: $value');
    },
  );

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
          selectedSubject: '', // Provide an initial value for 'selectedSubject'
          selectedMethod: '', // Provide an initial value for 'selectedMethod'
          updateSelectedSubject: updateSelectedSubject,
          updateSelectedMethod: updateSelectedMethod,
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
        // ...
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
            });
          },
        ),
        // ...
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
              });
            },
          ),
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
