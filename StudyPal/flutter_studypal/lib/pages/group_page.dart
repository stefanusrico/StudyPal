import 'package:flutter/material.dart';
import 'package:flutter_studypal/models/groups.dart';
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_studypal/models/group_data.dart';
import 'package:flutter_studypal/models/user_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

Color lightenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

Color darkenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class GroupPage extends StatefulWidget {
  final Group group;

  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late Future<GroupData> _groupDataFuture;
  late Group _group;
  int currentPage = 1;
  int pageSize = 9;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _groupDataFuture = fetchGroupData(_group.id);
  }

  Future<GroupData> fetchGroupData(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/group/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      return GroupData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.group.name,
              style: const TextStyle(
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
                    : [
                        darkenColor(themeProvider.primaryColor),
                        lightenColor(themeProvider.primaryColor),
                      ],
              ),
            ),
            child: FutureBuilder<GroupData>(
              future: _groupDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                } else {
                  final groupData = snapshot.data!;
                  final userData = groupData.userData ?? [];
                  final totalItems = userData.length;
                  totalPages = (totalItems / pageSize).ceil();
                  final int onlineCount =
                      userData.where((user) => user.status == 'online').length;

                  return Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Online ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text:
                                        '$onlineCount member${onlineCount > 1 ? "s" : ""}',
                                    style: TextStyle(
                                      color: darkenColor(darkenColor(
                                          themeProvider.primaryColor)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      itemCount: currentPage == totalPages
                                          ? userData.length % pageSize
                                          : pageSize,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final startIndex =
                                            (currentPage - 1) * pageSize;
                                        final userIndex = startIndex + index;
                                        if (userIndex >= userData.length) {
                                          return Container();
                                        }

                                        final user = userData[userIndex];
                                        final isOnline =
                                            user.status == 'online';

                                        return Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            side: BorderSide(
                                              color: isOnline
                                                  ? darkenColor(themeProvider
                                                      .primaryColor)
                                                  : isDarkMode
                                                      ? Colors.black
                                                      : const Color.fromARGB(
                                                          0, 255, 255, 255),
                                              width: isOnline ? 4 : 0,
                                            ),
                                          ),
                                          color: isOnline
                                              ? themeProvider.primaryColor
                                              : isDarkMode
                                                  ? const Color.fromARGB(
                                                      255, 23, 23, 23)
                                                  : Colors.white,
                                          child: InkWell(
                                            onTap: () {
                                              // Aksi saat kartu ditekan
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: isOnline
                                                      ? Colors.white
                                                      : themeProvider
                                                          .primaryColor,
                                                ),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${user.firstName} ${user.lastName}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isOnline
                                                            ? Colors.white
                                                            : themeProvider
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 20, 18),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Showing ${(currentPage - 1) * pageSize + 1}-${currentPage == totalPages ? userData.length : currentPage * pageSize} of ${userData.length} members',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 65),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.chevron_left_rounded,
                                              color: Colors.white),
                                          onPressed: currentPage > 1
                                              ? () {
                                                  setState(() {
                                                    currentPage--;
                                                  });
                                                }
                                              : null,
                                        ),
                                        for (int i = 1; i <= totalPages; i++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  currentPage = i;
                                                });
                                              },
                                              style: ButtonStyle(
                                                minimumSize:
                                                    MaterialStateProperty.all<
                                                        Size>(
                                                  const Size(40, 40),
                                                ),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  currentPage == i
                                                      ? themeProvider
                                                          .primaryColor
                                                      : isDarkMode
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 23, 23, 23)
                                                          : Colors.white,
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: BorderSide(
                                                      color: currentPage == i
                                                          ? darkenColor(
                                                              themeProvider
                                                                  .primaryColor)
                                                          : isDarkMode
                                                              ? Colors.black
                                                              : Colors.white,
                                                      width: currentPage == i
                                                          ? 4
                                                          : 0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                i.toString(),
                                                style: TextStyle(
                                                  color: currentPage == i
                                                      ? Colors.white
                                                      : themeProvider
                                                          .primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.white),
                                          onPressed: currentPage < totalPages
                                              ? () {
                                                  setState(() {
                                                    currentPage++;
                                                  });
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      bottomDetailsSheet(groupData),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomDetailsSheet(GroupData groupData) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return DraggableScrollableSheet(
      initialChildSize: .63,
      minChildSize: .08,
      maxChildSize: .70,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: isDarkMode
              ? const BoxDecoration(
                  color: Color.fromARGB(255, 25, 25, 25),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                )
              : const BoxDecoration(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildCustomCard("02:10:47", "Time Total"),
                              // buildCustomCard("00:20:43", "Max Focus"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Row kedua
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       buildCustomCard("12h 20m", "Start Time"),
                        //       buildCustomCard("14h 30m", "Finish Time"),
                        //     ],
                        //   ),
                        // ),
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
                                  ? const Color.fromARGB(255, 41, 41, 41)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              groupData.lastMessage != null
                                  ? groupData.lastMessage!['message'] ??
                                      'we r goin to c the lions'
                                  : 'we r goin to c the lions',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                final groupId = widget.group.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage(groupId: groupId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    darkenColor(themeProvider.primaryColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      width: 140,
      height: 80,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 136, 146, 237),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
