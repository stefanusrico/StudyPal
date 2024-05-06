import 'package:flutter/material.dart';
import 'package:flutter_studypal/components/feature_row.dart';
import 'package:flutter_studypal/utils/global_colors.dart';
import 'package:flutter_studypal/utils/global_text.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Welcome to StudyPal",
                    textAlign: TextAlign.center,
                    style: GlobalText.blackPrimaryArimoTextStyle.copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const FeatureRowWidget(
                  iconPath: 'lib/assets/timer.svg',
                  title: 'Time tracking',
                  description: 'Tracking study time for each subject.',
                  iconHeight: 38,
                ),
                const SizedBox(height: 35),
                const FeatureRowWidget(
                  iconPath: 'lib/assets/block.svg',
                  title: 'Block distractive apps',
                  description:
                      'On focus session, block other apps to boost focus.',
                  iconHeight: 33,
                ),
                const SizedBox(height: 35),
                const FeatureRowWidget(
                  iconPath: 'lib/assets/people.svg',
                  title: 'Study groups',
                  description:
                      'Create groups to check out friends status and study activities.',
                  iconHeight: 38,
                ),
                const SizedBox(height: 35),
                const FeatureRowWidget(
                  iconPath: 'lib/assets/controller.svg',
                  title: 'Gamify your study',
                  description:
                      'Create groups to check out friends status and study activities.',
                  iconHeight: 38,
                ),
                const SizedBox(height: 35),
                const FeatureRowWidget(
                  iconPath: 'lib/assets/achievement.svg',
                  title: 'Rewards and achievements',
                  description:
                      'Create groups to check out friends status and study activities.',
                  iconHeight: 38,
                ),
                const SizedBox(height: 45),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    gradient: GlobalColors.buttonGradient,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Bottom margin
              ],
            ),
          ),
        ),
      ),
    );
  }
}
