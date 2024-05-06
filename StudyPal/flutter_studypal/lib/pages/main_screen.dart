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
  int selectedTab = 0;
  List<NavModel> items = [];

  bool timerStarted = false;
  bool timerRunning = false;

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
        page: HomePage(stopWatchTimer: _stopWatchTimer), // Berikan referensi stopWatchTimer
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

  List<SpeedDialChild> _getSpeedDialChildren() {
    if (timerStarted && timerRunning) {
      // Jika timer berjalan, opsi "Pause" dan "Stop"
      return [
        SpeedDialChild(
          child: Icon(Icons.pause, color: Colors.orange),
          label: 'Pause',
          onTap: () {
            _stopWatchTimer.onStopTimer(); // Berhenti, tapi tidak reset
            setState(() {
              timerRunning = false; // Timer sedang berhenti
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.stop, color: Colors.red),
          label: 'Stop',
          onTap: () {
            _stopWatchTimer.onResetTimer(); // Reset timer
            setState(() {
              timerStarted = false; // Timer berhenti dan di-reset
            });
          },
        ),
      ];
    } else if (timerStarted && !timerRunning) {
      // Jika timer mulai tetapi sedang dihentikan, opsi "Resume" dan "Stop"
      return [
        SpeedDialChild(
          child: Icon(Icons.play_arrow_rounded, color: Colors.green),
          label: 'Resume',
          onTap: () {
            _stopWatchTimer.onStartTimer(); // Mulai lagi
            setState(() {
              timerRunning = true; // Timer berjalan lagi
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.stop, color: Colors.red),
          label: 'Stop',
          onTap: () {
            _stopWatchTimer.onResetTimer(); // Reset timer
            setState(() {
              timerStarted = false; // Timer berhenti dan di-reset
            });
          },
        ),
      ];
    } else {
      // Jika timer belum dimulai, opsi "Mulai timer"
      return [
        SpeedDialChild(
          child: Icon(Icons.timer, color: Colors.green),
          label: 'Mulai timer',
          onTap: () {
            _stopWatchTimer.onStartTimer(); // Mulai timer
            setState(() {
              timerStarted = true;
              timerRunning = true; // Timer berjalan
            });
          },
        ),
      ];
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
          icon: timerStarted ? (timerRunning ? Icons.pause : Icons.play_arrow_rounded) : Icons.timer_outlined,
          activeIcon: Icons.close,
          foregroundColor: Colors.white,
          backgroundColor: timerStarted ? (timerRunning ? Color.fromARGB(255, 186, 188, 252) : Color.fromARGB(255, 145, 112, 255)) : Color.fromARGB(255, 192, 193, 255),
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
              items[index].navKey.currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                selectedTab = index;
              });
            }
          },
          activeColor: const Color.fromARGB(255,150,180,254),
          inactiveColor: Colors.grey,
        ),
      ),
    );
  }
}
