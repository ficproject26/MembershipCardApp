import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

class KycTeamDashboardOverview extends StatefulWidget {
  const KycTeamDashboardOverview({super.key});

  @override
  State<KycTeamDashboardOverview> createState() => _KycTeamDashboardOverviewState();
}

class _KycTeamDashboardOverviewState extends State<KycTeamDashboardOverview> {
  String _selectedTab = 'Pending';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    
    final kycLeads = state.leads.where((l) => l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.KYC_Verified || l.status == LeadStatus.KYC_Rejected).toList();
    final pendingCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Pending).length;
    final completedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Verified).length;
    final rejectedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Rejected).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard, size: 32, color: Color(0xFF9C27B0)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'KYC Dashboard Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, 'Total KYC', '${kycLeads.length}', Icons.folder, isDark, tabId: 'All'),
              _buildStatCard(context, 'Pending', '$pendingCount', Icons.pending_actions, isDark, tabId: 'Pending'),
              _buildStatCard(context, 'Completed', '$completedCount', Icons.check_circle, isDark, tabId: 'Completed'),
              _buildStatCard(context, 'Rejected', '$rejectedCount', Icons.cancel, isDark, tabId: 'Rejected'),
            ],
          ),
          const SizedBox(height: 32),
          _buildRequestOverview(isDark, kycLeads),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final recentActivityWidget = _buildRecentActivity(isDark);
              final chartWidget = _buildStatusChart(isDark);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: recentActivityWidget),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: chartWidget),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    recentActivityWidget,
                    const SizedBox(height: 16),
                    chartWidget,
                  ],
                );
              }
            }
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, bool isDark, {String? tabId}) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 900 ? (width - 48 - 64) / 5 : (width > 600 ? (width - 48 - 32) / 3 : (width - 48 - 16) / 2);

    return GestureDetector(
      onTap: tabId != null ? () => setState(() => _selectedTab = tabId) : null,
      child: SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF9C27B0)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'View all',
              style: TextStyle(fontSize: 12, color: const Color(0xFF9C27B0), decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
      ),
    );
  }
  Widget _buildRecentActivity(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  child: const Icon(Icons.history, color: Color(0xFF9C27B0), size: 16),
                ),
                title: Text('KYC completed for LR09$index', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('${index + 1} hours ago', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KYC Status (This Month)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(color: Colors.orange, value: 18, title: '', radius: 20),
                      PieChartSectionData(color: Colors.blue, value: 6, title: '', radius: 20),
                      PieChartSectionData(color: Colors.green, value: 20, title: '', radius: 20),
                      PieChartSectionData(color: Colors.red, value: 2, title: '', radius: 20),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('28', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    Text('Total', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestOverview(bool isDark, List<LeadModel> kycLeads) {
    final primaryColor = const Color(0xFF9C27B0);
    
    final pendingCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Pending).length;
    final completedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Verified).length;
    final rejectedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Rejected).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KYC Requests Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTab('Pending ($pendingCount)', 'Pending', isDark),
              const SizedBox(width: 24),
              _buildTab('Completed ($completedCount)', 'Completed', isDark),
              const SizedBox(width: 24),
              _buildTab('Rejected ($rejectedCount)', 'Rejected', isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                            hintText: 'Search by Name / Ref ID',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filters'),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.05)),
                  columns: const [
                    DataColumn(label: Text('Ref ID')),
                    DataColumn(label: Text('Service Type')),
                    DataColumn(label: Text('Applicant Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Received Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: kycLeads.where((l) {
                    if (_selectedTab == 'Pending') return l.status == LeadStatus.KYC_Pending;
                    if (_selectedTab == 'Completed') return l.status == LeadStatus.KYC_Verified;
                    if (_selectedTab == 'Rejected') return l.status == LeadStatus.KYC_Rejected;
                    return true;
                  }).map((req) {
                    final statusColor = req.status == LeadStatus.KYC_Pending ? Colors.orange : (req.status == LeadStatus.KYC_Verified ? Colors.green : Colors.red);
                    return DataRow(
                      cells: [
                        DataCell(Text(req.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                        DataCell(Text(req.serviceType, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                        DataCell(Text(req.customerName ?? 'N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                        DataCell(Text(req.details['Loan Amount'] ?? req.details['amount'] ?? 'N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                        DataCell(Text('${req.dateCreated.day}/${req.dateCreated.month}/${req.dateCreated.year}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: statusColor),
                              const SizedBox(width: 6),
                              Text(req.status.name, style: TextStyle(color: statusColor)),
                            ],
                          )
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () => _showActionsDialog(context, req),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Actions'),
                              ),
                            ],
                          )
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareViaEmail(String email, String subject, String body) async {
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(ClipboardData(text: body));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client. Link copied to clipboard!')),
        );
      }
    }
  }

  void _shareToWhatsApp(String phone, String text) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final formattedPhone = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    
    final uri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp. KYC text copied to clipboard!')),
        );
      }
    }
  }

  void _showActionsDialog(BuildContext context, LeadModel lead) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final isDark = state.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentLead = state.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);
            final hasLink = currentLead.kycLink != null && currentLead.kycLink!.isNotEmpty;
            final isKycVerified = currentLead.status == LeadStatus.KYC_Verified;
            
            // Localhost for PC browser testing
            final kycUrl = hasLink ? 'http://localhost:3001/kyc-upload/form/${currentLead.kycLink}' : '';

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
              title: Text(
                'KYC Actions: ${currentLead.customerName ?? "Customer"}',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${currentLead.customerPhone ?? "N/A"}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 4),
                  Text('Email: ${currentLead.customerEmail ?? "N/A"}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 8),
                  Text('Current Status: ${currentLead.status.name}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 16),
                  if (hasLink) ...[
                    Text('KYC Link Generated:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(kycUrl, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    ),
                  ] else ...[
                    Text('No KYC link generated yet. Click below to create one.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                if (!isKycVerified)
                  ElevatedButton(
                    onPressed: () async {
                      final token = await state.generateKycLink(currentLead.id);
                      if (token != null) {
                        setDialogState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('KYC Link generated successfully!')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(hasLink ? 'Regenerate Link' : 'Generate Link'),
                  ),
                if (hasLink)
                  ElevatedButton(
                    onPressed: () {
                      final subject = 'KYC Verification for Loan Request - FIC';
                      final message = 'Dear ${currentLead.customerName},\n\nPlease upload your KYC documents (Aadhaar, PAN, and Photos) to complete your Loan application verification by clicking on this link: $kycUrl\n\nThank you,\nFIC Team';
                      _shareViaEmail(currentLead.customerEmail ?? '', subject, message);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Share via Email'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTab(String title, String tabId, bool isDark) {
    final isSelected = _selectedTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabId;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF9C27B0) : (isDark ? Colors.white54 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String name, String loanType, String amount, String date, String status, Color statusColor, bool isDark) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        DataCell(Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
        DataCell(Text(loanType, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        DataCell(Text(amount, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        DataCell(Text(date, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: statusColor),
              const SizedBox(width: 6),
              Text(status, style: TextStyle(color: statusColor)),
            ],
          )
        ),
        DataCell(
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
            ),
            child: const Text('Start KYC'),
          )
        ),
      ],
    );
  }
}
