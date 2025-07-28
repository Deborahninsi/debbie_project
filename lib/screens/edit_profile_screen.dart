import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = 'Deborah Ninsi';
  String email = 'debbie@example.com';
  String institution = 'University of Buea';
  String field = 'Computer Engineering';
  String year = '2024 - 2025';

  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery); // or .camera

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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
              : const AssetImage('assets/images/profile_avatar.png')
          as ImageProvider,
        ),
        Positioned(
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _pickImage,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.6),
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: _buildProfileImage()),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: fullName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (val) => fullName = val ?? '',
              ),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val ?? '',
              ),
              TextFormField(
                initialValue: institution,
                decoration: const InputDecoration(labelText: 'Institution'),
                onSaved: (val) => institution = val ?? '',
              ),
              TextFormField(
                initialValue: field,
                decoration: const InputDecoration(labelText: 'Field of Study'),
                onSaved: (val) => field = val ?? '',
              ),
              TextFormField(
                initialValue: year,
                decoration: const InputDecoration(labelText: 'Academic Year'),
                onSaved: (val) => year = val ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                },
                child: const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
