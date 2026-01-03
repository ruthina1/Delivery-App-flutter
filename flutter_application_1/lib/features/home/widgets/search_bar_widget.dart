import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.onFilterTap,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7), // Light grey background
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSizes.paddingM),
                  const Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Expanded(
                    child: onTap != null
                        ? Text(
                            AppStrings.searchHint,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                            ),
                          )
                        : TextField(
                            controller: controller,
                            onChanged: onChanged,
                            enabled: enabled,
                            autofocus: autofocus,
                            decoration: InputDecoration(
                              hintText: AppStrings.searchHint,
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textLight,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyles.bodyMedium,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFilterTap ?? () {
            if (onTap != null) {
              onTap!();
            }
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

