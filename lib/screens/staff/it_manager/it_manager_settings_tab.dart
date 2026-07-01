import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';

class ITManagerSettingsTab extends StatelessWidget {
  const ITManagerSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final staff = state.currentStaff;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Manage Your Preferences', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 24),

          const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF162032),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff?.name ?? 'Project Manager', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const Text('Project Manager', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(staff?.email ?? 'pm@example.com', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Account', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF162032),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.lock_outline, 'Change Password'),
                const Divider(color: Colors.white12, height: 1),
                _buildSettingsTile(Icons.notifications_none, 'Notification Settings'),
                const Divider(color: Colors.white12, height: 1),
                _buildSettingsTile(
                  Icons.color_lens_outlined, 
                  'App Theme', 
                  trailingText: state.isDarkMode ? 'Dark' : 'Light',
                  onTap: () => state.toggleTheme(),
                ),
                const Divider(color: Colors.white12, height: 1),
                _buildSettingsTile(Icons.language, 'Language', trailingText: 'English'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Support', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF162032),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSettingsTile(Icons.headset_mic_outlined, 'Help & Support'),
                const Divider(color: Colors.white12, height: 1),
                _buildSettingsTile(Icons.info_outline, 'About App', trailingText: 'Version 1.0.0'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Go back to login screen
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF162032),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 16),
                  Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3B6E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(trailingText, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
