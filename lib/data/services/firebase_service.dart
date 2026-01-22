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
      final raw = event.snapshot.value;

      if (raw == null) return [];

      final data = Map<String, dynamic>.from(raw as Map);

      return data.values
          .map((e) => MessageModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }
}
