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
  bool _isLoadingData = true;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _institutionController = TextEditingController();
    _fieldController = TextEditingController();
    _yearController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get current user data
      final userData = authProvider.userData;
      final user = authProvider.user;
      
      if (userData != null) {
        setState(() {
          _fullNameController.text = userData['fullName'] ?? user?.displayName ?? '';
          _usernameController.text = userData['username'] ?? user?.displayName ?? '';
          _institutionController.text = userData['institution'] ?? '';
          _fieldController.text = userData['field'] ?? '';
          _yearController.text = userData['year'] ?? '';
          _currentImageUrl = userData['profileImageUrl'];
          _isLoadingData = false;
        });
      } else {
        // No userData available, use Firebase Auth user data as fallback
        setState(() {
          _fullNameController.text = user?.displayName ?? '';
          _usernameController.text = user?.displayName ?? '';
          _currentImageUrl = user?.photoURL;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile data: $e')),
        );
      }
    }
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
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_profileImage == null) return _currentImageUrl;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      if (userId == null) return null;

      // Create a reference to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // Upload the file
      final uploadTask = ref.putFile(_profileImage!);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        throw Exception('No user logged in');
      }

      // Upload image if selected
      String? imageUrl;
      if (_profileImage != null) {
        imageUrl = await _uploadImage();
      } else {
        imageUrl = _currentImageUrl; // Keep existing image URL
      }

      // Prepare update data
      final updateData = {
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'institution': _institutionController.text.trim(),
        'field': _fieldController.text.trim(),
        'year': _yearController.text.trim(),
      };

      // Add image URL if available
      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['profileImageUrl'] = imageUrl;
      }

      // Update user data in Firestore and local state
      await authProvider.updateUserData(updateData);

      // Also update Firebase Auth display name if changed
      if (_fullNameController.text.trim() != authProvider.user?.displayName) {
        await authProvider.user?.updateDisplayName(_fullNameController.text.trim());
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error updating profile: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
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
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 57,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                    ? NetworkImage(_currentImageUrl!)
                    : null,
            child: (_profileImage == null && 
                   (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _isLoading ? null : _pickImage,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading profile data...'),
            ],
          ),
        ),
      );
    }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(child: _buildProfileImage()),
              const SizedBox(height: 8),
              Text(
                'Tap camera icon to change photo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  // Check for valid username characters
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                    return 'Username can only contain letters, numbers, and underscores';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _institutionController,
                decoration: InputDecoration(
                  labelText: 'Institution',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g., University of Cameroon',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fieldController,
                decoration: InputDecoration(
                  labelText: 'Field of Study',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g., Computer Science',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g., 3rd Year or 2024',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
