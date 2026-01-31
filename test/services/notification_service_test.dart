import 'package:app_chat/data/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MockNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
    );
  });

  late MockNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUp(() {
    mockPlugin = MockNotificationsPlugin();
    service = NotificationService(mockPlugin);
  });

  test('init llama a initialize', () async {
    when(() => mockPlugin.initialize(any()))
        .thenAnswer((_) async => true);

    await service.init();

    verify(() => mockPlugin.initialize(any())).called(1);
  });

  test('show llama a plugin.show', () async {
    when(() => mockPlugin.show(
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async {});

    await service.show(
      title: 'Hola',
      body: 'Mensaje',
    );

    verify(() => mockPlugin.show(
          0,
          'Hola',
          'Mensaje',
          any(),
        )).called(1);
  });
}
