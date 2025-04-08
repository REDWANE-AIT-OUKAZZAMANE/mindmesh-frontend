import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/models/user.dart';
import 'package:mindmesh/services/auth_service.dart';
import 'package:mindmesh/components/custom_button.dart';
import 'package:mindmesh/themes/app_theme.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please login to view your profile'),
            );
          }
          
          return _buildProfile(context, ref, user);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.fullName.isNotEmpty 
                        ? user.fullName.substring(0, 1).toUpperCase()
                        : user.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          
          // Full Name
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          // Username
          Text(
            '@${user.username}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          
          // Edit Profile Button
          SizedBox(
            width: 200,
            child: CustomButton(
              text: 'Edit Profile',
              icon: Icons.edit,
              isSecondary: true,
              onPressed: () {
                // TODO: Navigate to edit profile
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Info
          _buildInfoSection(context, user),
          const SizedBox(height: 32),
          
          // Stats
          _buildStatsSection(context),
          const SizedBox(height: 32),
          
          // Logout
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Logout',
              isSecondary: true,
              icon: Icons.logout,
              onPressed: () async {
                await ref.read(authServiceProvider).logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          const Divider(),
          _buildInfoItem(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Joined',
            value: user.createdAt != null 
                ? '${user.createdAt?.month}/${user.createdAt?.day}/${user.createdAt?.year}'
                : 'Not available',
          ),
          if (user.roles != null && user.roles!.isNotEmpty) ...[
            const Divider(),
            _buildInfoItem(
              context,
              icon: Icons.verified_user_outlined,
              title: 'Role',
              value: user.roles?.join(', ') ?? 'User',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryLight,
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, '24', 'Thoughts'),
              _buildStatItem(context, '8', 'Connections'),
              _buildStatItem(context, '12', 'Days Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
} 