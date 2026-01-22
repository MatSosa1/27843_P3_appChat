import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/data/services/firebase_service.dart';
import 'package:app_chat/domain/models/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final messageProvider = StreamProvider<List<Message>>((ref) {
  final service = ref.read(firebaseServiceProvider);

  return service.ref.onValue.map((event) {
    final data = event.snapshot.value as Map<String, dynamic>?;

    if (data == null) {
      return [];
    }

    return data.values
      .map((e) => MessageModel.fromJson(e).toEntity())
      .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  });
});
