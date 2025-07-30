import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        // Force refresh user data from Firestore
        await authProvider.updateUserData({});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    
    // If edit was successful, refresh the profile
    if (result == true) {
      await _refreshProfile();
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        final user = authProvider.user;
        
        // Get display values with fallbacks
        final displayName = userData?['fullName']?.isNotEmpty == true 
            ? userData!['fullName'] 
            : user?.displayName ?? 'User';
        
        final username = userData?['username']?.isNotEmpty == true 
            ? userData!['username'] 
            : user?.displayName ?? '';
            
        final profileImageUrl = userData?['profileImageUrl']?.isNotEmpty == true 
            ? userData!['profileImageUrl'] 
            : user?.photoURL;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _navigateToEditProfile,
                tooltip: 'Edit Profile',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading ? null : _refreshProfile,
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Refreshing profile...'),
                    ],
                  ),
                )
              : EnhancedRefreshIndicator(
                  onRefresh: _refreshProfile,
                  refreshMessage: 'Profile updated successfully!',
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            Stack(
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
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null,
                                    child: profileImageUrl == null || profileImageUrl.isEmpty
                                        ? Text(
                                            _getInitials(displayName),
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                            ),
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
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      onPressed: _navigateToEditProfile,
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            if (username.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '@$username',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Profile Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildProfileTile(
                                icon: Icons.person,
                                title: 'Full Name',
                                subtitle: displayName,
                              ),
                              _buildProfileTile(
                                icon: Icons.alternate_email,
                                title: 'Username',
                                subtitle: username.isNotEmpty ? username : 'Not specified',
                              ),
                              _buildProfileTile(
                                icon: Icons.email,
                                title: 'Email',
                                subtitle: user?.email ?? 'Not available',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Academic Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildProfileTile(
                                icon: Icons.school,
                                title: 'Institution',
                                subtitle: userData?['institution']?.isNotEmpty == true 
                                    ? userData!['institution'] 
                                    : 'Not specified',
                              ),
                              _buildProfileTile(
                                icon: Icons.book,
                                title: 'Field of Study',
                                subtitle: userData?['field']?.isNotEmpty == true 
                                    ? userData!['field'] 
                                    : 'Not specified',
                              ),
                              _buildProfileTile(
                                icon: Icons.calendar_today,
                                title: 'Academic Year',
                                subtitle: userData?['year']?.isNotEmpty == true 
                                    ? userData!['year'] 
                                    : 'Not specified',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Account Statistics
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Statistics',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Monthly Budget:',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'FCFA ${(userData?['monthlyBudget'] ?? 0.0).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Expenses:',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'FCFA ${(userData?['totalExpenses'] ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              if (userData?['createdAt'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Member Since:',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      _formatDate(userData!['createdAt']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToEditProfile,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Unknown';
      }
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
