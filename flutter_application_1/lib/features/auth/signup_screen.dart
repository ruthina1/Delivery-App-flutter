import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/constants.dart';
import '../../services/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('[SignUpScreen] Starting signup process...');
        
        final success = await _authService.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        debugPrint(' [SignUpScreen] Signup result: $success');
        debugPrint(' [SignUpScreen] AuthService isAuthenticated: ${_authService.isAuthenticated}');
        debugPrint(' [SignUpScreen] AuthService currentUser: ${_authService.currentUser?.email}');

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (mounted && _authService.isAuthenticated) {
            debugPrint(' [SignUpScreen] Navigating to main screen...');
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            debugPrint(' [SignUpScreen] User not authenticated, cannot navigate');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sign up successful but authentication failed. Please sign in.'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } else if (mounted) {
          debugPrint('[SignUpScreen] Signup returned false');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sign up failed. Email may already be registered.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint(' [SignUpScreen] Signup error: $e');
        debugPrint(' [SignUpScreen] Stack trace: $stackTrace');
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          String errorMessage = 'Sign up failed';
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'Email already registered. Please sign in.';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak. Please use a stronger password.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email address. Please check your email.';
          } else {
            errorMessage = 'Sign up failed: ${e.toString()}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else if (!_agreeToTerms && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to Terms and Conditions'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.createAccount, style: AppTextStyles.heading1),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                'Join us and start ordering delicious meals',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXL),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(AppStrings.fullName),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
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
                      
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                          return 'Name can only contain letters and spaces';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildInputLabel(AppStrings.email),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final trimmedValue = value.trim();
                        
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
                    _buildInputLabel(AppStrings.phoneNumber),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '+251 9XX XXX XXXX',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        final trimmedValue = value.trim();
                        
                        final cleanedValue = trimmedValue.replaceAll(RegExp(r'[\s\-+]'), '');
                        
                        
                        if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
                          return 'Phone number must contain only digits';
                        }
                
                        if (cleanedValue.length < 9 || cleanedValue.length > 15) {
                          return 'Phone number must be between 9 and 15 digits';
                        }
                        
                      
                        if (cleanedValue.startsWith('251')) {
                          if (cleanedValue.length != 12) {
                            return 'Invalid phone number format';
                          }
                          if (!['2519', '2517'].contains(cleanedValue.substring(0, 4))) {
                            return 'Invalid Ethiopian mobile number';
                          }
                        } else if (cleanedValue.startsWith('0')) {

                          if (cleanedValue.length != 10) {
                            return 'Invalid phone number format';
                          }
                        } else if (cleanedValue.startsWith('9') || cleanedValue.startsWith('7')) {
                          if (cleanedValue.length != 9) {
                            return 'Invalid phone number format';
                          }
                        } else {
                          return 'Phone number must start with 0, 9, 7, or +251';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildInputLabel(AppStrings.password),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Create a password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (value.length > 50) {
                          return 'Password must be less than 50 characters';
                        }
                        if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                          return 'Password must contain at least one letter';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Password must contain at least one number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    _buildInputLabel(AppStrings.confirmPassword),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall,
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_agreeToTerms && !_isLoading) ? _signUp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          ),
                          elevation: 0,
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
                            : Text(AppStrings.signUp, style: AppTextStyles.buttonLarge),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.signIn,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSizes.paddingS),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: onTogglePassword,
              )
            : null,
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
      ),
      validator: validator,
    );
  }
}

