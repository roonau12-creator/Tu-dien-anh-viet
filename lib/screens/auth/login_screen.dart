import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gradient_button.dart';
import '../../services/firebase_service.dart';
import 'register_screen.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await FirebaseService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      brandIcon: Icons.auto_stories_rounded,
      brandTitle: 'Từ điển Việt–Anh',
      brandSubtitle: 'Tra cứu nhanh • Lưu yêu thích • Ghi lịch sử',
      formTitle: 'Đăng nhập',
      formSubtitle: 'Chào mừng bạn quay lại! Tiếp tục khám phá từ vựng nhé.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              validator: AppValidators.validateUsername,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập',
                hintText: 'Ví dụ: nguyenvana',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: AppValidators.validatePassword,
              onFieldSubmitted: (_) => _submitLogin(),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 26),
            GradientButton(
              label: 'Đăng nhập',
              icon: Icons.login_rounded,
              isLoading: _isLoading,
              onPressed: _submitLogin,
            ),
            AuthSwitchLink(
              question: 'Chưa có tài khoản?',
              action: 'Đăng ký ngay',
              onTap: _openRegister,
            ),
          ],
        ),
      ),
    );
  }
}
