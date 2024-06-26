class Message {
  final String senderId;
  final String? recipientId;
  final String message;
  final String status;
  final DateTime timestamp;
  final String fullName;

  Message({
    required this.senderId,
    this.recipientId,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.fullName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      message: json['message'],
      status: json['status'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp']['_seconds'] * 1000) +
            (json['timestamp']['_nanoseconds'] ~/ 1000000),
      ),
      fullName: json['fullName'],
    );
  }
}
