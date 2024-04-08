// import 'package:flutter/material.dart';

// import 'package:snapping_sheet_2/snapping_sheet.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//                 body: Scaffold(
//         body: SnappingSheet(
//           snappingPositions: [
//             SnappingPosition.factor(
//               positionFactor: 0.9,
//               snappingCurve: Curves.easeOutCubic,
//             ),
//             SnappingPosition.factor(
//               positionFactor: 0.4,
//               snappingCurve: Curves.easeOutCubic,
//             ),
//           ],
//           child: Container(
//             color: Colors.white,
//             child: Center(
//               child: Text('This is a SnappingSheet'),
//             ),
//           ),
//         ),
//       ),
//             );
//   }
// }



import 'package:flutter/material.dart';
// import 'package:easy_count_timer/easy_count_timer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // var controller = CountTimerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Profile Page'),
      // ),
      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     CountTimer(
      //       format: CountTimerFormat.hoursMinutesSeconds,
      //       controller: controller,
      //     ),
      //     SizedBox(height: 20),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         IconButton(
      //           onPressed: () {
      //             controller.start();
      //           },
      //           icon: Icon(Icons.play_arrow_rounded),
      //         ),
      //         IconButton(
      //           onPressed: () {
      //             controller.pause();
      //           },
      //           icon: Icon(Icons.pause_rounded),
      //         ),
      //         IconButton(
      //           onPressed: () {
      //             controller.stop();
      //           },
      //           icon: Icon(Icons.stop_rounded),
      //         ),
      //         IconButton(
      //           onPressed: () {
      //             controller.reset();
      //           },
      //           icon: Icon(Icons.restart_alt_rounded),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
