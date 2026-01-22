import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/domain/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';

class ChatView extends ConsumerWidget {
  ChatView({super.key});

  final TextEditingController controller = TextEditingController();
  final String usuario = "Usuario Doris";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mensajesAsync = ref.watch(messageProvider);
    final service = ref.read(firebaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat en Tiempo Real'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //para  los mensajes
          Expanded(
            child: mensajesAsync.when(
              data: (mensajes) => ListView.builder(
                itemCount: mensajes.length,
                itemBuilder: (_, i) {
                  final m = mensajes[i];
                  return ListTile(
                    title: Text(m.text),
                    subtitle: Text(m.author),
                  );
                },
              ),
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
            ),
          ),

          //la barrita de mensaje
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (controller.text.trim().isEmpty) return;

                      service.sendMessage(
                        MessageModel.fromEntity(Message(
                          text: controller.text.trim(),
                          author: usuario,
                          timestamp:
                          DateTime.now().millisecondsSinceEpoch,
                        )),
                      );
                      controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
