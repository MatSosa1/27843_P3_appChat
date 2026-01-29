import 'package:flutter_test/flutter_test.dart';
import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/domain/models/message.dart';

void main() {
  group('MessageModel Tests', () {
    final testDate = DateTime.now().millisecondsSinceEpoch;
    final testJson = {
      'text': 'Hola mundo',
      'author': 'TestUser',
      'timestamp': testDate,
    };

    test('fromJson crea una instancia válida', () {
      final model = MessageModel.fromJson(testJson);
      
      expect(model.text, 'Hola mundo');
      expect(model.author, 'TestUser');
      expect(model.timestamp, testDate);
    });

    test('toJson crea un mapa válido', () {
      final model = MessageModel(
        text: 'Hola mundo',
        author: 'TestUser',
        timestamp: testDate,
      );

      final json = model.toJson();
      
      expect(json['text'], 'Hola mundo');
      expect(json['author'], 'TestUser');
      expect(json['timestamp'], testDate);
    });

    test('toEntity convierte correctamente a dominio', () {
      final model = MessageModel(
        text: 'Hola',
        author: 'User',
        timestamp: testDate,
      );

      final entity = model.toEntity();

      expect(entity, isA<Message>());
      expect(entity.text, model.text);
      expect(entity.author, model.author);
    });

    test('fromEntity crea un modelo desde dominio', () {
      final entity = Message(
        text: 'Hola',
        author: 'User',
        timestamp: testDate,
      );

      final model = MessageModel.fromEntity(entity);

      expect(model.text, entity.text);
      expect(model.author, entity.author);
    });
  });
}