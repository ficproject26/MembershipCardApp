import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/shared.dart';

class LoanTlDashboardOverview extends StatefulWidget {
  const LoanTlDashboardOverview({super.key});

  @override
  State<LoanTlDashboardOverview> createState() => _LoanTlDashboardOverviewState();
}

class _LoanTlDashboardOverviewState extends State<LoanTlDashboardOverview> {
  String _selectedTab = 'Pending';

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateProvider>(context).isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dashboard_outlined, color: Color(0xFFFFC107)),
              ),
              const SizedBox(width: 12),
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Consumer<AppStateProvider>(
            builder: (context, state, child) {
              final allLeads = state.leads.where((l) => l.serviceType == 'Loan').toList();
              final pendingCount = allLeads.where((l) => l.status == LeadStatus.Pending).length;
              final kycCount = allLeads.where((l) => l.status == LeadStatus.KYC_Pending).length;
              final verifiedCount = allLeads.where((l) => l.status == LeadStatus.KYC_Verified).length;
              final processedCount = allLeads.where((l) => l.status == LeadStatus.Approved || l.status == LeadStatus.Dispatched || l.status == LeadStatus.Process).length;
              final rejectedCount = allLeads.where((l) => l.status == LeadStatus.Rejected || l.status == LeadStatus.KYC_Rejected).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildStatCard('Total Requests', '${allLeads.length}', Icons.description_outlined, Colors.blue, isDark, constraints.maxWidth, tabId: 'All'),
                          _buildStatCard('Pending', '$pendingCount', Icons.pending_actions, Colors.orange, isDark, constraints.maxWidth, tabId: 'Pending'),
                          _buildStatCard('With KYC Team', '$kycCount', Icons.security, const Color(0xFF9C27B0), isDark, constraints.maxWidth, tabId: 'With KYC'),
                          _buildStatCard('Verified', '$verifiedCount', Icons.check_circle_outline, Colors.green, isDark, constraints.maxWidth, tabId: 'Verified'),
                          _buildStatCard('Processed', '$processedCount', Icons.account_balance_wallet_outlined, Colors.cyan, isDark, constraints.maxWidth, tabId: 'Processed'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text('Loan Requests Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('Pending ($pendingCount)', 'Pending', isDark),
                        const SizedBox(width: 24),
                        _buildTab('With KYC Team ($kycCount)', 'With KYC', isDark),
                        const SizedBox(width: 24),
                        _buildTab('Verified ($verifiedCount)', 'Verified', isDark),
                        const SizedBox(width: 24),
                        _buildTab('Processed ($processedCount)', 'Processed', isDark),
                        const SizedBox(width: 24),
                        _buildTab('Rejected ($rejectedCount)', 'Rejected', isDark),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          
          GlassCard(
            padding: const EdgeInsets.all(0),
            child: Column(
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
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                              hintText: 'Search by Name / Mobile / Ref ID',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
                            ),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text('Filters'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all((isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                    columns: const [
                      DataColumn(label: Text('Ref ID')),
                      DataColumn(label: Text('Applicant Name')),
                      DataColumn(label: Text('Loan Type')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Agent Name')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: Provider.of<AppStateProvider>(context).leads.where((l) {
                      if (l.serviceType != 'Loan') return false;
                      if (_selectedTab == 'Pending') return l.status == LeadStatus.Pending;
                      if (_selectedTab == 'With KYC') return l.status == LeadStatus.KYC_Pending;
                      if (_selectedTab == 'Verified') return l.status == LeadStatus.KYC_Verified;
                      if (_selectedTab == 'Processed') return l.status == LeadStatus.Approved || l.status == LeadStatus.Dispatched || l.status == LeadStatus.Process;
                      if (_selectedTab == 'Rejected') return l.status == LeadStatus.Rejected || l.status == LeadStatus.KYC_Rejected;
                      return true;
                    }).map((req) {
                      return DataRow(
                        cells: [
                          DataCell(Text(req.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                          DataCell(Text(req.customerName ?? 'N/A', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                          DataCell(Text(req.details['Type of Loan'] ?? req.details['loanType'] ?? 'N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                          DataCell(Text(req.details['Loan Amount'] ?? req.details['amount'] ?? 'N/A', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                          DataCell(Text(req.agentName ?? req.agentCode, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                          DataCell(Text('${req.dateCreated.day}/${req.dateCreated.month}/${req.dateCreated.year}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, size: 8, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(req.status.name, style: const TextStyle(color: Colors.orange)),
                              ],
                            ),
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _showRequestDetails(context, req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('View Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chevron_left, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 8),
                      _buildPageDot('1', true, isDark),
                      const SizedBox(width: 8),
                      _buildPageDot('2', false, isDark),
                      const SizedBox(width: 8),
                      _buildPageDot('3', false, isDark),
                      const SizedBox(width: 8),
                      Text('...', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                      const SizedBox(width: 8),
                      _buildPageDot('9', false, isDark),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Bottom Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final recentActivity = _buildRecentActivity(isDark);
              final requestStatus = _buildRequestStatus(isDark);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: recentActivity),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: requestStatus),
                  ],
                );
              } else {
                return Column(
                  children: [
                    recentActivity,
                    const SizedBox(height: 16),
                    requestStatus,
                  ],
                );
              }
            }
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, bool isDark, double maxWidth, {String? tabId}) {
    double cardWidth = 200;
    if (maxWidth > 1000) {
      cardWidth = (maxWidth - (16 * 4)) / 5;
    } else if (maxWidth > 600) cardWidth = (maxWidth - (16 * 2)) / 3;
    else cardWidth = (maxWidth - 16) / 2;

    return GestureDetector(
      onTap: tabId != null ? () => setState(() => _selectedTab = tabId) : null,
      child: SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54), maxLines: 1)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text('View all', style: TextStyle(fontSize: 12, color: Colors.blue[400])),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTab(String title, String tabId, bool isDark) {
    final isSelected = _selectedTab == tabId;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabId),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFC107) : (isDark ? Colors.white54 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPageDot(String number, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFC107) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? Colors.black : (isDark ? Colors.white : Colors.black),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          _buildActivityTimelineItem('LR1001 forwarded to KYC Team', '10 mins ago', isDark),
          _buildActivityTimelineItem('LR1000 verified by KYC Team', '1 hour ago', isDark),
          _buildActivityTimelineItem('LR0998 processed successfully', '3 hours ago', isDark, isLast: true),
        ],
      ),
    );
  }

  Widget _buildActivityTimelineItem(String title, String time, bool isDark, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDark ? Colors.white12 : Colors.black12,
              )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRequestStatus(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request Status (This Month)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(color: Colors.orange, value: 35, title: '', radius: 15),
                            PieChartSectionData(color: const Color(0xFF9C27B0), value: 22, title: '', radius: 15),
                            PieChartSectionData(color: Colors.green, value: 25, title: '', radius: 15),
                            PieChartSectionData(color: Colors.cyan, value: 18, title: '', radius: 15),
                            PieChartSectionData(color: Colors.red, value: 2, title: '', radius: 15),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('128', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          Text('Total', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend('Pending', '45 (35%)', Colors.orange, isDark),
                      const SizedBox(height: 8),
                      _buildLegend('With KYC', '28 (22%)', const Color(0xFF9C27B0), isDark),
                      const SizedBox(height: 8),
                      _buildLegend('Verified', '32 (25%)', Colors.green, isDark),
                      const SizedBox(height: 8),
                      _buildLegend('Processed', '23 (18%)', Colors.cyan, isDark),
                      const SizedBox(height: 8),
                      _buildLegend('Rejected', '2 (2%)', Colors.red, isDark),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegend(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  void _showRequestDetails(BuildContext context, LeadModel req) {
    final isDark = Provider.of<AppStateProvider>(context, listen: false).isDarkMode;
    final cardBg = isDark ? const Color(0xFF1C2541) : Colors.white;
    const yellow = Color(0xFFFFC107);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: yellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_outlined, color: yellow, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Request Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          Text('Ref: ${req.id.substring(0, 8)}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Text(req.status.name, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.white12 : Colors.black12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Applicant Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Name', req.customerName ?? 'N/A', isDark),
                      const SizedBox(height: 10),
                      _buildDetailRow('Phone', req.customerPhone ?? 'N/A', isDark),
                      const SizedBox(height: 10),
                      _buildDetailRow('Email', req.customerEmail ?? req.details['email'] ?? 'N/A', isDark),
                      const SizedBox(height: 20),
                      Text('Loan Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Loan Type', req.details['Type of Loan'] ?? req.details['loanType'] ?? 'N/A', isDark),
                      const SizedBox(height: 10),
                      _buildDetailRow('Amount', req.details['Loan Amount'] ?? req.details['amount'] ?? 'N/A', isDark),
                      const SizedBox(height: 10),
                      _buildDetailRow('Agent', req.agentName ?? req.agentCode, isDark),
                      const SizedBox(height: 10),
                      _buildDetailRow('Date', '${req.dateCreated.day}/${req.dateCreated.month}/${req.dateCreated.year}', isDark),
                      const SizedBox(height: 28),
                      Text('Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.security, size: 18),
                          label: const Text('Forward to KYC Team', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Provider.of<AppStateProvider>(context, listen: false)
                                .updateLeadStatus(req.id, 'KYC_Pending');
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request forwarded to KYC Team ✅'),
                                backgroundColor: Color(0xFF1976D2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Reject Request', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Provider.of<AppStateProvider>(context, listen: false)
                                .updateLeadStatus(req.id, 'Rejected');
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request rejected'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ],
    );
  }
}
