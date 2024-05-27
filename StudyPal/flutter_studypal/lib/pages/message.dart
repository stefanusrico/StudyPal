
class Message {
  final String id;
  final String message;
  final DateTime createdAt;
  final String sendBy;

  const Message({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.sendBy,
  });
}
