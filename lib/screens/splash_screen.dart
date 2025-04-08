import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindmesh/screens/auth/login_screen.dart';
import 'package:mindmesh/screens/home/home_screen.dart';
import 'package:mindmesh/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    // Add a 2-second delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));
    
    // Check authentication using the auth service
    final authService = ref.read(authServiceProvider);
    final isAuthenticated = await authService.isAuthenticated();
    
    if (!mounted) return;
    
    if (isAuthenticated) {
      // Navigate to home screen if authenticated
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Navigate to login screen if not authenticated
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use WillPopScope to prevent the back button from working on the splash screen
    return WillPopScope(
      onWillPop: () async {
        // Don't allow back navigation from splash screen
        // If pressed back here, exit the app
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: 25),
              
              // App name
              Text(
                'MindMesh',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Your second brain',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              const SpinKitPulse(
                color: Colors.purple,
                size: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 