import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_chat/presentation/widgets/chat/message_bubble.dart';
import 'package:app_chat/core/theme/app_colors.dart';

void main() {
  testWidgets('MessageBubble renderiza mensaje propio (derecha, color primario)', (tester) async {
    const message = 'Mi mensaje';
    const author = 'Yo';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            author: author,
            timestamp: timestamp,
            isMe: true, // Caso: Soy yo
          ),
        ),
      ),
    );

    // Verifica texto del mensaje
    expect(find.text(message), findsOneWidget);
    // Verifica que NO se muestra el autor para mensajes propios (según lógica del código original)
    expect(find.text(author), findsNothing);
    
    // Verifica alineación (el contenedor debe tener márgenes específicos para isMe)
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.myMessageBubble);
  });

  testWidgets('MessageBubble renderiza mensaje de otro (izquierda, color blanco)', (tester) async {
    const message = 'Hola tú';
    const author = 'Otro';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            author: author,
            timestamp: timestamp,
            isMe: false, // Caso: Es otro
          ),
        ),
      ),
    );

    expect(find.text(message), findsOneWidget);
    // Para otros, SÍ se muestra el autor
    expect(find.text(author), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.otherMessageBubble);
  });
}