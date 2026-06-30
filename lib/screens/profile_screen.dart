import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/providers/auth_provider.dart' as auth;
import 'package:unilink/providers/lost_found_provider.dart' as lost_found;
import 'package:unilink/providers/user_provider.dart' as user_prov;
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
    final userProfile = ref.watch(user_prov.userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await ref.read(auth.authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(Routes.login);
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userProfile.when(
        data: (user) {
          // Check if profile is essentially empty (only name and email from signup)
          final isIncomplete = user == null || 
                              (user.sic.isEmpty && user.college.isEmpty);

          if (isIncomplete) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.2)),
                    const SizedBox(height: 24),
                    const Text(
                      'Profile Incomplete',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete your profile to let others identify you when you find or lose an item.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _editProfile(context, ref, null),
                      child: const Text('Complete Profile'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: () => _editProfile(context, ref, user),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 32),
                _buildInfoSection(context, user),
                const SizedBox(height: 24),
                ref.watch(lost_found.userItemStatsProvider(user.uid)).when(
                  data: (stats) => _buildStatCards(
                    context, 
                    stats['reported'] ?? 0, 
                    stats['found'] ?? 0,
                    user.karmaPoints,
                  ),
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )),
                  error: (_, __) => _buildStatCards(context, 0, 0, user.karmaPoints),
                ),
                const SizedBox(height: 32),
                _buildLeaderboard(context, ref),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(Routes.home);
                break;
              case 1:
                context.go(Routes.notifications);
                break;
              case 2:
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.badge_outlined, 'SIC', user.sic),
          const Divider(height: 32),
          _buildInfoRow(context, Icons.school_outlined, 'Year', user.year),
          const Divider(height: 32),
          _buildInfoRow(context, Icons.calendar_month_outlined, 'Semester', user.semester),
          const Divider(height: 32),
          _buildInfoRow(context, Icons.location_city_outlined, 'College', user.college),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              value.isNotEmpty ? value : 'Not set',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, int reported, int found, int karma) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Posts',
                value: reported.toString(),
                icon: Icons.upload_file_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Resolved',
                value: found.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Karma',
                value: karma.toString(),
                icon: Icons.auto_awesome_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboard(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(user_prov.leaderboardProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.leaderboard_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'Campus Leaderboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: leaderboardAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No users found')),
                );
              }

              // Sort by karma descending
              final sortedUsers = [...users];
              sortedUsers.sort((a, b) => b.karmaPoints.compareTo(a.karmaPoints));

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedUsers.length > 10 ? 10 : sortedUsers.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 70,
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                ),
                itemBuilder: (context, index) {
                  final user = sortedUsers[index];
                  final isTopThree = index < 3;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTopThree 
                          ? (index == 0 ? Colors.amber : (index == 1 ? Colors.grey.shade400 : Colors.brown.shade300))
                          : colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTopThree ? Colors.white : colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user.college,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${user.karmaPoints}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
