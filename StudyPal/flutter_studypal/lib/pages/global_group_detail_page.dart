import 'package:flutter/material.dart';
import 'package:flutter_studypal/models/groups.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalGroupDetailDialog extends StatelessWidget {
  final Group group;

  const GlobalGroupDetailDialog({super.key, required this.group});

  Future<void> joinGroup(String userId, String groupId) async {
    final url = Uri.parse('http://10.0.2.2:4000/groups/$groupId/join');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Pengguna berhasil bergabung ke grup
        print('User joined the group successfully');
      } else {
        // Tangani error bergabung ke grup
        print('Failed to join group: ${response.body}');
      }
    } catch (e) {
      print('Error joining group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantIds = group.participantIds ?? [];
    final maxParticipants = group.maxParticipants ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  group.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  '${participantIds.length}/${maxParticipants} person',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: participantIds.length < maxParticipants
                    ? () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId = prefs.getString('email');
                        if (userId != null) {
                          await joinGroup(userId, group.id);
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      }
                    : null,
                child: const Text('Join Group'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
