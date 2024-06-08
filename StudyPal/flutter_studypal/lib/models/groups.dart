import 'package:flutter_studypal/models/user_data.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final List<String> participantIds;
  final int maxParticipants;
  final List<UserData> userData;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.participantIds,
    required this.maxParticipants,
    required this.userData,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['groupname'],
      description: json['description'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      maxParticipants: json['maxParticipants'] ?? 0,
      userData: [],
    );
  }
}
