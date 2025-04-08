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