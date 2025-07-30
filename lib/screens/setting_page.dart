import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                // Navigation will be handled automatically by AuthWrapper
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return ListView(
            children: [
              // User Info Section
              if (authProvider.user != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: authProvider.userData?['profileImageUrl'] != null && 
                                         authProvider.userData!['profileImageUrl'].isNotEmpty
                            ? NetworkImage(authProvider.userData!['profileImageUrl'])
                            : null,
                        child: authProvider.userData?['profileImageUrl'] == null || 
                               authProvider.userData!['profileImageUrl'].isEmpty
                            ? Text(
                                authProvider.displayName.isNotEmpty 
                                    ? authProvider.displayName[0].toUpperCase() 
                                    : 'U',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.displayName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authProvider.user!.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],

              // Theme Settings
              SwitchListTile(
                title: const Text("Dark Theme"),
                subtitle: const Text("Toggle between light and dark mode"),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              const Divider(),

              // Account Settings
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                subtitle: const Text("Update your account password"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/change-password'),
              ),
              const Divider(),

              // App Info
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text("Terms & Conditions"),
                subtitle: const Text("Read our terms and conditions"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showTermsDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text("Privacy Policy"),
                subtitle: const Text("Learn about our privacy practices"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showPrivacyDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("About XTrackr"),
                subtitle: const Text("Version 1.0.0"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(),

              // Logout Section
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                subtitle: const Text("Sign out of your account"),
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Keep existing dialog methods...
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              _getTermsAndConditions(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              _getPrivacyPolicy(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'XTrackr',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.track_changes_rounded,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'XTrackr is a comprehensive expense tracking and budget management application designed to help you take control of your finances.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Track daily expenses\n'
          '• Set and manage budgets\n'
          '• Monitor spending patterns\n'
          '• Secure data storage\n'
          '• User-friendly interface',
        ),
      ],
    );
  }

  String _getTermsAndConditions() {
    return '''
TERMS AND CONDITIONS FOR XTRACKR

Last updated: ${DateTime.now().year}

1. ACCEPTANCE OF TERMS
By downloading, installing, or using the XTrackr mobile application ("App"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, do not use the App.

2. DESCRIPTION OF SERVICE
XTrackr is a personal finance management application that allows users to track expenses, manage budgets, and monitor their financial activities. The App is designed to help users maintain better control over their personal finances.

3. USER ACCOUNTS
3.1 You must create an account to use certain features of the App.
3.2 You are responsible for maintaining the confidentiality of your account credentials.
3.3 You agree to provide accurate, current, and complete information during registration.
3.4 You are responsible for all activities that occur under your account.

4. USER RESPONSIBILITIES
4.1 You agree to use the App only for lawful purposes and in accordance with these Terms.
4.2 You will not use the App to engage in any fraudulent, abusive, or otherwise illegal activity.
4.3 You will not attempt to gain unauthorized access to any portion of the App or any other systems or networks.
4.4 You will not upload, post, or transmit any content that is harmful, threatening, abusive, or otherwise objectionable.

5. PRIVACY AND DATA PROTECTION
5.1 Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.
5.2 By using the App, you consent to the collection and use of your information as described in our Privacy Policy.
5.3 We implement appropriate security measures to protect your personal and financial data.

6. FINANCIAL DATA
6.1 The App allows you to input and store personal financial information.
6.2 You acknowledge that the accuracy of financial tracking depends on the accuracy of the data you input.
6.3 We are not responsible for any financial decisions you make based on the information provided by the App.
6.4 The App is for personal use only and should not be considered as professional financial advice.

7. INTELLECTUAL PROPERTY
7.1 The App and its original content, features, and functionality are owned by XTrackr and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.
7.2 You may not reproduce, distribute, modify, create derivative works of, publicly display, publicly perform, republish, download, store, or transmit any of the material on our App without prior written consent.

8. PROHIBITED USES
You may not use the App:
8.1 For any unlawful purpose or to solicit others to perform unlawful acts
8.2 To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances
8.3 To infringe upon or violate our intellectual property rights or the intellectual property rights of others
8.4 To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate
8.5 To submit false or misleading information
8.6 To upload or transmit viruses or any other type of malicious code

9. DISCLAIMERS
9.1 The information on this App is provided on an "as is" basis. To the fullest extent permitted by law, this Company excludes all representations, warranties, conditions, and terms.
9.2 We do not warrant that the App will be uninterrupted, timely, secure, or error-free.
9.3 We do not warrant that the results obtained from the use of the App will be accurate or reliable.

10. LIMITATION OF LIABILITY
10.1 In no event shall XTrackr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages.
10.2 Our liability to you for any cause whatsoever and regardless of the form of the action, will at all times be limited to the amount paid, if any, by you to us for the App during the term of use.

11. INDEMNIFICATION
You agree to defend, indemnify, and hold harmless XTrackr and its licensee and licensors, and their employees, contractors, agents, officers and directors, from and against any and all claims, damages, obligations, losses, liabilities, costs or debt, and expenses (including but not limited to attorney's fees).

12. TERMINATION
12.1 We may terminate or suspend your account and bar access to the App immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever.
12.2 Upon termination, your right to use the App will cease immediately.

13. GOVERNING LAW
These Terms shall be interpreted and governed by the laws of the jurisdiction in which XTrackr operates, without regard to its conflict of law provisions.

14. CHANGES TO TERMS
14.1 We reserve the right, at our sole discretion, to modify or replace these Terms at any time.
14.2 If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect.
14.3 What constitutes a material change will be determined at our sole discretion.

15. CONTACT INFORMATION
If you have any questions about these Terms and Conditions, please contact us at:
Email: support@xtrackr.com
Address: XTrackr Support Team

16. SEVERABILITY
If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.

17. WAIVER
The failure of XTrackr to enforce any right or provision of these Terms will not be considered a waiver of those rights.

18. ENTIRE AGREEMENT
These Terms and our Privacy Policy constitute the sole and entire agreement between you and XTrackr with respect to the App and supersede all prior and contemporaneous understandings, agreements, representations, and warranties.

By using XTrackr, you acknowledge that you have read and understood these Terms and Conditions and agree to be bound by them.
''';
  }

  String _getPrivacyPolicy() {
    return '''
PRIVACY POLICY FOR XTRACKR

Last updated: ${DateTime.now().year}

1. INTRODUCTION
XTrackr ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application XTrackr ("App"). Please read this Privacy Policy carefully.

2. INFORMATION WE COLLECT
2.1 Personal Information
We may collect personal information that you voluntarily provide to us when you:
• Register for an account
• Use the App's features
• Contact us for support
• Participate in surveys or promotions

This information may include:
• Name and username
• Email address
• Profile information (institution, field of study, academic year)
• Profile pictures
• Authentication credentials

2.2 Financial Information
The App allows you to input financial data including:
• Budget amounts
• Expense categories and amounts
• Transaction details
• Savings goals
• Financial preferences

2.3 Usage Information
We automatically collect certain information when you use the App:
• Device information (device type, operating system, unique device identifiers)
• App usage data (features used, time spent, user interactions)
• Log data (IP address, access times, pages viewed)
• Location data (if you grant permission)

2.4 Cookies and Tracking Technologies
We may use cookies, beacons, tags, and scripts to collect and track information and to improve and analyze our App.

3. HOW WE USE YOUR INFORMATION
We use the information we collect to:
3.1 Provide, operate, and maintain the App
3.2 Process your transactions and manage your account
3.3 Improve, personalize, and expand the App
3.4 Understand and analyze how you use the App
3.5 Develop new products, services, features, and functionality
3.6 Communicate with you for customer service, updates, and promotional purposes
3.7 Process your information for our legitimate business interests
3.8 Prevent fraudulent transactions and monitor against theft
3.9 Comply with legal obligations

4. SHARING YOUR INFORMATION
We do not sell, trade, or otherwise transfer your personal information to third parties except in the following circumstances:

4.1 Service Providers
We may share your information with third-party service providers who perform services on our behalf, such as:
• Cloud storage providers
• Analytics services
• Customer support platforms
• Authentication services

4.2 Legal Requirements
We may disclose your information if required to do so by law or in response to valid requests by public authorities.

4.3 Business Transfers
In the event of a merger, acquisition, or sale of assets, your information may be transferred as part of that transaction.

4.4 Consent
We may share your information with your explicit consent.

5. DATA SECURITY
5.1 We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.
5.2 Your financial data is encrypted both in transit and at rest.
5.3 We use secure authentication methods to protect your account.
5.4 Regular security assessments are conducted to identify and address potential vulnerabilities.
5.5 However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.

6. DATA RETENTION
6.1 We retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy.
6.2 We will retain and use your information to comply with legal obligations, resolve disputes, and enforce agreements.
6.3 You may request deletion of your account and associated data at any time.

7. YOUR PRIVACY RIGHTS
Depending on your location, you may have the following rights:
7.1 Access: Request access to your personal information
7.2 Correction: Request correction of inaccurate or incomplete information
7.3 Deletion: Request deletion of your personal information
7.4 Portability: Request transfer of your information to another service
7.5 Restriction: Request restriction of processing your information
7.6 Objection: Object to processing of your information
7.7 Withdraw Consent: Withdraw consent where processing is based on consent

8. CHILDREN'S PRIVACY
8.1 The App is not intended for children under the age of 13.
8.2 We do not knowingly collect personal information from children under 13.
8.3 If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.

9. INTERNATIONAL DATA TRANSFERS
9.1 Your information may be transferred to and processed in countries other than your own.
9.2 We ensure appropriate safeguards are in place for such transfers.
9.3 By using the App, you consent to such transfers.

10. THIRD-PARTY LINKS
10.1 The App may contain links to third-party websites or services.
10.2 We are not responsible for the privacy practices of these third parties.
10.3 We encourage you to read the privacy policies of any third-party sites you visit.

11. CHANGES TO THIS PRIVACY POLICY
11.1 We may update this Privacy Policy from time to time.
11.2 We will notify you of any material changes by posting the new Privacy Policy in the App.
11.3 Changes are effective when posted.
11.4 Your continued use of the App after changes constitutes acceptance of the updated policy.

12. CONTACT INFORMATION
If you have questions or concerns about this Privacy Policy, please contact us at:
Email: privacy@xtrackr.com
Address: XTrackr Privacy Team

13. CALIFORNIA PRIVACY RIGHTS
If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):
13.1 Right to know what personal information is collected
13.2 Right to know whether personal information is sold or disclosed
13.3 Right to say no to the sale of personal information
13.4 Right to access personal information
13.5 Right to equal service and price

14. EUROPEAN PRIVACY RIGHTS
If you are in the European Economic Area (EEA), you have rights under the General Data Protection Regulation (GDPR):
14.1 Lawful basis for processing your information
14.2 Right to access, rectify, or erase your information
14.3 Right to restrict or object to processing
14.4 Right to data portability
14.5 Right to withdraw consent
14.6 Right to lodge a complaint with supervisory authorities

15. DATA PROTECTION OFFICER
For questions about data protection, you may contact our Data Protection Officer at:
Email: dpo@xtrackr.com

16. COOKIES POLICY
16.1 We use cookies and similar technologies to enhance your experience.
16.2 You can control cookie settings through your device settings.
16.3 Disabling cookies may affect App functionality.

17. AUTOMATED DECISION MAKING
17.1 We may use automated systems to analyze your usage patterns.
17.2 This helps us improve the App and provide personalized features.
17.3 You have the right to object to automated decision-making.

By using XTrackr, you acknowledge that you have read and understood this Privacy Policy and agree to the collection and use of your information as described herein.
''';
  }
}
