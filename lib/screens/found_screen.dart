import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/providers/lost_found_provider.dart';
import 'package:unilink/widgets/items_list.dart';

class FoundScreen extends ConsumerWidget {
  const FoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foundItems = ref.watch(foundItemsProvider);

    return ItemsList(
      items: foundItems,
      provider: foundItemsProvider,
      emptyMessage: 'No found items reported yet.\nBe the first to report one!',
    );
  }
}
