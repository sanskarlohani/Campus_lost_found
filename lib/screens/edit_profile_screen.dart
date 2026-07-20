import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/providers/user_provider.dart';
import 'package:unilink/utils/avatars.dart';
import 'package:unilink/utils/test_utils.dart';
import 'dart:io' show File;

class EditProfileScreen extends ConsumerStatefulWidget {
  final User? initialUser;

  const EditProfileScreen({super.key, this.initialUser});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sicController;
  late final TextEditingController _yearController;
  late final TextEditingController _semesterController;
  late final TextEditingController _collegeController;
  String? _selectedAvatarUrl;
  XFile? _pickedImage;
  bool _isLoading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser?.name ?? '');
    _sicController = TextEditingController(text: widget.initialUser?.sic ?? '');
    _yearController = TextEditingController(text: widget.initialUser?.year ?? '');
    _semesterController = TextEditingController(text: widget.initialUser?.semester ?? '');
    _collegeController = TextEditingController(text: widget.initialUser?.college ?? '');
    _selectedAvatarUrl = widget.initialUser?.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sicController.dispose();
    _yearController.dispose();
    _semesterController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 400,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _selectedAvatarUrl = null; // Clear avatar if image picked
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _selectedAvatarUrl ?? widget.initialUser?.profileImageUrl ?? '';
      
      final service = ref.read(userServiceProvider);

      // If a new image was picked, upload it
      if (_pickedImage != null) {
        finalImageUrl = await service.uploadProfileImage(_pickedImage!);
      }

      final user = User(
        name: _nameController.text.trim(),
        sic: _sicController.text.trim(),
        year: _yearController.text.trim(),
        semester: _semesterController.text.trim(),
        college: _collegeController.text.trim(),
        profileImageUrl: finalImageUrl,
        karmaPoints: widget.initialUser?.karmaPoints ?? 0,
      );

      await service.updateProfile(user);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        border: Border.all(color: colorScheme.primary, width: 2),
                      ),
                      child: _buildProfilePreview(colorScheme),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Or Choose an Avatar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppAvatars.defaultAvatars.length,
                itemBuilder: (context, index) {
                  final avatarUrl = AppAvatars.defaultAvatars[index];
                  final isSelected = _selectedAvatarUrl == avatarUrl;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarUrl = avatarUrl;
                        _pickedImage = null; // Clear picked image if avatar chosen
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildAvatarItem(avatarUrl, colorScheme),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: 'Enter your full name',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sicController,
              decoration: const InputDecoration(
                labelText: 'SIC / Student ID',
                prefixIcon: Icon(Icons.badge_outlined),
                hintText: 'Enter your student ID',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your SIC' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      hintText: 'e.g. 3rd Year',
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _semesterController,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: Icon(Icons.school_outlined),
                      hintText: 'e.g. 5th Sem',
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collegeController,
              decoration: const InputDecoration(
                labelText: 'College / Department',
                prefixIcon: Icon(Icons.location_city_outlined),
                hintText: 'Enter your college name',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your college' : null,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview(ColorScheme colorScheme) {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return ClipOval(
          child: Image.network(
            _pickedImage!.path,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipOval(
          child: Image.file(
            File(_pickedImage!.path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    
    if (_selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty) {
      return _buildAvatarItem(_selectedAvatarUrl!, colorScheme, size: 120);
    }

    return Icon(Icons.person_outline_rounded, size: 50, color: colorScheme.primary);
  }

  Widget _buildAvatarItem(String url, ColorScheme colorScheme, {double size = 60}) {
    if (TestUtils.isWidgetTest()) {
      return Icon(Icons.face, size: size * 0.8, color: colorScheme.primary);
    }

    final bool isSvg = url.endsWith('.svg') || url.contains('dicebear');
    
    if (isSvg) {
      return SvgPicture.network(
        url,
        width: size,
        height: size,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
        },
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.face,
          size: size * 0.8,
          color: colorScheme.primary,
        ),
      );
    } else {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person, size: size * 0.8, color: colorScheme.primary),
      );
    }
  }
}
