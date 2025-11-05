import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/providers/lost_found_provider.dart';
import 'package:unilink/widgets/items_list.dart';

class LostScreen extends ConsumerWidget {
  const LostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lostItems = ref.watch(lostItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Items'),
      ),
      body: lostItems.when(
        data: (items) => ItemsList(
          items: AsyncData(items),
          provider: lostItemsProvider,
          emptyMessage: 'No lost items reported yet.\nBe the first to report one!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          if (error.toString().contains('requires an index')) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Setting up the database for first use...\nThis may take a few minutes.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Center(child: Text('Error: $error'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.report),
        child: const Icon(Icons.add),
      ),
    );
  }
}