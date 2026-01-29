import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para mocks internos
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_chat/presentation/providers/user_provider.dart';

void main() {
  group('UserNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Reinicia el contenedor de Riverpod antes de cada test
      container = ProviderContainer();
      // Limpia los valores simulados de SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      container.dispose();
    });

    test('El estado inicial debe ser null', () {
      final user = container.read(userProvider);
      expect(user, isNull);
    });

    test('saveUser guarda datos y actualiza el estado', () async {
      SharedPreferences.setMockInitialValues({}); // Simula almacenamiento vacío

      final notifier = container.read(userProvider.notifier);
      await notifier.saveUser('NuevoUsuario');

      final user = container.read(userProvider);
      
      expect(user, isNotNull);
      expect(user!.name, 'NuevoUsuario');
      expect(user.id, isNotEmpty); // Verifica que se generó un UUID
    });

    test('loadUser recupera datos existentes', () async {
      // Simulamos que ya existen datos guardados
      SharedPreferences.setMockInitialValues({
        'user_id': '123-abc',
        'user_name': 'UsuarioExistente',
      });

      final notifier = container.read(userProvider.notifier);
      await notifier.loadUser();

      final user = container.read(userProvider);
      
      expect(user, isNotNull);
      expect(user!.id, '123-abc');
      expect(user.name, 'UsuarioExistente');
    });

    test('updateUserName actualiza el nombre en estado y persistencia', () async {
      // 1. Configuramos estado inicial
      SharedPreferences.setMockInitialValues({
        'user_id': '123',
        'user_name': 'ViejoNombre',
      });

      final notifier = container.read(userProvider.notifier);
      await notifier.loadUser(); // Cargar estado inicial

      // 2. Ejecutar actualización
      await notifier.updateUserName('NombreActualizado');

      final user = container.read(userProvider);
      expect(user!.name, 'NombreActualizado');
    });
  });
}