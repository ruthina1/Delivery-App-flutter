import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';
import '../../data/models/models.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedUser = UserModel(
        id: _authService.currentUser!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: _selectedImage?.path ?? _authService.currentUser?.avatarUrl,
        favoriteProductIds: _authService.currentUser!.favoriteProductIds,
      );

      _authService.updateProfile(updatedUser);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

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
        title: Text(AppStrings.editProfile, style: AppTextStyles.heading3),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    AppStrings.save,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : _authService.currentUser?.avatarUrl != null
                                  ? Image.file(
                                      File(_authService.currentUser!.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Text('👤', style: TextStyle(fontSize: 50)),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Change Photo',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // Form Fields
              Text(AppStrings.fullName, style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Enter your name', Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  if (value.trim().length > 50) {
                    return 'Name must be less than 50 characters';
                  }
                  // Check for valid name (letters and spaces only)
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),

              Text(AppStrings.email, style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Enter your email', Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final trimmedValue = value.trim();
                  // Email regex pattern
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(trimmedValue)) {
                    return 'Please enter a valid email address';
                  }
                  if (trimmedValue.length > 100) {
                    return 'Email must be less than 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingM),

              Text(AppStrings.phoneNumber, style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSizes.paddingS),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Enter your phone number', Icons.phone_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  final trimmedValue = value.trim();
                  // Remove spaces, dashes, and plus signs for validation
                  final cleanedValue = trimmedValue.replaceAll(RegExp(r'[\s\-+]'), '');
                  
                  // Check if it's all digits
                  if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
                    return 'Phone number must contain only digits';
                  }
                  
                  // Ethiopian phone number validation (9-15 digits)
                  if (cleanedValue.length < 9 || cleanedValue.length > 15) {
                    return 'Phone number must be between 9 and 15 digits';
                  }
                  
                  // Check if it starts with valid Ethiopian mobile prefix
                  if (cleanedValue.startsWith('251')) {
                    // International format: 251XXXXXXXXX (should be 12 digits total)
                    if (cleanedValue.length != 12) {
                      return 'Invalid phone number format';
                    }
                    if (!['2519', '2517'].contains(cleanedValue.substring(0, 4))) {
                      return 'Invalid Ethiopian mobile number';
                    }
                  } else if (cleanedValue.startsWith('0')) {
                    // Local format: 09XXXXXXXXX (should be 10 digits)
                    if (cleanedValue.length != 10) {
                      return 'Invalid phone number format';
                    }
                  } else if (cleanedValue.startsWith('9') || cleanedValue.startsWith('7')) {
                    // Local format without 0: 9XXXXXXXXX (should be 9 digits)
                    if (cleanedValue.length != 9) {
                      return 'Invalid phone number format';
                    }
                  } else {
                    return 'Phone number must start with 0, 9, 7, or +251';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.paddingXL),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(AppStrings.save, style: AppTextStyles.buttonLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}

