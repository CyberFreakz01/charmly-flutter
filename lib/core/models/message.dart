enum MessageRole { user, model }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
  });

  final String id;
  final MessageRole role;
  final String text;

  factory ChatMessage.make(MessageRole role, String text) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return ChatMessage(id: '$stamp-${role.name}', role: role, text: text);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
      };
}
