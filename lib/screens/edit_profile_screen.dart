import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/providers/user_provider.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser?.name ?? '');
    _sicController = TextEditingController(text: widget.initialUser?.sic ?? '');
    _yearController = TextEditingController(text: widget.initialUser?.year ?? '');
    _semesterController = TextEditingController(text: widget.initialUser?.semester ?? '');
    _collegeController = TextEditingController(text: widget.initialUser?.college ?? '');
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = User(
        name: _nameController.text.trim(),
        sic: _sicController.text.trim(),
        year: _yearController.text.trim(),
        semester: _semesterController.text.trim(),
        college: _collegeController.text.trim(),
      );

      await ref.read(userServiceProvider).updateProfile(user);
      
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
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person_outline_rounded, size: 50, color: colorScheme.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ],
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
          ],
        ),
      ),
    );
  }
}
