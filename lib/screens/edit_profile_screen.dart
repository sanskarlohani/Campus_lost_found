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
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sicController,
              decoration: const InputDecoration(
                labelText: 'SIC',
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your SIC';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _semesterController,
              decoration: const InputDecoration(
                labelText: 'Semester',
                prefixIcon: Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your semester';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collegeController,
              decoration: const InputDecoration(
                labelText: 'College',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your college';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}