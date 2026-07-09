import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'commission_tab.dart';
import 'membership_tab.dart';
import 'payouts_tab.dart';
import 'staff_tab.dart';

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({Key? key}) : super(key: key);

  void _navigateToScreen(BuildContext context, String title, Widget child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final isDark = Provider.of<AppStateProvider>(context).isDarkMode;
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8F9FC),
            appBar: AppBar(
              title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            body: child,
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, bool isDark, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : Colors.black54),
      onTap: () => _navigateToScreen(context, title, screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final services = [
      'Credit Card',
      'Loan',
      'Jobs',
      'Insurance',
      'IT Projects',
      'BPO Services',
      'App Referral',
      'Plan Upgrade'
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Modules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A3B6E),
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuTile(context, isDark, 'Commission Config', Icons.percent, const AdminCommissionTab()),
            _buildMenuTile(context, isDark, 'Pricing Config', Icons.card_membership, const AdminMembershipTab()),
            _buildMenuTile(context, isDark, 'Staff Management', Icons.manage_accounts, const AdminStaffTab()),
            _buildMenuTile(context, isDark, 'Payouts Management', Icons.account_balance_wallet, const AdminPayoutsTab()),
            const Divider(height: 32, color: Colors.white24),
            Text(
              'Eligible Notes Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A3B6E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Update the notes displayed to agents before they submit a referral for each service.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (ctx, idx) {
                  final service = services[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      borderColor: const Color(0xFFFFC107),
                      borderOpacity: 0.3,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () {
                                  _showEditDialog(context, state, service, state.eligibleNotes[service] ?? '');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.eligibleNotes[service] ?? 'No notes configured.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppStateProvider state, String service, String currentNote) {
    final controller = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Notes: $service'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Eligible Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E)),
              onPressed: () {
                state.updateEligibleNote(service, controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('$service notes updated successfully!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
