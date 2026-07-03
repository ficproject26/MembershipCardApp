class MessageModel {
  final String id;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String content;
  final String type;
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.type = 'TEXT',
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverType: json['receiverType'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      mediaUrl: json['mediaUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
