import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/components/custom_bottom_nav.dart';
import 'package:mindmesh/screens/home/tabs/dashboard_tab.dart';
import 'package:mindmesh/screens/home/tabs/mind_map_tab.dart';
import 'package:mindmesh/screens/home/tabs/profile_tab.dart';
import 'package:mindmesh/screens/home/tabs/thoughts_tab.dart';
import 'package:mindmesh/services/auth_service.dart';

// Provider for tracking the current tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    
    // Get the current user
    final currentUserAsync = ref.watch(currentUserProvider);

    return WillPopScope(
      // Handle the back button press
      onWillPop: () async {
        // Show a confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
        
        // If user confirms, exit the app
        if (shouldExit) {
          SystemNavigator.pop();
        }
        
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        body: currentUserAsync.when(
          data: (user) {
            if (user == null) {
              // Handle not logged in state - should rarely happen as this 
              // is protected by the splash screen auth check
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(authServiceProvider).logout().then((_) {
                  Navigator.of(context).pushReplacementNamed('/login');
                });
              });
              
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            // Show the appropriate tab based on selected index
            return IndexedStack(
              index: selectedTab,
              children: const [
                DashboardTab(),
                ThoughtsTab(),
                MindMapTab(),
                ProfileTab(),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading user data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authServiceProvider).logout().then((_) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Return to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(),
        floatingActionButton: selectedTab == 1 
            ? FloatingActionButton(
                onPressed: () {
                  // Navigate to add thought screen
                  Navigator.of(context).pushNamed('/add-thought');
                },
                child: const Icon(Icons.add),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
} 