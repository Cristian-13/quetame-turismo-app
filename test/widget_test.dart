import 'package:flutter_test/flutter_test.dart';
import 'package:quetame_turismo/main.dart';

void main() {
  testWidgets('Prueba de humo básica', (WidgetTester tester) async {
    // Construye nuestra app y dispara un frame.
    await tester.pumpWidget(const QuetameTurismoApp());

    // Como estamos en la fase base, solo verificamos que la app compile bien
    // sin buscar el viejo contador.
    expect(find.byType(QuetameTurismoApp), findsOneWidget);
  });
}
