import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adminapp/app/app.dart';

void main() {
  testWidgets('Admin app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalonAdminApp()));
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
