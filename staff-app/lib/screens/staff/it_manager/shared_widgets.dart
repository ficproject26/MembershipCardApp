import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:provider/provider.dart';

class ITProjectRequestCard extends StatelessWidget {
  final LeadModel lead;

  const ITProjectRequestCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    if (lead.status == LeadStatus.Pending) {
      statusColor = Colors.orange;
      statusText = 'Pending';
    } else if (lead.status == LeadStatus.Stage1Approved || lead.status == LeadStatus.Stage2Approved || lead.status == LeadStatus.Stage3Approved) {
      statusColor = Colors.purple;
      statusText = 'In Progress';
    } else if (lead.status == LeadStatus.Approved) {
      statusColor = Colors.green;
      statusText = 'Approved';
    } else {
      statusColor = Colors.red;
      statusText = 'Rejected';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text('REQ-${lead.id.length > 8 ? lead.id.substring(0, 8).toUpperCase() : lead.id.toString().padLeft(3, '0')}', 
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('High', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_upward, color: Colors.red, size: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white54, size: 12),
                  const SizedBox(width: 4),
                  const Text('21 May 2024', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person_outline, 'Agent:', 'User ${lead.agentCode}'),
                    _buildInfoRow(Icons.business_center_outlined, 'Client:', lead.customerName ?? 'Unknown'),
                    _buildInfoRow(Icons.business_outlined, 'Company:', lead.details['Company Name'] ?? 'N/A'),
                    _buildInfoRow(Icons.folder_outlined, 'Project:', lead.serviceType),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    _buildActionButton(Icons.remove_red_eye_outlined, 'View', Colors.blue, () {
                      _showViewDialog(context, lead);
                    }),
                    _buildActionButton(Icons.people_outline, 'Assign', const Color(0xFFFFC107), () {
                      _showAssignDialog(context);
                    }),
                    _buildActionButton(Icons.check_circle_outline, 'Approve', Colors.green, () {
                      Provider.of<AppStateProvider>(context, listen: false).verifyLead(lead.id, LeadStatus.Stage1Approved);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Project moved to Requirements (Projects Tab)')));
                    }),
                    _buildActionButton(Icons.cancel_outlined, 'Reject', Colors.red, () {
                      Provider.of<AppStateProvider>(context, listen: false).verifyLead(lead.id, LeadStatus.Rejected);
                    }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.05),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  void _showViewDialog(BuildContext context, LeadModel lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162032),
        title: Text('Project Request Details', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${lead.customerName}', style: const TextStyle(color: Colors.white70)),
            Text('Company: ${lead.details['Company Name'] ?? "N/A"}', style: const TextStyle(color: Colors.white70)),
            Text('Contact: ${lead.customerPhone}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('Notes:', style: TextStyle(color: Colors.white)),
            Text(lead.details['Notes'] ?? 'No notes provided by agent.', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162032),
        title: const Text('Assign Developer', style: TextStyle(color: Colors.white)),
        content: const Text('Developer assignment will be connected to the team roster database in the next update.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
