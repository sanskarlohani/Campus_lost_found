import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/lost_found_provider.dart' as lost_found;
import 'package:unilink/providers/notification_provider.dart';
import 'package:unilink/widgets/glass_container.dart';

class ReportItemScreen extends ConsumerStatefulWidget {
  const ReportItemScreen({super.key});

  @override
  ConsumerState<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends ConsumerState<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _type = 'lost';
  bool _isLoading = false;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        // Compress image a little: reducing quality and size for storage efficiency
        imageQuality: 50, 
        maxWidth: 800,
      );
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = '';
      final service = ref.read(lost_found.lostFoundServiceProvider);

      // 1. Upload image if exists with type-based folder
      if (_pickedImage != null) {
        imageUrl = await service.uploadItemImage(File(_pickedImage!.path), _type);
      }

      // 2. Create item
      final item = LostFoundItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        type: _type,
        status: 'active',
        imageUrl: imageUrl,
      );

      final createdItem = await service.createItem(item);
      
      if (!mounted) return;

      // Create a global notification
      await NotificationService().createNotification(
        userId: service.getCurrentUserId(),
        title: 'New ${_type.toUpperCase()} Item Reported',
        message: _titleController.text,
        type: _type,
        itemId: createdItem.id,
        isGlobal: true,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item reported successfully as $_type'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help the Community',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide details about the item you lost or found.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: colorScheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                'Add a Photo',
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                              ),
                              const Text(
                                'Increases chances of success by 70%',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (_pickedImage != null)
                TextButton.icon(
                  onPressed: () => setState(() => _pickedImage = null),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove Photo'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              const SizedBox(height: 32),
              
              // Type Selector
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Lost',
                      icon: Icons.search_rounded,
                      isSelected: _type == 'lost',
                      color: Colors.orange,
                      onTap: () => setState(() => _type = 'lost'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeButton(
                      label: 'Found',
                      icon: Icons.inventory_2_outlined,
                      isSelected: _type == 'found',
                      color: Colors.green,
                      onTap: () => setState(() => _type = 'found'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Blue Water Bottle',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Library 2nd Floor',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add more details (color, brand, etc.)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'lost' ? Colors.orange : Colors.green,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Submit ${_type.toUpperCase()} Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 16,
        blur: isSelected ? 5 : 15,
        opacity: isSelected ? 0.8 : 0.05,
        color: color,
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
