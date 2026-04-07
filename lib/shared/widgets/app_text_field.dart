import 'package:flutter/material.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.useUnderline = false,
    this.labelTrailing,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final bool useUnderline;
  final Widget? labelTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            if (labelTrailing != null) ...[
              const Spacer(),
              labelTrailing!,
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: !useUnderline,
            fillColor: useUnderline ? Colors.transparent : AppColors.inputFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: useUnderline ? 0 : 20,
              vertical: 16,
            ),
            border: useUnderline
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
            enabledBorder: useUnderline
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
            focusedBorder: useUnderline
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
            errorBorder: useUnderline
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
            focusedErrorBorder: useUnderline
                ? const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error, width: 1.5),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: useUnderline ? 0 : 16,
                      right: 12,
                    ),
                    child: Icon(prefixIcon, size: 20),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minHeight: 20, minWidth: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
