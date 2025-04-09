import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mindmesh/screens/auth/login_screen.dart';
import 'package:mindmesh/screens/auth/register_screen.dart';
import 'package:mindmesh/screens/home/home_screen.dart';
import 'package:mindmesh/screens/splash_screen.dart';
import 'package:mindmesh/themes/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'services/api_service.dart';
import 'package:mindmesh/screens/network_debug_screen.dart';

Future<void> _checkBackendConnectivity() async {
  if (kDebugMode) {
    print('Checking backend connectivity...');
  }
  
  try {
    // 1. Try to resolve DNS
    try {
      final result = await InternetAddress.lookup('mindmesh-backend-yp1t.onrender.com');
      if (kDebugMode) {
        print('DNS lookup result: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DNS lookup error: $e');
      }
    }
    
    // 2. Try a direct HTTP request without any middleware
    try {
      final dio = Dio();
      // Increase timeouts
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      
      dio.options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final response = await dio.get('https://mindmesh-backend-yp1t.onrender.com/api/health');
      if (kDebugMode) {
        print('Direct API call result: ${response.statusCode}');
        print('Response data: ${response.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Direct API call error: $e');
        if (e is DioException) {
          print('Dio error type: ${e.type}');
          print('Dio error message: ${e.message}');
          if (e.response != null) {
            print('Dio error response: ${e.response!.statusCode} - ${e.response!.data}');
          }
        }
      }
    }
    
    // 3. Try a ping
    try {
      final pingArgs = Platform.isWindows 
          ? ['-n', '4', 'mindmesh-backend-yp1t.onrender.com']
          : ['-c', '4', 'mindmesh-backend-yp1t.onrender.com'];
          
      final result = await Process.run('ping', pingArgs);
      if (kDebugMode) {
        print('Ping stdout: ${result.stdout}');
        print('Ping stderr: ${result.stderr}');
        print('Ping exit code: ${result.exitCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ping error: $e');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('General connectivity check error: $e');
    }
  }
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Hive for local storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await _checkBackendConnectivity();
  
  // Run the app
  runApp(
    const ProviderScope(
      child: MindMeshApp(),
    ),
  );
}

class MindMeshApp extends ConsumerWidget {
  const MindMeshApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindMesh',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/debug': (context) => const NetworkDebugScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes here
        if (settings.name?.startsWith('/add-thought') == true) {
          // TODO: Create and return the AddThoughtScreen
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Add Thought Screen - Coming Soon')),
            ),
          );
        }
        if (settings.name?.startsWith('/thought/') == true) {
          // Extract the thought ID from the route
          final thoughtId = settings.name?.split('/').last;
          // TODO: Create and return the ThoughtDetailScreen with the thought ID
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text('Thought Detail Screen - ID: $thoughtId')),
            ),
          );
        }
        
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
} 