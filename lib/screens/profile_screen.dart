import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/providers/user_provider.dart' as user_provider;
import 'package:unilink/screens/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _editProfile(BuildContext context, WidgetRef ref, User? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(initialUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(user_provider.userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(
              context,
              ref,
              userProfile.value,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
          ),
        ],
      ),
      body: userProfile.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Complete your profile to get started',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _editProfile(context, ref, null),
                    child: const Text('Complete Profile'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text('SIC'),
                        subtitle: Text(user.sic.isNotEmpty ? user.sic : 'Not set'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Year'),
                        subtitle: Text(user.year.isNotEmpty ? user.year : 'Not set'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Semester'),
                        subtitle: Text(user.semester.isNotEmpty ? user.semester : 'Not set'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_city),
                        title: const Text('College'),
                        subtitle: Text(user.college.isNotEmpty ? user.college : 'Not set'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(Routes.home);
              break;
            case 1:
              context.go(Routes.notifications);
              break;
            case 2:
              // Already on profile
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}