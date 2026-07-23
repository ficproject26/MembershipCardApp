import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class LoanTlRequestsTab extends StatefulWidget {
  const LoanTlRequestsTab({super.key});

  @override
  State<LoanTlRequestsTab> createState() => _LoanTlRequestsTabState();
}

class _LoanTlRequestsTabState extends State<LoanTlRequestsTab> {
  String _selectedTab = 'Pending';
  LeadModel? _selectedRequest;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppStateProvider>(context).isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Requests',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                child: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Consumer<AppStateProvider>(
              builder: (context, state, child) {
                final allLeads = state.leads.where((l) => l.serviceType == 'Loan').toList();
                final pendingCount = allLeads.where((l) => l.status == LeadStatus.Pending).length;
                final withKycCount = allLeads.where((l) => l.status == LeadStatus.KYC_Pending).length;
                final verifiedCount = allLeads.where((l) => l.status == LeadStatus.KYC_Verified).length;
                final processedCount = allLeads.where((l) => l.status == LeadStatus.Approved || l.status == LeadStatus.Dispatched || l.status == LeadStatus.Process).length;
                final rejectedCount = allLeads.where((l) => l.status == LeadStatus.Rejected || l.status == LeadStatus.KYC_Rejected).length;
                return Row(
                  children: [
                    _buildTab('Pending ($pendingCount)', 'Pending', isDark),
                    const SizedBox(width: 24),
                    _buildTab('With KYC ($withKycCount)', 'With KYC', isDark),
                    const SizedBox(width: 24),
                    _buildTab('Verified ($verifiedCount)', 'Verified', isDark),
                    const SizedBox(width: 24),
                    _buildTab('Processed ($processedCount)', 'Processed', isDark),
                    const SizedBox(width: 24),
                    _buildTab('Rejected ($rejectedCount)', 'Rejected', isDark),
                  ],
                );
              }
            ),
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
                              onSelectChanged: (selected) {
                                if (selected == true) {
                                  setState(() => _selectedRequest = req);
                                }
                              },
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
                                    onPressed: () {
                                      setState(() => _selectedRequest = req);
                                    },
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
              ),
              if (MediaQuery.of(context).size.width > 1200) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildDetailsPanel(isDark),
                ),
              ]
            ],
          ),
          if (MediaQuery.of(context).size.width <= 1200) ...[
            const SizedBox(height: 16),
            _buildDetailsPanel(isDark),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(bool isDark) {
    if (_selectedRequest == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Select a request to view details', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    final requestDetailsCard = GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 120, child: Text('Ref ID', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
              Text(_selectedRequest!.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(_selectedRequest!.status.name, style: const TextStyle(color: Colors.orange, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow('Applicant Name', _selectedRequest!.customerName ?? 'N/A', isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Mobile', _selectedRequest!.customerPhone ?? 'N/A', isDark),
          const SizedBox(height: 16),
           _buildDetailRow('Email', _selectedRequest!.customerEmail ?? _selectedRequest!.details['email'] ?? 'N/A', isDark),
           const SizedBox(height: 16),
           _buildDetailRow('Loan Type', _selectedRequest!.details['Type of Loan'] ?? _selectedRequest!.details['loanType'] ?? 'N/A', isDark),
           const SizedBox(height: 16),
           _buildDetailRow('Amount', _selectedRequest!.details['Loan Amount'] ?? _selectedRequest!.details['amount'] ?? 'N/A', isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Agent Name', _selectedRequest!.agentName ?? _selectedRequest!.agentCode, isDark),
          const SizedBox(height: 16),
          _buildDetailRow('Date', '${_selectedRequest!.dateCreated.day}/${_selectedRequest!.dateCreated.month}/${_selectedRequest!.dateCreated.year}', isDark),
        ],
      ),
    );

    final actionsCard = GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatusButton(context, 'Verify', LeadStatus.Stage1Approved, Colors.amber),
              _buildStatusButton(context, 'Bank', LeadStatus.Stage2Approved, Colors.orange),
              _buildStatusButton(context, 'Approved', LeadStatus.Approved, Colors.green),
              _buildStatusButton(context, 'Disbursed', LeadStatus.Dispatched, Colors.teal),
              _buildStatusButton(context, 'Reject', LeadStatus.Rejected, Colors.red),
            ],
          ),
        ],
      ),
    );

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          requestDetailsCard,
          const SizedBox(height: 16),
          actionsCard,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: requestDetailsCard),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: actionsCard),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String label, LeadStatus targetStatus, MaterialColor color) {
    final isActive = _selectedRequest?.status == targetStatus;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : color.withValues(alpha: 0.1),
        foregroundColor: isActive ? Colors.white : color,
        elevation: isActive ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color),
        ),
      ),
      onPressed: () {
        if (_selectedRequest != null) {
          Provider.of<AppStateProvider>(context, listen: false).updateLeadStatus(_selectedRequest!.id, targetStatus.name);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Status updated to $label'),
            backgroundColor: color,
          ));
          setState(() {
            _selectedRequest = null;
          });
        }
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
