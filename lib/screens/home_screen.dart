import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/providers/lost_found_provider.dart';
import 'package:unilink/screens/found_screen.dart';
import 'package:unilink/screens/lost_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniLink'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lost Items'),
            Tab(text: 'Found Items'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both lost and found items
          final lostRefresh = ref.refresh(lostItemsProvider.future);
          final foundRefresh = ref.refresh(foundItemsProvider.future);
          await Future.wait([lostRefresh, foundRefresh]);
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            LostScreen(),
            FoundScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home screen
              break;
            case 1:
              context.go(Routes.notifications);
              break;
            case 2:
              context.go(Routes.profile);
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