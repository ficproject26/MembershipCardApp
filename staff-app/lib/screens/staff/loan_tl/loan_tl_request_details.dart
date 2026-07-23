import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class LoanTlRequestDetailsScreen extends StatefulWidget {
  final LeadModel lead;

  const LoanTlRequestDetailsScreen({super.key, required this.lead});

  @override
  State<LoanTlRequestDetailsScreen> createState() => _LoanTlRequestDetailsScreenState();
}

class _LoanTlRequestDetailsScreenState extends State<LoanTlRequestDetailsScreen> {
  final Color primaryDark = const Color(0xFF0D1B2A);
  final Color cardDark = const Color(0xFF1B263B);
  final Color accentGold = const Color(0xFFFFC107);

  late LeadModel _currentLead;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
  }

  void _copyApplicantDetailsToClipboard(BuildContext context) {
    final lead = _currentLead;
    final sb = StringBuffer();
    sb.writeln("--- LOAN APPLICATION DETAILS ---");
    sb.writeln("Ref ID: ${lead.id}");
    sb.writeln("Status: ${lead.status.name}");
    sb.writeln("Applicant Name: ${lead.customerName ?? 'N/A'}");
    sb.writeln("Mobile Number: ${lead.customerPhone ?? 'N/A'}");
    sb.writeln("Email ID: ${lead.customerEmail ?? 'N/A'}");
    sb.writeln("PAN: ${lead.details['pan'] ?? lead.details['PAN'] ?? 'N/A'}");
    sb.writeln("Date of Birth: ${lead.details['dob'] ?? lead.details['DOB'] ?? 'N/A'}");
    sb.writeln("Address: ${lead.details['address'] ?? lead.details['Address'] ?? 'N/A'}");
    sb.writeln("Loan Type: ${lead.details['loanType'] ?? lead.details['type'] ?? 'Personal Loan'}");
    sb.writeln("Loan Amount: ${lead.details['loanAmount'] ?? lead.details['amount'] ?? 'N/A'}");
    sb.writeln("Tenure: ${lead.details['tenure'] ?? 'N/A'}");
    sb.writeln("Purpose: ${lead.details['purpose'] ?? 'N/A'}");

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.black87, size: 18),
            SizedBox(width: 8),
            Text('Loan details copied to clipboard!', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: accentGold,
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

    String actionButtonText = 'Move to Verify';
    LeadStatus nextStatus = LeadStatus.Stage1Approved;

    if (lead.status == LeadStatus.Pending || lead.status == LeadStatus.Stage1Pending) {
      actionButtonText = 'Move to Verify';
      nextStatus = LeadStatus.Stage1Approved;
    } else if (lead.status == LeadStatus.Stage1Approved || lead.status == LeadStatus.Stage2Pending || lead.status == LeadStatus.KYC_Verified) {
      actionButtonText = 'Send to Bank';
      nextStatus = LeadStatus.Stage2Approved;
    } else if (lead.status == LeadStatus.Stage2Approved || lead.status == LeadStatus.Stage3Pending) {
      actionButtonText = 'Approve Loan';
      nextStatus = LeadStatus.Stage3Approved;
    } else if (lead.status == LeadStatus.Stage3Approved || lead.status == LeadStatus.Approved) {
      actionButtonText = 'Mark Disbursed';
      nextStatus = LeadStatus.Dispatched;
    } else if (lead.status == LeadStatus.Dispatched) {
      actionButtonText = 'Already Disbursed';
    }

    final isDisbursed = lead.status == LeadStatus.Dispatched;
    final isRejected = lead.status == LeadStatus.Rejected || lead.status == LeadStatus.KYC_Rejected || lead.status == LeadStatus.Stage1Rejected || lead.status == LeadStatus.Stage2Rejected;

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
              child: const Icon(Icons.work, color: Color(0xFFFFC107), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Loan TL Portal',
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
            icon: const Icon(Icons.wb_sunny_outlined, color: Colors.amber),
            onPressed: () => state.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Request Details Summary Card matching Screenshot 4
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDisbursed
                              ? Colors.teal.withOpacity(0.2)
                              : isRejected
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isDisbursed
                              ? 'Disbursed'
                              : isRejected
                                  ? 'Rejected'
                                  : (lead.status == LeadStatus.Stage1Approved ? 'With KYC' : lead.status == LeadStatus.Stage2Approved ? 'Bank' : lead.status.name),
                          style: TextStyle(
                            color: isDisbursed ? Colors.teal : (isRejected ? Colors.red : Colors.amber),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ref ID', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                          const SizedBox(height: 2),
                          Text(lead.id, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Applied On', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                          const SizedBox(height: 2),
                          Text(
                            '${lead.dateCreated.day}/${lead.dateCreated.month}/${lead.dateCreated.year}, ${lead.dateCreated.hour}:${lead.dateCreated.minute}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Applicant Details matching Screenshot 4
            Container(
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Applicant Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.amber, size: 18),
                          onPressed: () => _copyApplicantDetailsToClipboard(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow('Applicant Name', lead.customerName ?? 'Rohit Sharma', isDark),
                  _buildDetailRow('Mobile Number', lead.customerPhone ?? '+91 98765 43210', isDark, hasChevron: true),
                  _buildDetailRow('Email ID', lead.customerEmail ?? 'rohit.sharma@email.com', isDark),
                  _buildDetailRow('PAN', lead.details['pan'] ?? lead.details['PAN'] ?? 'ABCDE1234F', isDark, hasChevron: true),
                  _buildDetailRow('Date of Birth', lead.details['dob'] ?? lead.details['DOB'] ?? '15 Aug 1990', isDark, hasChevron: true),
                  _buildDetailRow('Address', lead.details['address'] ?? '123, MG Road, Bangalore, Karnataka - 560001', isDark, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Loan Details matching Screenshot 4
            Container(
              decoration: BoxDecoration(
                color: isDark ? cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Loan Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow('Loan Type', lead.details['loanType'] ?? lead.details['type'] ?? 'Personal Loan', isDark),
                  _buildDetailRow('Loan Amount', lead.details['loanAmount'] ?? lead.details['amount'] ?? '₹5,00,000', isDark, hasChevron: true),
                  _buildDetailRow('Tenure', lead.details['tenure'] ?? '36 Months', isDark),
                  _buildDetailRow('Purpose', lead.details['purpose'] ?? 'Home Renovation', isDark, isLast: true),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Documents"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.red), title: Text('Aadhaar Card.pdf')),
                            ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.blue), title: Text('PAN Card.pdf')),
                            ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.green), title: Text('Bank Statement 6Months.pdf')),
                          ],
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('View Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDisbursed
                      ? null
                      : () {
                          state.verifyLead(lead.id, nextStatus);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Notification"),
                              content: Text('Loan Request ${lead.id} updated to $actionButtonText!'),
                              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      actionButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildDetailRow(String label, String value, bool isDark, {bool hasChevron = false, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasChevron) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? Colors.white10 : Colors.grey[200],
          ),
      ],
    );
  }
}
