import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class Event {
  final String subject;
  final DateTime startTime;

  Event({required this.subject, required this.startTime});

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'startTime': startTime.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        subject: json['subject'],
        startTime: DateTime.parse(json['startTime']),
      );
}

class AddSchedulePage extends StatefulWidget {
  final Function(Event) onEventAdded;

  AddSchedulePage({required this.onEventAdded});

  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  String subject = '';

  void _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _pickStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (pickedTime != null) {
      setState(() {
        selectedStartTime = pickedTime;
      });
    }
  }

  void _saveSchedule() {
    final DateTime eventTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );

    Event newEvent = Event(
      subject: subject,
      startTime: eventTime,
    );

    widget.onEventAdded(newEvent);
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Schedule"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Select Date"),
              subtitle: Text(DateFormat.yMMMEd().format(selectedDate)),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            ListTile(
              title: Text("Select Start Time"),
              subtitle: Text(selectedStartTime.format(context)),
              trailing: Icon(Icons.access_time),
              onTap: () => _pickStartTime(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: TextField(
                onChanged: (value) {
                  subject = value;
                },
                decoration: InputDecoration(
                  labelText: "Subject",
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSchedule,
                child: Text("Save Schedule", style: TextStyle(color: themeProvider.primaryColor),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  Map<DateTime, List<Event>> events = {}; // Kelompokkan event berdasarkan tanggal

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load events saat inisialisasi
  }

  void goToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  void goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void onDaySelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void addEventToDate(Event event) {
    final dateKey = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );

    if (!events.containsKey(dateKey)) {
      events[dateKey] = []; // Buat daftar event baru untuk tanggal ini
    }

    events[dateKey]!.add(event); // Tambahkan event ke daftar
    _saveEvents(); // Save events setiap kali ada penambahan event baru
  }

  List<Event> getEventsForDate(DateTime date) {
    // Kembalikan event yang sesuai dengan tanggal yang dipilih
    final dateKey = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return events[dateKey] ?? [];
  }

  Future<void> _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> stringEvents = events.map((key, value) {
      return MapEntry(key.toIso8601String(), jsonEncode(value.map((e) => e.toJson()).toList()));
    });
    prefs.setString('events', jsonEncode(stringEvents));
  }

  Future<void> _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      Map<String, dynamic> stringEvents = jsonDecode(eventsString);
      setState(() {
        events = stringEvents.map((key, value) {
          DateTime date = DateTime.parse(key);
          List<Event> eventList = (jsonDecode(value) as List).map((e) => Event.fromJson(e)).toList();
          return MapEntry(date, eventList);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeModel>(context);
    final isDarkMode = themeProvider.isDarkMode;

    List<DateTime> daysInMonth = [];
    int lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    for (int i = 1; i <= lastDay; i++) {
      daysInMonth.add(DateTime(currentMonth.year, currentMonth.month, i));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Study Schedule",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16, // Ukuran teks
          ),
        ),
        centerTitle: true, // Nama AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Aksi untuk tombol AppBar lainnya
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Kontrol navigasi bulan di sini
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: goToPreviousMonth, // Mengubah bulan ke kiri
              ),
              Text(DateFormat.yMMMM().format(currentMonth)), // Format bulan
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded),
                onPressed: goToNextMonth, // Mengubah bulan ke kanan
              ),
            ],
          ),
          Container(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: daysInMonth.map((date) {
                bool isSelected = selectedDate.day == date.day;

                return GestureDetector(
                  onTap: () {
                    onDaySelected(date);
                  },
                  child: Container(
                    width: 57, // Ukuran konsisten
                    margin: EdgeInsets.symmetric(horizontal: 8), // Jarak antar-kartu
                    padding: EdgeInsets.symmetric(vertical: 10), // Padding yang seragam
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeProvider.primaryColor // Warna jika dipilih
                          : isDarkMode 
                              ? Color.fromARGB(255, 60, 60, 60)
                              : Colors.grey[100], // Warna default
                      borderRadius: BorderRadius.circular(10), // Ujung yang bulat
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date), // Nama hari
                          style: TextStyle(
                            color: isSelected 
                              ? Colors.white 
                              : isDarkMode 
                                  ? Colors.white
                                  : Colors.black, // Warna font
                          ),
                        ),
                        Text(
                          DateFormat('d').format(date), // Tanggal
                          style: TextStyle(
                            color: isSelected 
                              ? Colors.white 
                              : isDarkMode 
                                  ? Colors.white
                                  : Colors.black,  // Warna font
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 24, // 24 jam dalam sehari
              itemBuilder: (context, index) {
                String hour = DateFormat('hh:mm a').format(DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  index,
                ));

                // Cari event yang dimulai pada jam ini
                List<Event> eventsForHour = getEventsForDate(selectedDate).where(
                  (event) => event.startTime.hour == index,
                ).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          // Label waktu per jam
                          Text(
                            hour,
                            style: TextStyle(
                              color: isDarkMode 
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                          // Tambahkan jarak antara waktu dan kartu subjek
                          SizedBox(width: 10), // Jarak horizontal 10 piksel

                          // Kartu subjek dan waktu yang bisa discroll secara horizontal
                          if (eventsForHour.isNotEmpty)
                            Expanded( // Pastikan `Row` dapat menggunakan seluruh lebar yang tersisa
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Untuk scroll horizontal
                                child: Row(
                                  children: eventsForHour.map((event) {
                                    String formattedTime = DateFormat.jm().format(event.startTime);

                                    return Card(
                                      color: themeProvider.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(17, 5, 17, 5),
                                        child: Text(
                                          '${event.subject}, $formattedTime', // Format teks dalam kartu
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSchedulePage(
                onEventAdded: (event) {
                  setState(() {
                    addEventToDate(event); // Tambahkan event ke tanggal yang sesuai
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white, // Warna jika dipilih,
        shape: CircleBorder(), // Bentuk bulat
      ),
    );
  }
}
