import 'package:app_chat/data/models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('chat/general');

  void sendMessage(MessageModel message) {
    ref.push()
      .set(message.toJson());
  }
}

