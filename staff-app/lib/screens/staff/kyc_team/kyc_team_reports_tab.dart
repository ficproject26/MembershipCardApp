import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared/shared.dart';

class KycTeamReportsTab extends StatelessWidget {
  const KycTeamReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateProvider>(context).isDarkMode;
    final primaryColor = const Color(0xFF9C27B0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5. Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date Range', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: 'All',
                        dropdownColor: isDark ? const Color(0xFF1A3B6E) : Colors.white,
                        underline: const SizedBox(),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        isExpanded: true,
                        items: ['All', 'Pending', 'In Progress', 'Completed'].map((String value) {
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
              ),
              const SizedBox(width: 16),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Generate Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('KYC Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(context, 'Total KYC', '28', isDark),
              const SizedBox(width: 16),
              _buildStatCard(context, 'Pending', '18', isDark),
              const SizedBox(width: 16),
              _buildStatCard(context, 'In Progress', '6', isDark),
              const SizedBox(width: 16),
              _buildStatCard(context, 'Completed', '20', isDark),
              const SizedBox(width: 16),
              _buildStatCard(context, 'Returned', '2', isDark),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final donutChart = _buildDonutChart(isDark);
              final lineChart = _buildLineChart(isDark);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: donutChart),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: lineChart),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    donutChart,
                    const SizedBox(height: 16),
                    lineChart,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
          _buildTopLoanTypes(isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, bool isDark) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54), maxLines: 1),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KYC by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
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
                          Text('28', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
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
                    _buildLegend('Pending', Colors.orange, isDark),
                    const SizedBox(height: 8),
                    _buildLegend('In Progress', Colors.blue, isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Completed', Colors.green, isDark),
                    const SizedBox(height: 8),
                    _buildLegend('Returned', Colors.red, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color, bool isDark) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildLineChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KYC Completed Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('1 May', style: style);
                          case 1: return const Text('7 May', style: style);
                          case 2: return const Text('14 May', style: style);
                          case 3: return const Text('21 May', style: style);
                          case 4: return const Text('31 May', style: style);
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 30,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 5),
                      FlSpot(1, 12),
                      FlSpot(2, 25),
                      FlSpot(3, 8),
                      FlSpot(4, 15),
                    ],
                    isCurved: false,
                    color: const Color(0xFF9C27B0),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopLoanTypes(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Loan Types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(0),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLoanTypeRow('Personal Loan', '15', isDark),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              _buildLoanTypeRow('Home Loan', '8', isDark),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              _buildLoanTypeRow('Business Loan', '4', isDark),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              _buildLoanTypeRow('Education Loan', '1', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanTypeRow(String title, String count, bool isDark) {
    return ListTile(
      leading: Icon(Icons.description_outlined, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      trailing: Text(count, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
    );
  }
}
