import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/src/framework.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/navigation/routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemsList extends ConsumerWidget {
  final AsyncValue<List<LostFoundItem>> items;
  final String emptyMessage;
  final ProviderOrFamily provider;

  const ItemsList({
    super.key,
    required this.items,
    required this.emptyMessage,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return items.when(
      data: (itemsList) {
        // Always wrap the content in RefreshIndicator
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(provider);
          },
          child: itemsList.isEmpty
              ? _buildEmptyState(context)
              : _buildItemsList(context, itemsList),
        );
      },
      error: (error, stackTrace) => _buildErrorState(context, error),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(BuildContext context, List<LostFoundItem> itemsList) {
    return ListView.builder(
      itemCount: itemsList.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item.location)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(item.timestamp),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () => context.push('${Routes.itemDetails}/${item.id}'),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}