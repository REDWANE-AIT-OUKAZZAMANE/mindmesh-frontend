import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/screens/auth/login_screen.dart';
import 'package:mindmesh/screens/home/home_screen.dart';
import 'package:mindmesh/services/auth_service.dart';
import 'package:mindmesh/themes/app_theme.dart';
import 'package:mindmesh/components/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String username;

  const VerificationScreen({
    Key? key,
    required this.email,
    required this.username,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
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
  
  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.verifyEmail(
        widget.email,
        _verificationCodeController.text.trim()
      );
      
      if (!mounted) return;
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Check if auto-login was successful
        if (result['autoLogin'] == true) {
          // Navigate to home screen if auto-login successful
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          // Navigate to login screen if no auto-login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                initialEmail: widget.email,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Verification failed. Please try again.';
          _isLoading = false;
        });
      }
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
      final result = await authService.resendVerificationCode(
        widget.email,
        widget.username,
      );
      
      if (!mounted) return;
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'A new verification code has been sent to your email'),
            backgroundColor: Colors.green,
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
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog when back is pressed
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Verification'),
            content: const Text('Are you sure you want to cancel the verification process? You will need to verify your email to use the app.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Return to Login'),
              ),
            ],
          ),
        );
        
        // If user confirms, navigate back to login
        if (result == true) {
          if (!mounted) return false;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
          elevation: 0,
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
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A verification code has been sent to\n${widget.email}',
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
                          _verifyEmail();
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
                      text: 'Verify',
                      isLoading: _isLoading,
                      onPressed: _verifyEmail,
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
      ),
    );
  }
} 