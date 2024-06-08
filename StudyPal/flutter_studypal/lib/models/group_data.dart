import 'user_data.dart';

class GroupData {
  final Map<String, dynamic>? lastMessage;
  final String? description;
  final String? documentId;
  final String? groupname;
  final String? initiatedBy;
  final int? maxParticipants;
  final DateTime? initiatedAt;
  final DateTime? lastUpdatedAt;
  final List<String>? participantIds;
  final List<UserData>? userData;

  GroupData({
    this.lastMessage,
    this.description,
    this.documentId,
    this.groupname,
    this.initiatedBy,
    this.maxParticipants,
    this.initiatedAt,
    this.lastUpdatedAt,
    this.participantIds,
    this.userData,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      lastMessage: json['lastMessage'] != null
          ? Map<String, dynamic>.from(json['lastMessage'])
          : null,
      description: json['description'],
      documentId: json['documentId'],
      groupname: json['groupname'],
      initiatedBy: json['initiatedBy'],
      maxParticipants: json['maxParticipants'],
      initiatedAt: json['initiatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['initiatedAt']['_seconds'] * 1000)
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['lastUpdatedAt']['_seconds'] * 1000)
          : null,
      participantIds: json['participantIds'] != null
          ? List<String>.from(json['participantIds'])
          : null,
      userData: json['userData'] != null
          ? List<UserData>.from(
              json['userData'].map((userData) => UserData.fromJson(userData)))
          : null,
    );
  }
}
