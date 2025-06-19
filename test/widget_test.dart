import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/main.dart';
import 'package:currency_converter/screen/splash.dart';

void main() {
  testWidgets('App shows SplashScreen initially', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CurrencyConverterApp());

    // Check if SplashScreen widget is present
    expect(find.byType(SplashScreen), findsOneWidget);

    // Wait for all animations and semantics to settle
    await tester.pumpAndSettle();
  });
}
