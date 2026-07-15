import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/shared.dart';
import 'payouts_tab.dart';
import 'commission_tab.dart';

class AdminDashboardTab extends StatefulWidget {
  final void Function(int tabIndex)? onNavigate;
  const AdminDashboardTab({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final TextEditingController _notificationController = TextEditingController();

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    // Calculate metrics
    final totalAgents = state.agents.length;
    final totalLeads = state.leads.length;
    final pendingLeads = state.leads.where((l) => l.status == LeadStatus.Pending).length;
    final pendingPayouts = state.transactions
        .where((t) => t.type == TransactionType.Withdrawal && t.status == TransactionStatus.Pending)
        .length;
    final totalCommissionPaid = state.transactions
        .where((t) => t.type == TransactionType.DirectCommission || t.type == TransactionType.IndirectCommission)
        .fold<double>(0.0, (val, tx) => val + tx.amount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row of quick statistics cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                title: 'Total Agents',
                value: '$totalAgents',
                subtitle: 'Registered',
                icon: Icons.people,
                color: Colors.blue,
                isDark: isDark,
                onTap: () => widget.onNavigate?.call(2),
              ),
              _buildStatCard(
                title: 'Pending Leads',
                value: '$pendingLeads',
                subtitle: 'Requires review',
                icon: Icons.pending_actions,
                color: Colors.amber,
                isDark: isDark,
                onTap: () => widget.onNavigate?.call(1),
              ),
              _buildStatCard(
                title: 'Pending Payouts',
                value: '$pendingPayouts',
                subtitle: 'Approvals queue',
                icon: Icons.payments,
                color: Colors.redAccent,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPayoutsTab()),
                ),
              ),
              _buildStatCard(
                title: 'Total Commission',
                value: '₹${totalCommissionPaid.toStringAsFixed(0)}',
                subtitle: 'Distributed',
                icon: Icons.account_balance_wallet,
                color: Colors.greenAccent,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCommissionTab()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Performance chart
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Referral & Payout Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'FIC Membership Club Lead Conversion Metrics (₹ in thousands)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: isDark ? Colors.white12 : Colors.black12,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                              int index = value.toInt() - 1;
                              if (index >= 0 && index < months.length) {
                                return Text(
                                  months[index],
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : Colors.black54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 1,
                      maxX: 6,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(1, 20),
                            FlSpot(2, 45),
                            FlSpot(3, 35),
                            FlSpot(4, 65),
                            FlSpot(5, 80),
                            FlSpot(6, 95),
                          ],
                          isCurved: true,
                          color: const Color(0xFFFFC107),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFFFC107).withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Broadcast notifications console
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Firebase Push Notifications Composer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notificationController,
                  decoration: InputDecoration(
                    hintText: 'Enter alert description for agents...',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: const Color(0xFFFFC107)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: const Color(0xFFFFC107)),
                      onPressed: () {
                        if (_notificationController.text.trim().isNotEmpty) {
                          state.addNotification(_notificationController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                              content: Text('Firebase Notification Broadcasted Successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _notificationController.clear();
                        }
                      },
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent Activity Stream
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Platform Alerts Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.notifications.take(5).length,
                  separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black12),
                  itemBuilder: (context, idx) {
                    final item = state.notifications[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFFFFF3CD), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.15),
        highlightColor: color.withValues(alpha: 0.08),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 8, color: color.withValues(alpha: 0.7)),
                      ]
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
