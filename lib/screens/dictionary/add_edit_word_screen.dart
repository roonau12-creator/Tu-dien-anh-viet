import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/utils/validators.dart';
import '../../models/word_entry.dart';
import '../../services/firebase_service.dart';

class AddEditWordScreen extends StatefulWidget {
  final WordEntry? existingWord;

  const AddEditWordScreen({super.key, this.existingWord});

  @override
  State<AddEditWordScreen> createState() => _AddEditWordScreenState();
}

class _AddEditWordScreenState extends State<AddEditWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _viController;
  late final TextEditingController _enController;
  late final TextEditingController _typeController;
  late final TextEditingController _exampleController;

  bool get _isEditing => widget.existingWord != null;
  bool _isLoading = false;

  static const List<String> _commonWordTypes = [
    'Danh từ',
    'Động từ',
    'Tính từ',
    'Trạng từ',
    'Đại từ',
    'Giới từ',
    'Thán từ',
  ];

  @override
  void initState() {
    super.initState();
    _viController = TextEditingController(
      text: widget.existingWord?.vietnamese ?? '',
    );
    _enController = TextEditingController(
      text: widget.existingWord?.english ?? '',
    );
    _typeController = TextEditingController(
      text: widget.existingWord?.wordType ?? 'Danh từ',
    );
    _exampleController = TextEditingController(
      text: widget.existingWord?.example ?? '',
    );
  }

  @override
  void dispose() {
    _viController.dispose();
    _enController.dispose();
    _typeController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await FirebaseService.saveWord(
      existingId: widget.existingWord?.id,
      vietnamese: _viController.text,
      english: _enController.text,
      wordType: _typeController.text,
      example: _exampleController.text,
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
        SnackBar(
          content: Text(
            _isEditing
                ? 'Đã cập nhật mục từ thành công!'
                : 'Đã thêm mục từ mới vào từ điển!',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa mục từ' : 'Thêm mục từ mới'),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppTheme.softShadow,
              ),
              child: IconButton(
                tooltip: 'Quay lại',
                onPressed: () => Navigator.maybePop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPreview(),
                  const SizedBox(height: 18),
                  _SectionCard(
                    icon: Icons.translate_rounded,
                    title: 'Thông tin mục từ',
                    subtitle: 'Nhập cặp từ Việt – Anh và chọn loại từ.',
                    children: [
                      TextFormField(
                        controller: _viController,
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            AppValidators.requiredField(val, 'từ tiếng Việt'),
                        decoration: const InputDecoration(
                          labelText: 'Từ tiếng Việt *',
                          hintText: 'Ví dụ: máy tính',
                          prefixIcon: Icon(Icons.translate_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _enController,
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            AppValidators.requiredField(val, 'từ tiếng Anh'),
                        decoration: const InputDecoration(
                          labelText: 'Từ tiếng Anh *',
                          hintText: 'Ví dụ: computer',
                          prefixIcon: Icon(Icons.language_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _typeController,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (val) =>
                            AppValidators.requiredField(val, 'loại từ'),
                        decoration: const InputDecoration(
                          labelText: 'Loại từ *',
                          hintText: 'Danh từ, Động từ...',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonWordTypes.map((type) {
                          final selected = _typeController.text == type;
                          return _TypeChip(
                            label: type,
                            selected: selected,
                            onTap: () =>
                                setState(() => _typeController.text = type),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.format_quote_rounded,
                    gradient: AppTheme.skyGradient,
                    title: 'Câu ví dụ',
                    subtitle: 'Thêm một câu ví dụ để dễ ghi nhớ hơn.',
                    children: [
                      TextFormField(
                        controller: _exampleController,
                        maxLines: 3,
                        validator: (val) =>
                            AppValidators.requiredField(val, 'câu ví dụ'),
                        decoration: const InputDecoration(
                          labelText: 'Câu ví dụ *',
                          hintText: 'Ví dụ: I use a computer to write code.',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  GradientButton(
                    label: _isEditing ? 'Lưu thay đổi' : 'Thêm vào từ điển',
                    icon: _isEditing
                        ? Icons.check_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                    isLoading: _isLoading,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Thẻ xem trước trực tiếp mục từ đang nhập.
  Widget _buildPreview() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _viController,
        _enController,
        _typeController,
      ]),
      builder: (context, _) {
        final vi = _viController.text.trim();
        final en = _enController.text.trim();
        final type = _typeController.text.trim();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl - 4),
            boxShadow: AppTheme.glowShadow(),
          ),
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  right: -70,
                  top: -70,
                  child: GlowBlob(
                    size: 180,
                    color: Colors.white,
                    opacity: 0.22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'XEM TRƯỚC',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const Spacer(),
                        if (type.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      vi.isEmpty ? 'Từ tiếng Việt' : vi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: vi.isEmpty ? 0.5 : 1),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            en.isEmpty ? 'English word' : en,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: en.isEmpty ? 0.5 : 0.92),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Mã mục từ: ${widget.existingWord!.id}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.brandGradient : null,
          color: selected ? null : AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Gradient gradient;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.gradient = AppTheme.brandGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconBox(
                icon: icon,
                gradient: gradient,
                size: 40,
                iconSize: 20,
                radius: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
