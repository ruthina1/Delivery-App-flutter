import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSizes.paddingM),
            Icon(
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
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

