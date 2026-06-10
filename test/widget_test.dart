import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskai/main.dart';

void main() {
  testWidgets('TaskAI app loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaskAIApp()));
    await tester.pumpAndSettle();

    expect(find.text('TaskAI'), findsOneWidget);
  });
}
