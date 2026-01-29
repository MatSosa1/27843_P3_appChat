import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_chat/presentation/views/username_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('UsernameView valida entrada vacía', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: UsernameView()),
      ),
    );

    // Encuentra el botón y tócalo sin escribir nada
    final button = find.text('Continuar');
    await tester.tap(button);
    await tester.pump(); // Reconstruir UI para mostrar errores

    // Debe aparecer el mensaje de error del validador
    expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
  });

  testWidgets('UsernameView valida nombre muy corto', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: UsernameView()),
      ),
    );

    // Escribe "A" (muy corto)
    await tester.enterText(find.byType(TextFormField), 'A');
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('El nombre debe tener al menos 2 caracteres'), findsOneWidget);
  });

  testWidgets('UsernameView permite continuar con nombre válido', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: UsernameView()),
      ),
    );

    // Escribe un nombre válido
    await tester.enterText(find.byType(TextFormField), 'Marcos');
    await tester.tap(find.text('Continuar'));
    
    // Al haber una operación asíncrona (guardar en prefs), usamos pumpAndSettle
    await tester.pump(); 
    
    // Verificamos que apareció el indicador de carga o intentó navegar
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}