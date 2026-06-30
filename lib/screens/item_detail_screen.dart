import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/lost_found_provider.dart' as lost_found;
import 'package:unilink/providers/user_provider.dart' as user_prov;
import 'package:timeago/timeago.dart' as timeago;

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _isActionLoading = false;

  void _showClaimDialog(LostFoundItem item) {
    final controller = TextEditingController();
    final isLostType = item.type == 'lost';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLostType ? 'I Found This' : 'Claim Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLostType
                  ? 'Send a message to the owner about where you found it or where they can collect it.'
                  : 'Send a message to the finder to prove this item belongs to you.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isLostType 
                  ? 'e.g., I found it near the library cafe, I\'ve kept it at the reception.'
                  : 'e.g., This is my blue bottle with a NASA sticker.',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              
              Navigator.pop(context);
              setState(() => _isActionLoading = true);
              
              try {
                await ref.read(lost_found.lostFoundServiceProvider).claimItem(
                  item.id,
                  controller.text.trim(),
                );
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              } finally {
                if (mounted) setState(() => _isActionLoading = false);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveItem(LostFoundItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Resolved?'),
        content: const Text('This will hide the item from the public list. Use this if the item has been returned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Resolve')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isActionLoading = true);
      try {
        await ref.read(lost_found.lostFoundServiceProvider).resolveItem(item.id);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item marked as resolved'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemAsync = ref.watch(lost_found.itemDetailProvider(widget.itemId));

    return Scaffold(
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found'));
          }

          final timeStr = timeago.format(DateTime.fromMillisecondsSinceEpoch(item.timestamp));
          final isOwner = item.userId == ref.read(lost_found.lostFoundServiceProvider).getCurrentUserId();
          final isResolved = item.status == 'resolved';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        item.type == 'lost' ? Icons.search_rounded : Icons.inventory_2_outlined,
                        size: 100,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isResolved 
                                ? Colors.grey 
                                : (item.type == 'lost' ? Colors.orange : Colors.green)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isResolved ? 'RESOLVED' : item.type.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isResolved 
                                  ? Colors.grey 
                                  : (item.type == 'lost' ? Colors.orange.shade800 : Colors.green.shade800),
                              ),
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(context, Icons.location_on_outlined, 'Location', item.location),
                      const SizedBox(height: 32),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 40),
                      // Reporter Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reported By',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.person, color: colorScheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final reporterAsync = ref.watch(user_prov.otherUserProfileProvider(item.userId));
                                      return reporterAsync.when(
                                        data: (reporter) => Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isOwner 
                                                ? 'You' 
                                                : (reporter?.name ?? 'Community Member'),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            if (reporter != null && reporter.year.isNotEmpty)
                                              Text(
                                                '${reporter.year}, ${reporter.college}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                        loading: () => const Text('Loading...'),
                                        error: (_, __) => const Text('Community Member'),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      bottomSheet: itemAsync.when(
        data: (item) {
          if (item == null || item.status == 'resolved') return const SizedBox.shrink();
          final isOwner = item.userId == ref.read(lost_found.lostFoundServiceProvider).getCurrentUserId();
          
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isActionLoading 
                ? null 
                : (isOwner ? () => _resolveItem(item) : () => _showClaimDialog(item)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwner ? Colors.green : colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isActionLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    isOwner 
                      ? 'Mark as Resolved' 
                      : (item.type == 'lost' ? 'I Found This' : 'Claim Item')
                  ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
