import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_chat/presentation/views/chat_view.dart';
import 'package:app_chat/presentation/providers/user_provider.dart';
import 'package:app_chat/presentation/providers/chat_provider.dart';
import 'package:app_chat/data/services/firebase_service.dart';
import 'package:app_chat/domain/models/message.dart';
import 'package:app_chat/data/models/message_model.dart';

// Mocks
class MockFirebaseService extends Mock implements FirebaseService {}

// Mock Notifier para controlar el usuario logueado
class MockUserNotifier extends UserNotifier {
  @override
  UserData? build() {
    return const UserData(id: 'test-id', name: 'Test User');
  }
}

void main() {
  late MockFirebaseService mockFirebaseService;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    // Registramos el fallback para MessageModel por si Mocktail lo pide
    registerFallbackValue(MessageModel(text: '', author: '', timestamp: 0));
  });

  testWidgets('ChatView muestra mensajes y permite enviar', (tester) async {
    // 1. Datos de prueba
    final testMessages = [
      Message(text: 'Hola', author: 'Test User', timestamp: 1000), // Mío
      Message(text: 'Mundo', author: 'Otro', timestamp: 2000),     // Otro
    ];

    // 2. Renderizar UI con overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override 1: Servicio de Firebase simulado
          firebaseServiceProvider.overrideWithValue(mockFirebaseService),
          
          // Override 2: Lista de mensajes (Simulamos un stream con datos inmediatos)
          messageProvider.overrideWith((ref) => Stream.value(testMessages)),
          
          // Override 3: Usuario Logueado
          userProvider.overrideWith(() => MockUserNotifier()),

          // Override 4: Desactivar notificaciones para el test
          chatNotificationProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(home: ChatView()),
      ),
    );

    // Esperar a que el Stream emita los datos y la UI se dibuje
    await tester.pumpAndSettle();

    // 3. Validaciones Visuales
    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('Mundo'), findsOneWidget);
    expect(find.text('Chat General'), findsOneWidget); // Título del AppBar

    // 4. Prueba de interacción: Enviar mensaje
    // Encontrar el campo de texto
    final inputFinder = find.byType(TextField);
    await tester.enterText(inputFinder, 'Nuevo Mensaje');
    
    // Encontrar botón de enviar (icono send_rounded)
    final sendButton = find.byIcon(Icons.send_rounded);
    await tester.tap(sendButton);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 300)); 
    
    //Esperar a que terminen todas las animaciones de scroll
    await tester.pumpAndSettle();

    // 5. Verificar que se llamó al servicio de Firebase
    verify(() => mockFirebaseService.sendMessage(any())).called(1);
  });
}