import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_connect_pro/main.dart';

void main() {
  testWidgets('HRConnectProApp smoke test builds login or shell screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HRConnectProApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial branding is displayed
    expect(find.textContaining('HR Connect Pro'), findsWidgets);
  });
}
