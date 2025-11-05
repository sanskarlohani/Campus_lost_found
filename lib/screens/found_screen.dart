import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:unilink/providers/lost_found_provider.dart';
import 'package:unilink/widgets/items_list.dart';

class FoundScreen extends ConsumerWidget {
  const FoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foundItems = ref.watch(foundItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
      ),
      body: ItemsList(
        items: foundItems,
        provider: foundItemsProvider,
        emptyMessage: 'No found items reported yet.\nBe the first to report one!',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.report),
        child: const Icon(Icons.add),
      ),
    );
  }
}