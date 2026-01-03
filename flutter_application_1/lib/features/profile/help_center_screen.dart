import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, dynamic>> _faqs = const [
    {
      'question': 'How do I place an order?',
      'answer': 'Browse our menu, add items to your cart, and proceed to checkout. Enter your delivery address and payment method, then confirm your order.',
    },
    {
      'question': 'What are the delivery charges?',
      'answer': 'Delivery is FREE for orders over 1500 ETB. For orders below 1500 ETB, a delivery fee of 50 ETB applies.',
    },
    {
      'question': 'How long does delivery take?',
      'answer': 'Delivery typically takes 25-35 minutes depending on your location and order complexity.',
    },
    {
      'question': 'Can I cancel my order?',
      'answer': 'You can cancel your order within 5 minutes of placing it. After that, please contact our support team.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept Cash on Delivery, Credit Cards, and Mobile Money payments.',
    },
  ];

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
        title: Text(AppStrings.helpCenter, style: AppTextStyles.heading3),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text(
                faq['question'] as String,
                style: AppTextStyles.labelLarge,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Text(
                    faq['answer'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

