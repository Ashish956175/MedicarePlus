import 'dart:async';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _messageController = StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get messageStream => _messageController.stream;

  final List<ChatMessage> _messages = [];

  void loadInitialMessages(String otherUserId) {
    // Mock initial messages
    _messages.clear();
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: otherUserId,
        receiverId: 'me',
        text: 'Hello Doctor, I have a question about my prescription.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'me',
        receiverId: otherUserId,
        text: 'Sure, please go ahead. How can I help you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isMe: true,
      ),
    ]);
    _messageController.add(List.from(_messages));
  }

  void sendMessage(String receiverId, String text) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );
    _messages.add(newMessage);
    _messageController.add(List.from(_messages));

    // Mock an auto-reply
    Timer(const Duration(seconds: 2), () {
      final reply = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: receiverId,
        receiverId: 'me',
        text: 'Thank you for your response, Doctor!',
        timestamp: DateTime.now(),
        isMe: false,
      );
      _messages.add(reply);
      _messageController.add(List.from(_messages));
    });
  }

  void dispose() {
    _messageController.close();
  }
}
