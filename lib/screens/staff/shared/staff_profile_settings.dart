import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/staff_model.dart';

class StaffProfileSettingsTab extends StatefulWidget {
  const StaffProfileSettingsTab({Key? key}) : super(key: key);

  @override
  State<StaffProfileSettingsTab> createState() => _StaffProfileSettingsTabState();
}

class _StaffProfileSettingsTabState extends State<StaffProfileSettingsTab> {
  // Shared switch state
  bool notif1 = true;
  bool notif2 = true;
  bool notif3 = true;
  bool notif4 = true;
  bool notif5 = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final staff = state.currentStaff;
    
    final isKyc = staff?.role == StaffRole.kycDepartment;
    final primaryColor = isKyc ? const Color(0xFF9C27B0) : const Color(0xFFFFC107);
    
    // Dynamic content
    final defaultName = isKyc ? 'KYC Neha' : 'TL Raj Kumar';
    final defaultEmail = isKyc ? 'neha@company.com' : 'rajkumar@company.com';
    
    final n1Label = isKyc ? 'New KYC Assigned' : 'New Loan Request';
    final n2Label = isKyc ? 'KYC Form Submitted' : 'KYC Response Received';
    final n3Label = isKyc ? 'Document Uploaded' : 'Task Due Reminder';
    final n4Label = isKyc ? 'KYC Completed' : 'Loan Processed';
    final n5Label = isKyc ? 'Task Due Reminder' : 'Report Notifications';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withOpacity(0.2),
                          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Placeholder face
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Change Photo', style: TextStyle(color: primaryColor, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField('Full Name', staff?.name ?? defaultName, isDark),
                          const SizedBox(height: 16),
                          _buildInputField('Email', staff?.email ?? defaultEmail, isDark),
                          const SizedBox(height: 16),
                          _buildInputField('Mobile', '9876543210', isDark),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: _buildInputField('Password', '********', isDark, isPassword: true)),
                              const SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text('Change Password', style: TextStyle(color: isKyc ? primaryColor : Colors.blue, fontSize: 14)),
                              )
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isKyc ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 24),
                _buildSwitch(n1Label, notif1, (v) => setState(() => notif1 = v), isDark, primaryColor, !isKyc),
                _buildSwitch(n2Label, notif2, (v) => setState(() => notif2 = v), isDark, primaryColor, !isKyc),
                _buildSwitch(n3Label, notif3, (v) => setState(() => notif3 = v), isDark, primaryColor, !isKyc),
                _buildSwitch(n4Label, notif4, (v) => setState(() => notif4 = v), isDark, primaryColor, !isKyc),
                _buildSwitch(n5Label, notif5, (v) => setState(() => notif5 = v), isDark, primaryColor, !isKyc),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Provider.of<AppStateProvider>(context, listen: false).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, bool isDark, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              if (isPassword) Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : Colors.black54, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged, bool isDark, Color accentColor, bool useBlueThumb) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: useBlueThumb ? Colors.blue[300] : accentColor,
            activeTrackColor: useBlueThumb ? Colors.blue.withOpacity(0.3) : accentColor.withOpacity(0.3),
            inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[600],
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
