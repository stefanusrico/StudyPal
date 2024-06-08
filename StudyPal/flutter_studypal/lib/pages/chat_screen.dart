import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_studypal/models/message.dart';
import 'package:flutter_studypal/models/socket_manager.dart';

class ChatPage extends StatefulWidget {
  final dynamic groupId;
  final IO.Socket socket;

  ChatPage({super.key, required this.groupId})
      : socket = IO.io(
          'http://10.0.2.2:4000',
          IO.OptionBuilder().setTransports(['websocket']).build(),
        );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  String? email;
  String? token;
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  Future<void>? _loadMessagesFuture;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadMessagesFuture = _loadMessages();
    if (!SocketManager.socket.connected) {
      _connectToServer();
    }
  }

  Future<void> _loadMessages() async {
    await _getEmailandToken();
    print(widget.groupId);
    await loadMessagesFromBackend(widget.groupId, email!);
  }

  @override
  void dispose() {
    _disconnectSocket();
    super.dispose();
  }

  void _connectToServer() {
    if (!_isConnected) {
      _isConnected = true;
      SocketManager.socket.onConnect((_) {
        print('Connected');
        SocketManager.socket.emit('join', {'groupId': widget.groupId});
      });

      SocketManager.socket.onDisconnect((data) {
        print('Disconnected');
        _isConnected = false;
      });

      SocketManager.socket.on('newMessage', (data) {
        handleIncomingMessage(data);
      });
    }
  }

  void _disconnectSocket() {
    if (_isConnected) {
      print('Disconnected');
      SocketManager.socket.disconnect();
      _isConnected = false;
    }
  }

  Future<void> _getEmailandToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      token = prefs.getString('token');
    });
  }

  void addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void handleIncomingMessage(dynamic data) {
    try {
      final senderId = (data['senderId'] ?? '').toString();
      final text = data['text'] ?? '';

      if (senderId.isNotEmpty && text.isNotEmpty) {
        final message = types.TextMessage(
          author: senderId == email
              ? _user
              : types.User(id: senderId, firstName: data['fullName']),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: text,
        );

        setState(() {
          _messages.insert(0, message);
        });
      }
    } catch (error, stackTrace) {
      print('Error handling incoming message: $error');
      print('Stack trace: $stackTrace');
    }
  }

  void sendMessage(String text) {
    widget.socket.emit(
      'message',
      jsonEncode({
        'text': text,
        'senderId': email,
        'groupId': widget.groupId,
      }),
    );

    final message = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void handleSendPressed(types.PartialText message) {
    sendMessage(message.text);
  }

  void handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      addMessage(message);
    }
  }

  void handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      addMessage(message);
    }
  }

  void handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  Future<void> loadMessagesFromBackend(String groupId, String email) async {
    final url = 'http://10.0.2.2:4000/messages/$groupId?email=$email';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(response.body);
        final messages = messagesData.map((messageData) {
          final chatMessage = ChatMessage.fromJson(messageData);
          return types.TextMessage(
            author: chatMessage.senderId == email
                ? _user
                : types.User(
                    id: chatMessage.senderId,
                    firstName: chatMessage.fullName,
                  ),
            createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: chatMessage.message,
          );
        }).toList();
        setState(() {
          _messages = messages;
        });
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      print('Error loading messages: $error');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Chat'), // Judul "Chat"
            centerTitle: true, // Posisikan teks di tengah header
            leading: IconButton(
              // Tombol kembali di pojok kiri atas
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          body: FutureBuilder<void>(
            future: _loadMessagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Chat(
                  messages: _messages,
                  onAttachmentPressed: handleAttachmentPressed,
                  onMessageTap: handleMessageTap,
                  onPreviewDataFetched: handlePreviewDataFetched,
                  onSendPressed: handleSendPressed,
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _user,
                  theme: const DefaultChatTheme(
                    seenIcon: Text(
                      'read',
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
}
