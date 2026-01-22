import 'package:app_chat/domain/models/message.dart';

class MessageModel {
  final String text;
  final String author;
  final int timestamp;

  MessageModel({
    required this.text,
    required this.author,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      text: map['text'],
      author: map['author'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'timestamp': timestamp
    };
  }

  Message toEntity() {
    return Message(
      text: text,
      author: author,
      timestamp: timestamp
    );
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      text: message.text,
      author: message.author,
      timestamp: message.timestamp
    );
  }
}
