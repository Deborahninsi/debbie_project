import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile_avatar.png'),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Deborah Ninsi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'debbie@example.com',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Divider(height: 32),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Institution'),
            subtitle: Text('University of Buea'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Field of Study'),
            subtitle: Text('Computer Engineering'),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Academic Year'),
            subtitle: Text('2024 - 2025'),
          ),
        ],
      ),
    );
  }
}
