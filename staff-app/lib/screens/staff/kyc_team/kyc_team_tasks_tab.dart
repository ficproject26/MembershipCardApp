import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class KycTeamTasksTab extends StatelessWidget {
  const KycTeamTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateProvider>(context).isDarkMode;
    final primaryColor = const Color(0xFF9C27B0); // Purple accent
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(context, 'Total Tasks', '18', Icons.assignment, isDark),
              _buildStatCard(context, 'Pending', '10', Icons.pending_actions, isDark),
              _buildStatCard(context, 'In Progress', '6', Icons.sync, isDark),
              _buildStatCard(context, 'Completed', '2', Icons.check_circle, isDark),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Pending (10)   In Progress (6)   Completed (2)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: GlassCard(
              padding: const EdgeInsets.all(0),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                columns: const [
                  DataColumn(label: Text('Ref ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Task', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Applicant', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: List.generate(5, (index) {
                  return DataRow(
                    cells: [
                      DataCell(Text('LR09${index + 1}', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                      DataCell(Text('Verify ID & Address', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                      DataCell(Text('Jane Doe', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                      DataCell(Text('14 May 2025', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                      DataCell(Text('High', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Pending', style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ),
                      ),
                      DataCell(
                        TextButton(
                          onPressed: () {},
                          child: Text('Open Task', style: TextStyle(color: primaryColor)),
                        )
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 900 ? (width - 48 - 48) / 4 : (width > 600 ? (width - 48 - 32) / 3 : (width - 48 - 16) / 2);

    return SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF9C27B0)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
