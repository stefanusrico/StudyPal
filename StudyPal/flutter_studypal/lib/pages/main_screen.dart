import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_studypal/components/nav_bar.dart';
import 'package:flutter_studypal/components/nav_model.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'home_page.dart';
import 'insight_page.dart';
import 'group_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(
        page: const HomePage(),
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
          children: items
              .map((page) => Navigator(
                    key: page.navKey,
                    onGenerateInitialRoutes: (navigator, initialRoute) {
                      return [
                        MaterialPageRoute(builder: (context) => page.page)
                      ];
                    },
                  ))
              .toList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton( // Floating action button
          onPressed: () => debugPrint("Add Button pressed"),
          shape: const CircleBorder(), // Set shape to circle
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: [
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
          activeColor: const Color.fromARGB(255,150,180,254),// Set color for selected icon
          inactiveColor: Colors.grey, // Set color for inactive icons
        ),
      ),
    );
  }
}
