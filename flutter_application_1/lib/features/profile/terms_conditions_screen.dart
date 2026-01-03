import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.termsConditions, style: AppTextStyles.heading3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'Last Updated: December 2024',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
            _buildSection(
              'Acceptance of Terms',
              'By using Burger Knight, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use our service.',
            ),
            _buildSection(
              'Ordering',
              'When you place an order, you agree to provide accurate and complete information. We reserve the right to refuse or cancel any order.',
            ),
            _buildSection(
              'Pricing',
              'All prices are displayed in Ethiopian Birr (ETB). Prices are subject to change without notice. We reserve the right to correct pricing errors.',
            ),
            _buildSection(
              'Delivery',
              'We aim to deliver orders within the estimated time. However, delivery times are estimates and may vary due to factors beyond our control.',
            ),
            _buildSection(
              'Refunds',
              'Refunds are processed according to our refund policy. Contact our support team for assistance with refund requests.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

