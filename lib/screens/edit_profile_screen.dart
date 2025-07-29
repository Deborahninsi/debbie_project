import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _institutionController;
  late TextEditingController _fieldController;
  late TextEditingController _yearController;

  File? _profileImage;
  bool _isLoading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    
    _fullNameController = TextEditingController(text: userData?['fullName'] ?? '');
    _usernameController = TextEditingController(text: userData?['username'] ?? '');
    _institutionController = TextEditingController(text: userData?['institution'] ?? '');
    _fieldController = TextEditingController(text: userData?['field'] ?? '');
    _yearController = TextEditingController(text: userData?['year'] ?? '');
    _currentImageUrl = userData?['profileImageUrl'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _institutionController.dispose();
    _fieldController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_profileImage == null) return _currentImageUrl;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      if (userId == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Upload image if selected
      String? imageUrl = await _uploadImage();

      // Update user data
      await authProvider.updateUserData({
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'institution': _institutionController.text.trim(),
        'field': _fieldController.text.trim(),
        'year': _yearController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                  ? NetworkImage(_currentImageUrl!)
                  : const AssetImage('assets/images/profile_avatar.png') as ImageProvider,
          child: (_profileImage == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
              ? Text(
                  _usernameController.text.isNotEmpty ? _usernameController.text[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        Positioned(
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _pickImage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
            ),
          ),
        )
      ],
    );
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: _buildProfileImage()),
              const SizedBox(height: 24),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(
                  labelText: 'Field of Study',
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
