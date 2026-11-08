import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tudienanhviet/core/theme/app_theme.dart';
import 'package:tudienanhviet/core/widgets/gradient_button.dart';
import 'package:tudienanhviet/screens/auth/login_screen.dart';

void main() {
  testWidgets('Màn hình đăng nhập hiển thị đúng các trường nhập liệu',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );

    expect(find.text('Từ điển Việt–Anh'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(GradientButton), findsOneWidget);
    expect(find.textContaining('Đăng ký ngay'), findsOneWidget);
  });
}
