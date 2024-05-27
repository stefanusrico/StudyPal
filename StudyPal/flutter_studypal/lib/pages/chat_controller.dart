import 'package:flutter/material.dart';

import 'message.dart';

class ChatController {
  final List<Message> initialMessageList;
  final List<ChatUser> chatUsers;
  final ScrollController scrollController;

  ChatController({
    required this.initialMessageList,
    required this.chatUsers,
    required this.scrollController,
  });
}

class ChatUser {
  final String id;
  final String name;
  final String profilePhoto;

  const ChatUser({
    required this.id,
    required this.name,
    required this.profilePhoto,
  });
}
