class ChatMessage {
  final String senderId;
  final String? recipientId;
  final String message;
  final String status;
  final DateTime timestamp;
  final String fullName;

  ChatMessage({
    required this.senderId,
    this.recipientId,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.fullName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
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
