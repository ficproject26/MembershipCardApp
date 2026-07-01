import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/lead_model.dart';

class LoanTlTasksTab extends StatefulWidget {
  const LoanTlTasksTab({Key? key}) : super(key: key);

  @override
  State<LoanTlTasksTab> createState() => _LoanTlTasksTabState();
}

class _LoanTlTasksTabState extends State<LoanTlTasksTab> {
  String _selectedTab = 'Pending';
  LeadModel? _selectedTask;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    
    final allLeads = state.leads.where((l) => l.serviceType == 'Loan').toList();
    final pendingTasks = allLeads.where((l) => l.status == LeadStatus.Pending).toList();
    final inProgressTasks = allLeads.where((l) => l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.Process).toList();
    final completedTasks = allLeads.where((l) => l.status == LeadStatus.Approved || l.status == LeadStatus.Dispatched).toList();
    final totalTasks = pendingTasks.length + inProgressTasks.length + completedTasks.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                child: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Total Tasks', '$totalTasks', Icons.assignment, Colors.blue, isDark, constraints.maxWidth),
                  _buildStatCard('Pending', '${pendingTasks.length}', Icons.pending_actions, Colors.orange, isDark, constraints.maxWidth),
                  _buildStatCard('In Progress', '${inProgressTasks.length}', Icons.group, const Color(0xFF9C27B0), isDark, constraints.maxWidth),
                  _buildStatCard('Completed', '${completedTasks.length}', Icons.how_to_reg, Colors.green, isDark, constraints.maxWidth),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          
          Text('My Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildTab('Pending (${pendingTasks.length})', 'Pending', isDark),
              const SizedBox(width: 24),
              _buildTab('In Progress (${inProgressTasks.length})', 'In Progress', isDark),
              const SizedBox(width: 24),
              _buildTab('Completed (${completedTasks.length})', 'Completed', isDark),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: GlassCard(
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
                                    hintText: 'Search tasks...',
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
                          headingRowColor: MaterialStateProperty.all((isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                          columns: const [
                            DataColumn(label: Text('Ref ID')),
                            DataColumn(label: Text('Task')),
                            DataColumn(label: Text('Applicant')),
                            DataColumn(label: Text('Due Date')),
                            DataColumn(label: Text('Priority')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: allLeads.where((l) {
                            if (_selectedTab == 'Pending') return l.status == LeadStatus.Pending;
                            if (_selectedTab == 'In Progress') return l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.Process;
                            if (_selectedTab == 'Completed') return l.status == LeadStatus.Approved || l.status == LeadStatus.Dispatched;
                            return false;
                          }).map((task) {
                            final statusStr = _selectedTab;
                            return DataRow(
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  setState(() => _selectedTask = task);
                                }
                              },
                              cells: [
                                DataCell(Text(task.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                DataCell(Text('Review Lead', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                DataCell(Text(task.customerName ?? 'N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                DataCell(Text('${task.dateCreated.day}/${task.dateCreated.month}/${task.dateCreated.year}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                DataCell(_buildPriorityBadge('Medium')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusStr == 'Pending' ? Colors.orange.withOpacity(0.1) : Colors.cyan.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusStr == 'Pending' ? Colors.orange.withOpacity(0.3) : Colors.cyan.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle, size: 8, color: statusStr == 'Pending' ? Colors.orange : Colors.cyan),
                                        const SizedBox(width: 4),
                                        Text(statusStr, style: TextStyle(color: statusStr == 'Pending' ? Colors.orange : Colors.cyan, fontSize: 12)),
                                      ],
                                    ),
                                  ),
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
                            Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (MediaQuery.of(context).size.width > 900) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildDetailsPanel(isDark),
                ),
              ]
            ],
          ),
          if (MediaQuery.of(context).size.width <= 900) ...[
            const SizedBox(height: 16),
            _buildDetailsPanel(isDark),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(bool isDark) {
    if (_selectedTask == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Select a task to view details', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    final statusStr = _selectedTab;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 100, child: Text('Ref ID', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
              Text(_selectedTask!.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(statusStr, style: const TextStyle(color: Colors.orange, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (isSmallScreen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow('Task', 'Review Lead', isDark),
                const SizedBox(height: 16),
                _buildDetailRow('Applicant', _selectedTask!.customerName ?? 'N/A', isDark),
                const SizedBox(height: 16),
                _buildDetailRow('Due Date', '${_selectedTask!.dateCreated.day}/${_selectedTask!.dateCreated.month}/${_selectedTask!.dateCreated.year}', isDark),
                const SizedBox(height: 24),
                Text('Priority', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                const SizedBox(height: 8),
                _buildPriorityBadge('Medium'),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Task', 'Review Lead', isDark),
                      const SizedBox(height: 16),
                      _buildDetailRow('Applicant', _selectedTask!.customerName ?? 'N/A', isDark),
                      const SizedBox(height: 16),
                      _buildDetailRow('Due Date', '${_selectedTask!.dateCreated.day}/${_selectedTask!.dateCreated.month}/${_selectedTask!.dateCreated.year}', isDark),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                      const SizedBox(height: 8),
                      _buildPriorityBadge('Medium'),
                    ],
                  ),
                )
              ],
            ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Open Task', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    if (priority == 'High') color = Colors.red;
    else if (priority == 'Medium') color = Colors.orange;
    else color = Colors.green;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, bool isDark, double maxWidth) {
    double cardWidth = 200;
    if (maxWidth > 1000) cardWidth = (maxWidth - (16 * 3)) / 4;
    else if (maxWidth > 600) cardWidth = (maxWidth - (16 * 2)) / 3;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
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
    );
  }
}
