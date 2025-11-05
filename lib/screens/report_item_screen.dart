import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/lost_found_provider.dart';
import 'package:unilink/providers/notification_provider.dart';

class ReportItemScreen extends ConsumerStatefulWidget {
  const ReportItemScreen({super.key});

  @override
  ConsumerState<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends ConsumerState<ReportItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _type = 'lost';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final item = LostFoundItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        type: _type,
        status: 'active',
      );

      final createdItem = await ref.read(lostFoundServiceProvider).createItem(item);
      
      if (!mounted) return;

      // Create notification for all users
      await NotificationService().createNotification(
        userId: ref.read(lostFoundServiceProvider).getCurrentUserId(),
        title: 'New ${_type.toUpperCase()} Item Reported',
        message: _titleController.text,
        type: _type,
        itemId: createdItem.id,
      );
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item reported successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report ${_type.toUpperCase()} Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'lost',
                  label: Text('Lost'),
                  icon: Icon(Icons.search),
                ),
                ButtonSegment(
                  value: 'found',
                  label: Text('Found'),
                  icon: Icon(Icons.find_in_page),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _type = selection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}