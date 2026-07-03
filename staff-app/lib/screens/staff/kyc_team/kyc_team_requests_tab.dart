import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class KycTeamRequestsTab extends StatefulWidget {
  const KycTeamRequestsTab({super.key});

  @override
  State<KycTeamRequestsTab> createState() => _KycTeamRequestsTabState();
}

class _KycTeamRequestsTabState extends State<KycTeamRequestsTab> {
  String _selectedTab = 'Pending';
  LeadModel? _selectedRequest;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateProvider>(context).isDarkMode;
    final primaryColor = const Color(0xFF9C27B0);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KYC Requests',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 24),
          Text('My Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 16),
          Consumer<AppStateProvider>(
            builder: (context, state, child) {
              final kycLeads = state.leads.where((l) => l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.KYC_Verified || l.status == LeadStatus.KYC_Rejected).toList();
              final pendingCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Pending).length;
              final completedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Verified).length;
              final rejectedCount = kycLeads.where((l) => l.status == LeadStatus.KYC_Rejected).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTaskStatCard('Pending', '$pendingCount', Icons.people, const Color(0xFF9C27B0), isDark),
                      const SizedBox(width: 16),
                      _buildTaskStatCard('Completed', '$completedCount', Icons.check_circle_outline, Colors.green, isDark),
                      const SizedBox(width: 16),
                      _buildTaskStatCard('Rejected', '$rejectedCount', Icons.cancel_outlined, Colors.red, isDark),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildTab('Pending ($pendingCount)', 'Pending', isDark),
                      const SizedBox(width: 24),
                      _buildTab('Completed ($completedCount)', 'Completed', isDark),
                      const SizedBox(width: 24),
                      _buildTab('Rejected ($rejectedCount)', 'Rejected', isDark),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 200,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                                    hintText: 'Search tasks...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                ),
                              ),
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
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                showCheckboxColumn: false,
                                headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.05)),
                                columns: const [
                                  DataColumn(label: Text('Ref ID')),
                                  DataColumn(label: Text('Task')),
                                  DataColumn(label: Text('Applicant')),
                                  DataColumn(label: Text('Due Date')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: Provider.of<AppStateProvider>(context).leads.where((l) {
                                  if (_selectedTab == 'Pending') return l.status == LeadStatus.KYC_Pending;
                                  if (_selectedTab == 'Completed') return l.status == LeadStatus.KYC_Verified;
                                  if (_selectedTab == 'Rejected') return l.status == LeadStatus.KYC_Rejected;
                                  return false;
                                }).map((req) {
                                  final isPending = req.status == LeadStatus.KYC_Pending;
                                  return DataRow(
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        setState(() => _selectedRequest = req);
                                      }
                                    },
                                    cells: [
                                      DataCell(Text(req.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(Text(req.serviceType, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                      DataCell(Text(req.customerName ?? 'N/A', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(Text('${req.dateCreated.day}/${req.dateCreated.month}/${req.dateCreated.year}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (isPending ? Colors.orange : Colors.blue).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.circle, size: 8, color: isPending ? Colors.orange : Colors.blue),
                                              const SizedBox(width: 4),
                                              Text(req.status.name, style: TextStyle(color: isPending ? Colors.orange : Colors.blue, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 900) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildRequestDetails(isDark, primaryColor),
                  ),
                ]
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width <= 900) ...[
            const SizedBox(height: 16),
            _buildRequestDetails(isDark, primaryColor),
          ]
        ],
      ),
    );
  }

  Widget _buildTaskStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            )
          ],
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

  Widget _buildRequestDetails(bool isDark, Color primaryColor) {
    if (_selectedRequest == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Select a task to view details', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          _buildDetailRow('Ref ID', _selectedRequest!.id.substring(0, 8), isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Service Type', _selectedRequest!.serviceType, isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Applicant', _selectedRequest!.customerName ?? 'N/A', isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Date', '${_selectedRequest!.dateCreated.day}/${_selectedRequest!.dateCreated.month}/${_selectedRequest!.dateCreated.year}', isDark),
          const SizedBox(height: 32),
          if (_selectedRequest!.status == LeadStatus.KYC_Pending) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AppStateProvider>(context, listen: false).updateLeadStatus(_selectedRequest!.id, 'KYC_Verified');
                  setState(() => _selectedRequest = null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Verify Document', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Provider.of<AppStateProvider>(context, listen: false).updateLeadStatus(_selectedRequest!.id, 'KYC_Rejected');
                  setState(() => _selectedRequest = null);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reject KYC', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
