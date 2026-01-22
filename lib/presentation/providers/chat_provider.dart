import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/data/services/firebase_service.dart';
import 'package:app_chat/data/services/notification_service.dart';
import 'package:app_chat/domain/models/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_provider.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final messageProvider = StreamProvider<List<Message>>((ref) {
  final service = ref.read(firebaseServiceProvider);

  return service.ref.onValue.map((event) {
    final raw = event.snapshot.value;

    if (raw == null) return [];

    final data = Map<String, dynamic>.from(raw as Map);

    return data.values
        .map((e) => MessageModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity())
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  });
});

final chatNotificationProvider = Provider<void>((ref) {
  ref.listen(messageProvider, (prev, next) {
    if (next.isLoading || next.value == null) return;

    final previous = prev?.value ?? [];
    final current = next.value!;

    if (previous.isEmpty) return;

    final lastPrevTs = previous.last.timestamp;
    final lastCurrent = current.last;

    final user = ref.read(userProvider);
    if (user != null && lastCurrent.author == user.name) return;

    if (lastCurrent.timestamp > lastPrevTs) {
      NotificationService.show(
        title: lastCurrent.author,
        body: lastCurrent.text,
      );
    }
  });
});
