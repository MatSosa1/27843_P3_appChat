import 'dart:async';

import 'package:app_chat/data/services/firebase_service.dart';
import 'package:app_chat/domain/models/message.dart';
import 'package:app_chat/presentation/providers/chat_provider.dart';
import 'package:app_chat/presentation/providers/user_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---
class MockFirebaseService extends Mock implements FirebaseService {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

// Mock UserNotifier
class MockUserNotifier extends UserNotifier {
  @override
  UserData? build() => const UserData(id: 'my-id', name: 'Yo');
}

void main() {
  late MockFirebaseService mockService;
  late MockDatabaseReference mockRef;
  late StreamController<DatabaseEvent> eventController;

  setUp(() {
    mockService = MockFirebaseService();
    mockRef = MockDatabaseReference();
    
    // IMPORTANTE: sync: true para evitar Timeouts
    eventController = StreamController<DatabaseEvent>.broadcast(sync: true);

    when(() => mockService.ref).thenReturn(mockRef);
    when(() => mockRef.onValue).thenAnswer((_) => eventController.stream);
  });

  tearDown(() {
    eventController.close();
  });

  // Helper para convertir los estados del provider en un Stream testeable
  Stream<AsyncValue<List<Message>>> monitorProvider(ProviderContainer container) {
    final controller = StreamController<AsyncValue<List<Message>>>();
    final sub = container.listen(
      messageProvider,
      (_, next) => controller.add(next),
      fireImmediately: true,
    );
    addTearDown(() {
      sub.close();
      controller.close();
    });
    return controller.stream;
  }

  group('messageProvider Tests', () {
    test('Debe transformar datos de Firebase a List<Message> ordenados', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final rawData = {
        'msg1': {'text': 'Hola', 'author': 'Otro', 'timestamp': 2000},
        'msg2': {'text': 'Mundo', 'author': 'Yo', 'timestamp': 1000},
      };

      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      when(() => mockEvent.snapshot).thenReturn(mockSnapshot);
      when(() => mockSnapshot.value).thenReturn(rawData);

      // Verificamos la secuencia de estados: Loading -> Data con 2 mensajes
      expectLater(
        monitorProvider(container),
        emitsInOrder([
          isA<AsyncLoading<List<Message>>>(), // Estado inicial
          isA<AsyncData<List<Message>>>()
              .having((d) => d.value.length, 'length', 2)
              .having((d) => d.value.first.text, 'first', 'Mundo') // Ordenado por fecha (1000)
              .having((d) => d.value.last.text, 'last', 'Hola'),   // (2000)
        ]),
      );

      // Emitimos el evento
      eventController.add(mockEvent);
    });

    test('Debe retornar lista vacía si snapshot.value es null', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final mockEvent = MockDatabaseEvent();
      final mockSnapshot = MockDataSnapshot();
      when(() => mockEvent.snapshot).thenReturn(mockSnapshot);
      when(() => mockSnapshot.value).thenReturn(null);

      expectLater(
        monitorProvider(container),
        emitsInOrder([
          isA<AsyncLoading<List<Message>>>(),
          isA<AsyncData<List<Message>>>().having((d) => d.value, 'value', isEmpty),
        ]),
      );

      eventController.add(mockEvent);
    });
  });

  group('chatNotificationProvider Tests', () {
    test('Detecta nuevo mensaje y cambia estado (simulando notificación)', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseServiceProvider.overrideWithValue(mockService),
          userProvider.overrideWith(() => MockUserNotifier()),
        ],
      );
      addTearDown(container.dispose);

      // Activar listener de notificaciones
      container.read(chatNotificationProvider);
      
      // Paso 1: Estado vacío
      final eventEmpty = MockDatabaseEvent();
      final snapEmpty = MockDataSnapshot();
      when(() => eventEmpty.snapshot).thenReturn(snapEmpty);
      when(() => snapEmpty.value).thenReturn(null);

      // Paso 2: Nuevo mensaje de Otro
      final rawNew = {
        'msg1': {'text': 'Nuevo', 'author': 'Otro', 'timestamp': 5000},
      };
      final eventNew = MockDatabaseEvent();
      final snapNew = MockDataSnapshot();
      when(() => eventNew.snapshot).thenReturn(snapNew);
      when(() => snapNew.value).thenReturn(rawNew);

      // Verificamos flujo completo de datos en el messageProvider
      // Si esto pasa, significa que chatNotificationProvider también recibió los updates
      expectLater(
        monitorProvider(container),
        emitsInOrder([
          isA<AsyncLoading>(),
          isA<AsyncData>().having((d) => d.value, 'empty', isEmpty),
          isA<AsyncData>().having((d) => d.value.length, 'new msg', 1),
        ]),
      );

      eventController.add(eventEmpty);
      await Future.delayed(Duration.zero);
      eventController.add(eventNew);
    });

    test('No notifica si el mensaje es propio (flujo de datos)', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseServiceProvider.overrideWithValue(mockService),
          userProvider.overrideWith(() => MockUserNotifier()), // Soy "Yo"
        ],
      );
      addTearDown(container.dispose);

      container.read(chatNotificationProvider);

      // 1. Mensaje viejo de otro
      final rawOld = {'msg1': {'text': 'A', 'author': 'Otro', 'timestamp': 1000}};
      final eventOld = MockDatabaseEvent();
      final snapOld = MockDataSnapshot();
      when(() => eventOld.snapshot).thenReturn(snapOld);
      when(() => snapOld.value).thenReturn(rawOld);

      // 2. Mensaje nuevo MÍO
      final rawMine = {
        'msg1': {'text': 'A', 'author': 'Otro', 'timestamp': 1000},
        'msg2': {'text': 'B', 'author': 'Yo', 'timestamp': 2000},
      };
      final eventMine = MockDatabaseEvent();
      final snapMine = MockDataSnapshot();
      when(() => eventMine.snapshot).thenReturn(snapMine);
      when(() => snapMine.value).thenReturn(rawMine);

      expectLater(
        monitorProvider(container),
        emitsInOrder([
          isA<AsyncLoading>(),
          isA<AsyncData>().having((d) => d.value.length, 'old', 1),
          isA<AsyncData>().having((d) => d.value.length, 'mine', 2),
        ]),
      );

      eventController.add(eventOld);
      await Future.delayed(Duration.zero);
      eventController.add(eventMine);
    });
  });
}