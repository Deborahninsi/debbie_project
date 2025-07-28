import 'package:flutter/material.dart';

class SettingsTabView extends StatelessWidget {
  const SettingsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text('App Settings', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}