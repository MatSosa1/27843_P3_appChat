import 'package:app_chat/data/models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('chat/general');

  void sendMessage(MessageModel message) {
    ref.push()
      .set(message.toJson());
  }

  Stream<List<MessageModel>> receiveMessages() {
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<String, dynamic>?;

      if (data == null) return [];

      final messages = data.values
        .map((e) => MessageModel.fromJson(e))
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    });
  }
}

