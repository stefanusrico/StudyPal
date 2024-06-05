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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

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
  late IO.Socket socket;
  Future<void>? _loadMessagesFuture;

  @override
  void initState() {
    super.initState();
    _loadMessagesFuture = _loadMessages();
  }

  Future<void> _loadMessages() async {
    await _getEmailandToken();
    initSocket();
    await loadMessagesFromBackend('group1', email!);
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void initSocket() {
    socket = IO.io('http://10.0.2.2:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((data) => print('Connected'));
    socket.onDisconnect((data) => print('Disconnected'));
    socket.on('newMessage', (data) {
      handleIncomingMessage(data);
    });
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
    final message = types.TextMessage(
      author: data['sender'] == email ? _user : types.User(id: data['sender']),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: data['text'],
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void sendMessage(String text) {
    // Kirim pesan ke server menggunakan socket.emit
    socket.emit('message', {'text': text, 'senderId': email});

    // Tambahkan pesan ke daftar pesan
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

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(response.body);
        final messages = messagesData.map((messageData) {
          final createdAt = messageData['sentAt'];
          int? createdAtMillis;

          if (createdAt is String) {
            createdAtMillis = DateTime.parse(createdAt).millisecondsSinceEpoch;
          } else if (createdAt is int) {
            createdAtMillis = createdAt;
          }

          return types.TextMessage(
            author: messageData['sentBy'] == email
                ? _user
                : types.User(
                    id: messageData['sentBy'],
                    firstName: messageData['fullName']),
            createdAt: createdAtMillis ?? DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: messageData['message'],
          );
        }).toList();

        setState(() {
          _messages = messages;
        });
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading messages: $error');
    }
  }

  // void loadMessages() async {
  //   final response = await rootBundle.loadString('assets/messages.json');
  //   final messages = (jsonDecode(response) as List)
  //       .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
  //       .toList();

  //   setState(() {
  //     _messages = messages;
  //   });
  // }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Chat'), // Judul "Chat"
            centerTitle: true, // Posisikan teks di tengah header
            // leading: IconButton(
            //   // Tombol kembali di pojok kiri atas
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
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
