import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/lead_model.dart';
import '../../widgets/glass_card.dart';

class TLLeadsTab extends StatelessWidget {
  const TLLeadsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    // TL only sees Credit Card leads that are Stage1Pending, Stage2Pending, or Stage3Pending
    final pendingLeads = state.leads.where((l) => 
      l.serviceType == 'Credit Card' &&
      (l.status == LeadStatus.Stage1Pending || l.status == LeadStatus.Stage2Pending || l.status == LeadStatus.Stage3Pending)
    ).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.pending_actions, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Credit Card Approvals (${pendingLeads.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: pendingLeads.isEmpty
              ? Center(
                  child: Text(
                    'No pending leads to approve.',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pendingLeads.length,
                  itemBuilder: (context, index) {
                    final lead = pendingLeads[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lead ID: ${lead.id}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    lead.status == LeadStatus.Stage1Pending ? 'Stage 1 Pending' : 
                                    (lead.status == LeadStatus.Stage2Pending ? 'Stage 2 Pending' : 'Stage 3 Pending'),
                                    style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Agent Code: ${lead.agentCode}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                                  onPressed: () {
                                    final buffer = StringBuffer();
                                    buffer.writeln('Lead ID: ${lead.id}');
                                    buffer.writeln('Agent Code: ${lead.agentCode}');
                                    if (lead.customerName != null && lead.customerName!.isNotEmpty) {
                                      buffer.writeln('Customer: ${lead.customerName} (${lead.customerPhone})');
                                    }
                                    for (var e in lead.details.entries) {
                                      buffer.writeln('${e.key}: ${e.value}');
                                    }
                                    if (lead.bankMessage != null && lead.bankMessage!.isNotEmpty) {
                                      buffer.writeln('Bank Message: ${lead.bankMessage}');
                                    }
                                    Clipboard.setData(ClipboardData(text: buffer.toString()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Lead details copied to clipboard!')),
                                    );
                                  },
                                  tooltip: 'Copy Details',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ...lead.details.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 11)),
                                )),
                            if (lead.customerName != null && lead.customerName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Customer: ${lead.customerName} (${lead.customerPhone})', style: const TextStyle(fontSize: 11)),
                            ],
                            if (lead.bankMessage != null && lead.bankMessage!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Bank Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueAccent)),
                              const SizedBox(height: 2),
                              Text('"${lead.bankMessage!}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    LeadStatus rejectStatus = LeadStatus.Rejected;
                                    if (lead.status == LeadStatus.Stage1Pending) rejectStatus = LeadStatus.Stage1Rejected;
                                    else if (lead.status == LeadStatus.Stage2Pending) rejectStatus = LeadStatus.Stage2Rejected;
                                    state.verifyLead(lead.id, rejectStatus, reason: 'Rejected by TL');
                                  },
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    LeadStatus approveStatus = LeadStatus.Approved;
                                    if (lead.status == LeadStatus.Stage1Pending) approveStatus = LeadStatus.Stage1Approved;
                                    else if (lead.status == LeadStatus.Stage2Pending) approveStatus = LeadStatus.Stage2Approved;
                                    state.verifyLead(lead.id, approveStatus);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
