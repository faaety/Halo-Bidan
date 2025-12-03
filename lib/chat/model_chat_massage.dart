class ChatMessage {
  final int? id;
  final String text; //isi pesan
  final String sender;//penanda pengirim pesan
  final DateTime timestamp;
  final bool isEdited;
  final String? replyTo; //isi pesan yang sedang kita balas.
  final String? replySender; //siapa pengirim pesan yang sedang dibalas.

  ChatMessage({
    this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isEdited = false,
    this.replyTo,
    this.replySender,
  });

  ChatMessage copyWith({
    int? id,
    String? text,
    String? sender,
    DateTime? timestamp,
    bool? isEdited,
    String? replyTo,
    String? replySender,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      replyTo: replyTo ?? this.replyTo,
      replySender: replySender ?? this.replySender,
    );
  }
}
