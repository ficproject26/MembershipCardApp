import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/glass_card.dart';
import '../../models/lead_model.dart';

class AdminLeadsTab extends StatelessWidget {
  const AdminLeadsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final pendingLeads = state.leads.where((l) => l.status == LeadStatus.Pending).toList();
    final processedLeads = state.leads.where((l) => l.status != LeadStatus.Pending).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFFFFC107),
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            indicatorColor: const Color(0xFFFFC107),
            tabs: [
              Tab(text: 'Pending (${pendingLeads.length})'),
              Tab(text: 'Processed (${processedLeads.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLeadList(context, pendingLeads, true, state, isDark),
                _buildLeadList(context, processedLeads, false, state, isDark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeadList(
    BuildContext context,
    List<LeadModel> list,
    bool isPending,
    AppStateProvider state,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.check_circle_outline : Icons.assignment_outlined, color: const Color(0xFFFFC107), size: 48),
            const SizedBox(height: 12),
            Text(
              isPending ? 'No pending leads to review' : 'No processed leads found',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final lead = list[idx];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lead.serviceType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  ),
                  Text(
                    'Agent: ${lead.agentCode}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Customer: ${lead.customerName ?? "Pending"}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              Text(
                'Phone: ${lead.customerPhone}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lead.details.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFFFC107)),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        _showRejectDialog(context, state, lead.id);
                      },
                      child: const Text('Reject Lead'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        state.verifyLead(lead.id, LeadStatus.Approved);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lead Approved & Commission Paid!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Approve & Pay Commission', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      lead.status == LeadStatus.Approved ? Icons.check_circle : Icons.cancel,
                      color: lead.status == LeadStatus.Approved ? Colors.green : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lead.status == LeadStatus.Approved
                          ? 'Approved'
                          : 'Rejected: ${lead.rejectionReason ?? "No reason specified"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: lead.status == LeadStatus.Approved ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ).marginOnly(bottom: 12);
      },
    );
  }

  void _showRejectDialog(BuildContext context, AppStateProvider state, String leadId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reject Lead'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                state.verifyLead(leadId, LeadStatus.Rejected, reason: controller.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
