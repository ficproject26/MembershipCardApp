import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/shared.dart';

class LoanTlReportsTab extends StatelessWidget {
  const LoanTlReportsTab({super.key});

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
                  color: Colors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date Range', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 8),
                        Text('01 May 2025 - 31 May 2025', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_month, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Type', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: DropdownButton<String>(
                        value: 'All',
                        dropdownColor: isDark ? const Color(0xFF1A3B6E) : Colors.white,
                        underline: const SizedBox(),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        isExpanded: true,
                        items: ['All', 'Personal Loan', 'Home Loan', 'Business Loan', 'Education Loan'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Generate Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Text('Loan Requests Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildSummaryCard('Total Requests', '128', isDark, constraints.maxWidth, isHighlight: true),
                  _buildSummaryCard('Pending', '45', isDark, constraints.maxWidth, valueColor: Colors.orange),
                  _buildSummaryCard('With KYC Team', '28', isDark, constraints.maxWidth),
                  _buildSummaryCard('Verified', '20', isDark, constraints.maxWidth),
                  _buildSummaryCard('Processed', '23', isDark, constraints.maxWidth),
                  _buildSummaryCard('Rejected', '2', isDark, constraints.maxWidth, valueColor: Colors.red),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final donutChart = _buildLoanTypeChart(isDark);
              final barChart = _buildStatusChart(isDark);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: donutChart),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: barChart),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    donutChart,
                    const SizedBox(height: 16),
                    barChart,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
          
          _buildTopAgents(isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, bool isDark, double maxWidth, {Color? valueColor, bool isHighlight = false}) {
    double cardWidth = 200;
    if (maxWidth > 1000) {
      cardWidth = (maxWidth - (16 * 5)) / 6;
    } else if (maxWidth > 600) cardWidth = (maxWidth - (16 * 2)) / 3;
    else cardWidth = (maxWidth - 16) / 2;

    return SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54), maxLines: 1),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor ?? (isHighlight ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white70 : Colors.black87)))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanTypeChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Requests by Loan Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(color: const Color(0xFFFFC107), value: 42, title: '', radius: 20),
                            PieChartSectionData(color: const Color(0xFF9C27B0), value: 29, title: '', radius: 20),
                            PieChartSectionData(color: Colors.cyan, value: 15, title: '', radius: 20),
                            PieChartSectionData(color: Colors.green, value: 9, title: '', radius: 20),
                            PieChartSectionData(color: Colors.red, value: 5, title: '', radius: 20),
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend('Personal Loan', '55 (42%)', const Color(0xFFFFC107), isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Home Loan', '38 (29%)', const Color(0xFF9C27B0), isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Business Loan', '20 (15%)', Colors.cyan, isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Education Loan', '12 (9%)', Colors.green, isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Other Loans', '3 (5%)', Colors.red, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
            SizedBox(
              width: 100,
              child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
            ),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildStatusChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Requests by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, MetaMeta) {
                        const style = TextStyle(color: Colors.grey, fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('Pending', style: style);
                          case 1: return const Text('With KYC', style: style);
                          case 2: return const Text('Verified', style: style);
                          case 3: return const Text('Processed', style: style);
                          case 4: return const Text('Rejected', style: style);
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarData(0, 45, Colors.blue),
                  _buildBarData(1, 28, const Color(0xFF9C27B0)),
                  _buildBarData(2, 32, Colors.green),
                  _buildBarData(3, 23, Colors.cyan),
                  _buildBarData(4, 2, Colors.red),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  Widget _buildTopAgents(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Agents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('Agent Name', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54))),
                    Expanded(flex: 1, child: Text('Total Requests', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54))),
                    Expanded(flex: 1, child: Text('Processed', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54))),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildAgentRow('Agent Raj', '25', '15', isDark),
              _buildAgentRow('Agent Kumar', '22', '12', isDark),
              _buildAgentRow('Agent Priya', '20', '10', isDark),
              _buildAgentRow('Agent Ravi', '18', '9', isDark),
              _buildAgentRow('Agent Neha', '15', '8', isDark, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentRow(String name, String total, String processed, bool isDark, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.person, color: isDark ? Colors.white70 : Colors.black54, size: 20),
                    const SizedBox(width: 12),
                    Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Text(total, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
              Expanded(flex: 1, child: Text(processed, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
