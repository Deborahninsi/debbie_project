// settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text("ON", style: TextStyle(color: Colors.white)),
              ),
              title: Text("@obase"),
              subtitle: Text("Email not added\n237671913897"),
              trailing: Icon(Icons.edit),
              isThreeLine: true,
            ),
            Divider(),

            _settingsItem(Icons.qr_code, "QR code (Payment)", "Create & share your QR code"),
            _settingsItem(Icons.support_agent, "Help & Support", "Chat with our team"),
            _settingsItem(Icons.family_restroom, "Next of kin", "Who is seated at your right hand?"),
            _settingsItem(Icons.lock, "Security PIN", "Four digits security pin"),
            _settingsItem(Icons.email_outlined, "Email verification", "Email not added"),
            _settingsItem(Icons.verified_user, "Verify my ID (KYC)", "Show proof of ID"),
            _settingsItem(Icons.account_balance_wallet, "Add Wallet", "Add numbers to wallet"),
            _settingsItem(Icons.alternate_email, "My NkwaTag", "Manage your tag"),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade100,
        child: Icon(icon, color: Colors.teal),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Implement navigation or action
      },
    );
  }
}
