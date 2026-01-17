// lib/ui/components/y_button.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum YButtonVariant { primary, secondary }

class YButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final YButtonVariant variant;

  const YButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = YButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == YButtonVariant.primary;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.surface,
          foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.border),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
