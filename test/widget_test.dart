import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../edupath_app/lib/features/auth/login_page.dart';

void main() {
  testWidgets('login screen shows the main hero content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginPage()),
    );

    expect(find.text('EduPath'), findsOneWidget);
    expect(find.text('Welcome Back 👋'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
