import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:due_guard/main.dart';
import 'package:due_guard/features/dueguard/presentation/provider/item_provider.dart';

void main() {
  testWidgets('DueGuard app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ItemProvider()..loadItems(),
        child: const DueGuardApp(),
      ),
    );
    // Verify the GetStarted screen appears
    expect(find.text('Get Started'), findsOneWidget);
  });
}
