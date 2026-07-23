import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class InsuranceApplicationDetailsScreen extends StatefulWidget {
  final LeadModel lead;

  const InsuranceApplicationDetailsScreen({super.key, required this.lead});

  @override
  State<InsuranceApplicationDetailsScreen> createState() => _InsuranceApplicationDetailsScreenState();
}

class _InsuranceApplicationDetailsScreenState extends State<InsuranceApplicationDetailsScreen> {
  final Color primaryDark = const Color(0xFF0D1B2A);
  final Color cardDark = const Color(0xFF1B263B);
  final Color accentBlue = const Color(0xFF2563EB);

  late LeadModel _currentLead;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
  }

  void _copyCustomerDetailsToClipboard(BuildContext context) {
    final lead = _currentLead;
    final sb = StringBuffer();
    sb.writeln("--- INSURANCE APPLICATION DETAILS ---");
    sb.writeln("Lead ID: ${lead.id}");
    sb.writeln("Status: ${lead.status.name}");
    sb.writeln("Submitted By Agent: ${lead.agentCode}");
    sb.writeln("Customer Name: ${lead.customerName ?? 'N/A'}");
    sb.writeln("Phone: ${lead.customerPhone ?? 'N/A'}");
    sb.writeln("Email: ${lead.customerEmail ?? 'N/A'}");
    sb.writeln("Insurance Type: ${lead.details['insuranceType'] ?? lead.details['type'] ?? 'Health Insurance'}");
    sb.writeln("Sum Insured: ${lead.details['sumInsured'] ?? lead.details['amount'] ?? 'N/A'}");
    sb.writeln("Premium: ${lead.details['premium'] ?? 'N/A'}");
    sb.writeln("Nominee Name: ${lead.details['nomineeName'] ?? 'N/A'}");
    sb.writeln("Address: ${lead.details['address'] ?? 'N/A'}");

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Insurance details copied to clipboard!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final updatedLead = state.leads.firstWhere((l) => l.id == _currentLead.id, orElse: () => _currentLead);
    _currentLead = updatedLead;

    final lead = _currentLead;

    String actionButtonText = 'Verify KYC';
    LeadStatus nextStatus = LeadStatus.Stage1Approved;

    if (lead.status == LeadStatus.Pending || lead.status == LeadStatus.Stage1Pending) {
      actionButtonText = 'Verify KYC';
      nextStatus = LeadStatus.Stage1Approved;
    } else if (lead.status == LeadStatus.Stage1Approved || lead.status == LeadStatus.Stage2Pending) {
      actionButtonText = 'Send to Underwriting';
      nextStatus = LeadStatus.Stage2Approved;
    } else if (lead.status == LeadStatus.Stage2Approved || lead.status == LeadStatus.Stage3Pending || lead.status == LeadStatus.Stage3Approved) {
      actionButtonText = 'Activate Policy';
      nextStatus = LeadStatus.Approved;
    } else if (lead.status == LeadStatus.Approved) {
      actionButtonText = 'Policy Active';
    }

    final isFullyApproved = lead.status == LeadStatus.Approved;
    final isRejected = lead.status == LeadStatus.Rejected || lead.status == LeadStatus.Stage1Rejected || lead.status == LeadStatus.Stage2Rejected;

    final insType = lead.details['insuranceType'] ?? lead.details['type'] ?? 'Health Insurance';

    IconData insIcon = Icons.health_and_safety;
    if (insType.toLowerCase().contains('motor') || insType.toLowerCase().contains('car')) {
      insIcon = Icons.directions_car;
    } else if (insType.toLowerCase().contains('term') || insType.toLowerCase().contains('life')) {
      insIcon = Icons.umbrella;
    } else if (insType.toLowerCase().contains('travel')) {
      insIcon = Icons.card_travel;
    }

    return Scaffold(
      backgroundColor: isDark ? primaryDark : const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3B6E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(insIcon, color: const Color(0xFFFFC107), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Insurance Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF1A3B6E),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lead ID: ${lead.id}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFullyApproved
                              ? Colors.green.withOpacity(0.2)
                              : isRejected
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isFullyApproved
                              ? 'Active'
                              : isRejected
                                  ? 'Rejected'
                                  : (lead.status == LeadStatus.Stage1Approved ? 'KYC Verified' : lead.status == LeadStatus.Stage2Approved ? 'Underwriting' : 'Pending'),
                          style: TextStyle(
                            color: isFullyApproved ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Submitted by Agent: ${lead.agentCode}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                      Text('${lead.dateCreated.day}/${lead.dateCreated.month}/${lead.dateCreated.year}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Applicant Details Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Applicant Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E))),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue, size: 20),
                  onPressed: () => _copyCustomerDetailsToClipboard(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person, 'Name', lead.customerName ?? 'Applicant', isDark),
                  _buildDetailRow(Icons.phone, 'Mobile Number', lead.customerPhone ?? '+91 9876543210', isDark),
                  _buildDetailRow(Icons.email, 'Email ID', lead.customerEmail ?? 'applicant@email.com', isDark),
                  _buildDetailRow(Icons.credit_card, 'PAN / ID', lead.details['pan'] ?? lead.details['PAN'] ?? 'ABCDE1234F', isDark),
                  _buildDetailRow(Icons.home, 'Address', lead.details['address'] ?? 'Bangalore, Karnataka', isDark, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Insurance Details Card
            Text('Policy & Plan Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E))),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.health_and_safety, 'Insurance Type', insType, isDark),
                  _buildDetailRow(Icons.monetization_on, 'Sum Insured', lead.details['sumInsured'] ?? lead.details['amount'] ?? '₹5,00,000', isDark),
                  _buildDetailRow(Icons.payments, 'Annual Premium', lead.details['premium'] ?? '₹12,500 / year', isDark),
                  _buildDetailRow(Icons.person_outline, 'Nominee Name', lead.details['nomineeName'] ?? 'Family Nominee', isDark, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? cardDark : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isRejected
                      ? null
                      : () {
                          state.verifyLead(lead.id, LeadStatus.Rejected, reason: 'Rejected by Insurance TL');
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Notification"),
                              content: Text('Lead ${lead.id} rejected.'),
                              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isFullyApproved
                      ? null
                      : () {
                          state.verifyLead(lead.id, nextStatus);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Notification"),
                              content: Text('Insurance Lead ${lead.id} updated to $actionButtonText!'),
                              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isFullyApproved ? 'Policy Active' : actionButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 14),
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.white10 : Colors.grey[200]),
      ],
    );
  }
}
