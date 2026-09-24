import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ev_butce_takip/main.dart';
import 'package:ev_butce_takip/providers/auth_provider.dart';
import 'package:ev_butce_takip/providers/budget_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final auth = AuthProvider();
    final budget = BudgetProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: budget),
        ],
        child: const EvButceApp(),
      ),
    );

    expect(find.byType(EvButceApp), findsOneWidget);
  });
}
