import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/screens/auth/login_screen.dart';
import 'package:mindmesh/screens/auth/reset_password_form_screen.dart';
import 'package:mindmesh/services/auth_service.dart';
import 'package:mindmesh/themes/app_theme.dart';
import 'package:mindmesh/components/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class PasswordVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const PasswordVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _PasswordVerificationScreenState createState() => _PasswordVerificationScreenState();
}

class _PasswordVerificationScreenState extends ConsumerState<PasswordVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendTimer = 0;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // Start with a 30 second cooldown for resend
    _startResendTimer();
  }
  
  void _startResendTimer() {
    setState(() {
      _resendTimer = 30; // 30 seconds cooldown
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _verificationCodeController.dispose();
    super.dispose();
  }
  
  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Verify the code with the backend first
      final authService = ref.read(authServiceProvider);
      
      // Use our new method to verify without marking as used
      final result = await authService.verifyResetCode(
        widget.email,
        _verificationCodeController.text.trim(),
      );
      
      if (!mounted) return;
      
      if (result['success']) {
        // Code is valid, proceed to the reset password form
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordFormScreen(
              email: widget.email,
              resetCode: _verificationCodeController.text.trim(),
            ),
          ),
        );
      } else {
        // Code is invalid
        setState(() {
          _errorMessage = result['message'] ?? 'Invalid verification code. Please try again or request a new code.';
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resendVerificationCode() async {
    if (_resendTimer > 0 || _isResending) {
      return;
    }
    
    setState(() {
      _isResending = true;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.requestPasswordReset(widget.email);
      
      if (!mounted) return;
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A new verification code has been sent to your email. All previous codes are now invalid.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Start cooldown timer
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to resend verification code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Reset Code'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  Image.asset(
                    'assets/images/logo.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verify Reset Code',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A password reset code has been sent to\n${widget.email}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Verification code input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _verificationCodeController,
                      autoFocus: true,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        activeColor: AppColors.primaryLight,
                        inactiveColor: Colors.grey.shade300,
                        selectedColor: AppColors.primaryLight,
                        selectedFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                      ),
                      enableActiveFill: true,
                      onCompleted: (value) {
                        // Auto-submit when all digits are entered
                        _verifyCode();
                      },
                      beforeTextPaste: (text) {
                        // Allow only numbers
                        if (text != null) {
                          return text.length == 6 && RegExp(r'^[0-9]+$').hasMatch(text);
                        }
                        return false;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Verify button
                  CustomButton(
                    text: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _verifyCode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Resend code
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(_resendTimer > 0 
                        ? 'Resend Code (${_resendTimer}s)'
                        : 'Resend Code'),
                    onPressed: _resendTimer > 0 || _isResending 
                        ? null  // Disable button during cooldown or when resending
                        : _resendVerificationCode,
                    style: TextButton.styleFrom(
                      foregroundColor: _resendTimer > 0 || _isResending
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 