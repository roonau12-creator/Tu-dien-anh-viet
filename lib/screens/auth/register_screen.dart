import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/gradient_button.dart';
import '../../services/firebase_service.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await FirebaseService.register(
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      brandIcon: Icons.person_add_alt_1_rounded,
      brandTitle: 'Tham gia ngay',
      brandSubtitle: 'Lưu lại những từ vựng bạn yêu thích',
      formTitle: 'Tạo tài khoản',
      formSubtitle: 'Chỉ mất một phút để bắt đầu xây dựng vốn từ của bạn.',
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
              textInputAction: TextInputAction.next,
              validator: AppValidators.validatePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Ít nhất 6 ký tự',
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
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              validator: (val) => AppValidators.validateConfirmPassword(
                val,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) => _submitRegister(),
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  tooltip: _obscureConfirm ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
            ),
            const SizedBox(height: 26),
            GradientButton(
              label: 'Đăng ký',
              icon: Icons.how_to_reg_rounded,
              isLoading: _isLoading,
              onPressed: _submitRegister,
            ),
            AuthSwitchLink(
              question: 'Đã có tài khoản?',
              action: 'Đăng nhập',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
