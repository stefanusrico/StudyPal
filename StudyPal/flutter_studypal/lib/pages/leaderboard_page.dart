import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

extension DateUtils on DateTime {
  int get weekOfYear {
    final firstThursday = DateTime(year, 1, 4)
        .subtract(Duration(days: DateTime(year, 1, 4).weekday - 4));
    final week = ((difference(firstThursday).inDays + 1) / 7).ceil();
    if (week == 0) {
      final lastWeekOfPreviousYear = DateTime(year - 1, 12, 28).weekOfYear;
      if (lastWeekOfPreviousYear == 53) {
        return 53;
      } else {
        return 52;
      }
    } else if (week > 52) {
      final nextYear = DateTime(year + 1, 1, 1);
      final nextFirstThursday = DateTime(nextYear.year, 1, 4)
          .subtract(Duration(days: DateTime(nextYear.year, 1, 4).weekday - 4));
      if (difference(nextFirstThursday).inDays >= 0) {
        return 1;
      }
    }
    return week;
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String? email;
  String? token;
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Day';
  int _selectedWeek = DateTime.now().weekOfYear;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<Map<String, dynamic>> dailyAccumulatedTimes = [];
  List<Map<String, dynamic>> weeklyAccumulatedTimes = [];
  List<Map<String, dynamic>> monthlyAccumulatedTimes = [];

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  Future<List<Map<String, dynamic>>> fetchDailyAccumulatedTimes() async {
    await _getEmailandToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/daily-accumulated-times'),
      headers: headers,
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch daily accumulated times');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWeeklyAccumulatedTimes() async {
    await _getEmailandToken(); // Ambil email dan token dari SharedPreferences

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $token', // Tambahkan header Authorization dengan Bearer Token
    };

    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/weekly-accumulated-times'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch weekly accumulated times');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMonthlyAccumulatedTimes() async {
    await _getEmailandToken(); // Ambil email dan token dari SharedPreferences

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $token', // Tambahkan header Authorization dengan Bearer Token
    };

    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/monthly-accumulated-times'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch monthly accumulated times');
    }
  }

  List<Map<String, dynamic>> _getAccumulatedTimesList() {
    switch (_selectedPeriod) {
      case 'Day':
        return dailyAccumulatedTimes;
      case 'Week':
        return weeklyAccumulatedTimes;
      case 'Month':
        return monthlyAccumulatedTimes;
      default:
        return [];
    }
  }

  void _changeDate(int value) {
    setState(() {
      if (_selectedPeriod == 'Week') {
        _selectedWeek += value;
        if (_selectedWeek < 1) {
          _selectedYear--;
          _selectedWeek =
              DateTime(_selectedYear, DateTime.december, 31).weekOfYear;
        } else if (_selectedWeek >
            DateTime(_selectedYear, DateTime.december, 31).weekOfYear) {
          _selectedYear++;
          _selectedWeek = 1;
        }
      } else if (_selectedPeriod == 'Month') {
        DateTime newDate = DateTime(_selectedYear, _selectedMonth + value);
        _selectedYear = newDate.year;
        _selectedMonth = newDate.month;
      } else {
        _selectedDate = _selectedDate.add(Duration(days: value));
      }
    });
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
  }

  @override
  void initState() {
    super.initState();
    _getEmailandToken().then((_) {
      fetchDailyAccumulatedTimes().then((data) {
        setState(() {
          dailyAccumulatedTimes = data;
        });
      }).catchError((error) {
        print('Error fetching daily accumulated times: $error');
      });

      fetchWeeklyAccumulatedTimes().then((data) {
        setState(() {
          weeklyAccumulatedTimes = data;
        });
      }).catchError((error) {
        print('Error fetching weekly accumulated times: $error');
      });

      fetchMonthlyAccumulatedTimes().then((data) {
        setState(() {
          monthlyAccumulatedTimes = data;
        });
      }).catchError((error) {
        print('Error fetching monthly accumulated times: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total rankings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              icon: const Icon(Icons.filter_list),
              underline: const SizedBox(),
              value: _selectedPeriod,
              items: ['Day', 'Week', 'Month'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                _changePeriod(value!);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _changePeriod('Day'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _selectedPeriod == 'Day'
                          ? Colors.white
                          : Colors.black,
                      backgroundColor: _selectedPeriod == 'Day'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                    child: const Text('Day'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _changePeriod('Week'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _selectedPeriod == 'Week'
                          ? Colors.white
                          : Colors.black,
                      backgroundColor: _selectedPeriod == 'Week'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                    child: const Text('Week'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _changePeriod('Month'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: _selectedPeriod == 'Month'
                          ? Colors.white
                          : Colors.black,
                      backgroundColor: _selectedPeriod == 'Month'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                    child: const Text('Month'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text(
                  _selectedPeriod == 'Day'
                      ? '${_selectedDate.day} ${_getMonthName(_selectedDate.month)}'
                      : _selectedPeriod == 'Week'
                          ? 'Week ${_selectedWeek.toString().padLeft(2, '0')}, $_selectedYear'
                          : '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Daily Top 3',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRankingCard(_getAccumulatedTimesList()[0], 0),
                  const SizedBox(width: 8.0), // Jarak antara kartu ranking
                  _buildRankingCard(_getAccumulatedTimesList()[1], 1),
                  const SizedBox(width: 8.0),
                  _buildRankingCard(_getAccumulatedTimesList()[2], 2),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _getAccumulatedTimesList().length,
                itemBuilder: (context, index) {
                  final accumulatedTime = _getAccumulatedTimesList()[index];
                  return _buildRankingItem(accumulatedTime, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  Widget _buildRankingCard(Map<String, dynamic> accumulatedTime, int index) {
    final userId = accumulatedTime['userId'] ?? '-';
    final accumulatedTimeValue = accumulatedTime['accumulatedTime'] ?? 0;
    final formattedTime = accumulatedTimeValue != null
        ? formatDuration(accumulatedTimeValue)
        : '-';
    final rank = (index + 1).toString();
    final fullName = accumulatedTime['fullName'] ?? userId;
    final color = index == 0
        ? Colors.yellow
        : index == 1
            ? Colors.grey
            : Colors.brown.shade300;

    return Column(
      children: [
        CircleAvatar(
          radius: 24.0,
          backgroundColor: color,
          child: Text(
            rank,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> accumulatedTime, int index) {
    final userId = accumulatedTime['userId'] ?? '-';
    final accumulatedTimeValue = accumulatedTime['accumulatedTime'] ??
        0; // Nilai default jika accumulatedTime null
    final formattedTime = accumulatedTimeValue != null
        ? formatDuration(accumulatedTimeValue)
        : '-'; // Tampilkan '-' jika accumulatedTime null
    final rank = (index + 1).toString();
    final fullName = accumulatedTime['fullName'] ?? userId;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12.0,
                backgroundColor: Colors.red,
                child: Text(
                  rank,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              // const CircleAvatar(
              //   radius: 20.0,
              //   backgroundImage: AssetImage('assets/profile_image.jpg'),
              // ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.book, color: Colors.grey),
              const SizedBox(width: 8.0),
              const Icon(Icons.laptop, color: Colors.grey),
            ],
          ),
        ),
        const Divider(height: 32.0),
      ],
    );
  }
}

String formatDuration(int accumulatedTime) {
  final duration = Duration(seconds: accumulatedTime);
  final hours = duration.inHours.remainingDigits(2);
  final minutes = duration.inMinutes.remainder(60).remainingDigits(2);
  final seconds = duration.inSeconds.remainder(60).remainingDigits(2);
  return '$hours:$minutes:$seconds';
}

extension on int {
  String remainingDigits(int digits) {
    final value = toString().padLeft(digits, '0');
    return value.substring(value.length - digits);
  }
}
