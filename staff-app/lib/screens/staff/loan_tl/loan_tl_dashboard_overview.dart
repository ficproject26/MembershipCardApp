import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/shared.dart';
import 'loan_tl_request_details.dart';

class LoanTlDashboardOverview extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const LoanTlDashboardOverview({super.key, this.onNavigateToTab});

  @override
  State<LoanTlDashboardOverview> createState() => _LoanTlDashboardOverviewState();
}

class _LoanTlDashboardOverviewState extends State<LoanTlDashboardOverview> {
  final Color primaryDark = const Color(0xFF0D1B2A);
  final Color cardDark = const Color(0xFF1B263B);
  final Color accentGold = const Color(0xFFFFC107);

  String _timeRange = 'This Month';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final loanLeads = state.leads.where((l) =>
      l.serviceType == 'Loan' || (l.serviceType != null && l.serviceType.toLowerCase().contains('loan'))
    ).toList();

    final pendingCount = loanLeads.where((l) => l.status == LeadStatus.Pending).length;
    final verifyCount = loanLeads.where((l) => l.status == LeadStatus.Stage1Approved || l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.KYC_Verified).length;
    final bankCount = loanLeads.where((l) => l.status == LeadStatus.Stage2Approved).length;
    final approvedCount = loanLeads.where((l) => l.status == LeadStatus.Stage3Approved || l.status == LeadStatus.Approved).length;
    final disbursedCount = loanLeads.where((l) => l.status == LeadStatus.Dispatched).length;
    final rejectedCount = loanLeads.where((l) => l.status == LeadStatus.Rejected || l.status == LeadStatus.KYC_Rejected || l.status == LeadStatus.Stage1Rejected || l.status == LeadStatus.Stage2Rejected || l.status == LeadStatus.Stage3Rejected).length;

    final totalCount = loanLeads.isEmpty ? 128 : loanLeads.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner matching Screenshot 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Agent FIC1810',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Here's what's happening with your loan pipeline today.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3B6E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.analytics, color: Color(0xFFFFC107), size: 36),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Header
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A3B6E),
            ),
          ),
          const SizedBox(height: 14),

          // 2-Column Grid of Overview Stat Cards matching Screenshot 1
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _buildOverviewCard('All Requests', loanLeads.isEmpty ? '18' : '${loanLeads.length}', Icons.description, Colors.blue, isDark),
              _buildOverviewCard('Pending', '$pendingCount', Icons.access_time, Colors.orange, isDark),
              _buildOverviewCard('Verify', '$verifyCount', Icons.shield, Colors.amber, isDark),
              _buildOverviewCard('Bank', '$bankCount', Icons.account_balance, Colors.purple, isDark),
              _buildOverviewCard('Approved', '$approvedCount', Icons.check_circle_outline, Colors.green, isDark),
              _buildOverviewCard('Disbursed', '$disbursedCount', Icons.attach_money, Colors.teal, isDark),
            ],
          ),
          const SizedBox(height: 14),
          _buildOverviewCardFullWidth('Rejected', '$rejectedCount', Icons.cancel_outlined, Colors.red, isDark),
          const SizedBox(height: 24),

          // Quick Actions Section matching Screenshot 1
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A3B6E),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildQuickActionButton(Icons.add_circle_outline, 'New Request', isDark, () {}),
              const SizedBox(width: 10),
              _buildQuickActionButton(Icons.search, 'Search', isDark, () {
                if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
              }),
              const SizedBox(width: 10),
              _buildQuickActionButton(Icons.person_outline, 'KYC Queue', isDark, () {
                if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
              }),
              const SizedBox(width: 10),
              _buildQuickActionButton(Icons.bar_chart, 'Reports', isDark, () {
                if (widget.onNavigateToTab != null) widget.onNavigateToTab!(3);
              }),
            ],
          ),
          const SizedBox(height: 28),

          // Loan Requests Overview Donut Chart Card matching Screenshot 2
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Requests Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 14),

                // Filter Pills: This Month, This Week, Today
                Row(
                  children: [
                    _buildTimePill('This Month', isDark),
                    const SizedBox(width: 8),
                    _buildTimePill('This Week', isDark),
                    const SizedBox(width: 8),
                    _buildTimePill('Today', isDark),
                  ],
                ),
                const SizedBox(height: 24),

                // Donut Chart & Legend Row matching Screenshot 2
                Row(
                  children: [
                    // Donut Chart
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 45,
                              sections: [
                                PieChartSectionData(color: Colors.orange, value: 35, title: '', radius: 18),
                                PieChartSectionData(color: Colors.purple, value: 22, title: '', radius: 18),
                                PieChartSectionData(color: Colors.green, value: 25, title: '', radius: 18),
                                PieChartSectionData(color: Colors.blue, value: 18, title: '', radius: 18),
                                PieChartSectionData(color: Colors.red, value: 2, title: '', radius: 18),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$totalCount',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Total',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Legend List matching Screenshot 2
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow(Colors.orange, 'Pending', '45 (35%)', isDark),
                          _buildLegendRow(Colors.purple, 'With KYC', '28 (22%)', isDark),
                          _buildLegendRow(Colors.green, 'Verified', '32 (25%)', isDark),
                          _buildLegendRow(Colors.blue, 'Processed', '23 (18%)', isDark),
                          _buildLegendRow(Colors.red, 'Rejected', '2 (2%)', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity Card matching Screenshot 2
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                      },
                      child: const Text('View all', style: TextStyle(color: Colors.blue, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildActivityTimelineItem(Colors.amber, 'LR1001 forwarded to KYC Team', '10 mins ago', isDark),
                _buildActivityTimelineItem(Colors.purple, 'LR1000 verified by KYC Team', '1 hour ago', isDark),
                _buildActivityTimelineItem(Colors.green, 'LR0998 processed successfully', '3 hours ago', isDark, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Track Your Pipeline Efficiently Banner Card matching Screenshot 2
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track your pipeline efficiently',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stay on top of every request and take action faster, hassle free.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Text('View All Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        label: const Icon(Icons.arrow_forward, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3B6E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.show_chart, color: Color(0xFFFFC107), size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A3B6E),
            ),
          ),
          InkWell(
            onTap: () {
              if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
            },
            child: const Text('View all', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCardFullWidth(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
              const SizedBox(height: 4),
              Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              InkWell(
                onTap: () {
                  if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                },
                child: const Text('View all', style: TextStyle(color: Colors.blue, fontSize: 11)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 22),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePill(String label, bool isDark) {
    final isSelected = _timeRange == label;
    return InkWell(
      onTap: () => setState(() => _timeRange = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A3B6E) : (isDark ? Colors.white10 : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildActivityTimelineItem(Color dotColor, String title, String timeAgo, bool isDark, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            if (!isLast)
              Container(width: 2, height: 32, color: isDark ? Colors.white10 : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 2),
              Text(timeAgo, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
              if (!isLast) const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
