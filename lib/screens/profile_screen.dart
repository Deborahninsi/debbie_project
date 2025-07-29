import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _refreshProfile(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      // Reload user data from Firestore
      await authProvider.updateUserData({});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        
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
          body: EnhancedRefreshIndicator(
            onRefresh: () => _refreshProfile(context),
            refreshMessage: 'Profile updated successfully!',
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userData?['profileImageUrl'] != null && userData!['profileImageUrl'].isNotEmpty
                            ? NetworkImage(userData['profileImageUrl'])
                            : const AssetImage('assets/images/profile_avatar.png') as ImageProvider,
                        child: userData?['profileImageUrl'] == null || userData!['profileImageUrl'].isEmpty
                            ? Text(
                                authProvider.displayName.isNotEmpty ? authProvider.displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userData?['fullName'] ?? authProvider.displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    authProvider.user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 32),
                _buildProfileTile(
                  icon: Icons.person,
                  title: 'Username',
                  subtitle: userData?['username'] ?? authProvider.displayName,
                ),
                _buildProfileTile(
                  icon: Icons.school,
                  title: 'Institution',
                  subtitle: userData?['institution']?.isEmpty ?? true 
                      ? 'Not specified' 
                      : userData!['institution'],
                ),
                _buildProfileTile(
                  icon: Icons.book,
                  title: 'Field of Study',
                  subtitle: userData?['field']?.isEmpty ?? true 
                      ? 'Not specified' 
                      : userData!['field'],
                ),
                _buildProfileTile(
                  icon: Icons.calendar_today,
                  title: 'Academic Year',
                  subtitle: userData?['year']?.isEmpty ?? true 
                      ? 'Not specified' 
                      : userData!['year'],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Statistics',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monthly Budget:'),
                            Text(
                              'FCFA ${(userData?['monthlyBudget'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Expenses:'),
                            Text(
                              'FCFA ${(userData?['totalExpenses'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
