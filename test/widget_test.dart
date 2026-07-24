import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreamers_movies_app_bv/presentation/screens/movies/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders its loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
