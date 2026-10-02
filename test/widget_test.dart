import 'package:flutter_test/flutter_test.dart';
import 'package:ka_ka_ki/app/app.dart';

void main() {
  testWidgets('App launches and displays Home screen elements', (WidgetTester tester) async {
    await tester.pumpWidget(const KaKaKiApp());
    await tester.pumpAndSettle();

    expect(find.text('ka-kā-ki'), findsOneWidget);
    expect(find.text('CREATE ROOM'), findsOneWidget);
    expect(find.text('JOIN ROOM'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });
}
