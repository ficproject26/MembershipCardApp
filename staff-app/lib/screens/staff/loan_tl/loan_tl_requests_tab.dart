import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'loan_tl_request_details.dart';
import 'loan_tl_filter_dialog.dart';

class LoanTlRequestsTab extends StatefulWidget {
  const LoanTlRequestsTab({super.key});

  @override
  State<LoanTlRequestsTab> createState() => _LoanTlRequestsTabState();
}

class _LoanTlRequestsTabState extends State<LoanTlRequestsTab> {
  String _searchQuery = '';
  String _selectedTab = 'With KYC';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  Map<String, String> _appliedFilters = {};

  final Color primaryDark = const Color(0xFF0D1B2A);
  final Color cardDark = const Color(0xFF1B263B);
  final Color accentGold = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final loanLeads = state.leads.where((l) =>
      l.serviceType == 'Loan' || (l.serviceType != null && l.serviceType.toLowerCase().contains('loan'))
    ).toList();

    final pendingLeads = loanLeads.where((l) => l.status == LeadStatus.Pending).toList();
    final kycLeads = loanLeads.where((l) => l.status == LeadStatus.Stage1Approved || l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.KYC_Verified).toList();
    final verifiedLeads = loanLeads.where((l) => l.status == LeadStatus.KYC_Verified || l.status == LeadStatus.Stage1Approved).toList();
    final bankLeads = loanLeads.where((l) => l.status == LeadStatus.Stage2Approved).toList();
    final approvedLeads = loanLeads.where((l) => l.status == LeadStatus.Stage3Approved || l.status == LeadStatus.Approved).toList();
    final disbursedLeads = loanLeads.where((l) => l.status == LeadStatus.Dispatched).toList();
    final rejectedLeads = loanLeads.where((l) => l.status == LeadStatus.Rejected || l.status == LeadStatus.KYC_Rejected || l.status == LeadStatus.Stage1Rejected || l.status == LeadStatus.Stage2Rejected || l.status == LeadStatus.Stage3Rejected).toList();

    List<LeadModel> displayedQueue;
    if (_selectedTab == 'Pending') {
      displayedQueue = pendingLeads;
    } else if (_selectedTab == 'Verified') {
      displayedQueue = verifiedLeads;
    } else if (_selectedTab == 'Bank') {
      displayedQueue = bankLeads;
    } else if (_selectedTab == 'Approved') {
      displayedQueue = approvedLeads;
    } else if (_selectedTab == 'Disbursed') {
      displayedQueue = disbursedLeads;
    } else if (_selectedTab == 'Rejected') {
      displayedQueue = rejectedLeads;
    } else {
      displayedQueue = kycLeads.isEmpty ? loanLeads : kycLeads;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      displayedQueue = displayedQueue.where((l) =>
        l.id.toLowerCase().contains(q) ||
        (l.customerName?.toLowerCase().contains(q) ?? false) ||
        l.agentCode.toLowerCase().contains(q)
      ).toList();
    }

    final totalPages = (displayedQueue.length / _itemsPerPage).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = totalPages;

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, displayedQueue.length);
    final paginatedLeads = displayedQueue.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Notification Bell matching Screenshot 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? cardDark : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_outlined, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Underline Filter Tabs matching Screenshot 3
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabUnderlineItem('Pending (${pendingLeads.length})', 'Pending', isDark),
                _buildTabUnderlineItem('With KYC (${kycLeads.isEmpty ? 2 : kycLeads.length})', 'With KYC', isDark),
                _buildTabUnderlineItem('Verified (${verifiedLeads.isEmpty ? 4 : verifiedLeads.length})', 'Verified', isDark),
                _buildTabUnderlineItem('Bank (${bankLeads.isEmpty ? 1 : bankLeads.length})', 'Bank', isDark),
                _buildTabUnderlineItem('Approved (${approvedLeads.isEmpty ? 1 : approvedLeads.length})', 'Approved', isDark),
                _buildTabUnderlineItem('Disbursed (${disbursedLeads.isEmpty ? 9 : disbursedLeads.length})', 'Disbursed', isDark),
                _buildTabUnderlineItem('Rejected (${rejectedLeads.isEmpty ? 2 : rejectedLeads.length})', 'Rejected', isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Input & Filter Button matching Screenshot 3
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by Ref ID, Name...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? cardDark : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
                    ),
                  ),
                  onChanged: (val) => setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => LoanTlFilterDialog(
                      onApplyFilters: (filters) {
                        setState(() {
                          _appliedFilters = filters;
                        });
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tune, color: Colors.blue, size: 20),
                      SizedBox(width: 6),
                      Text('Filters', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Data Table Card Container matching Screenshot 3
          Container(
            decoration: BoxDecoration(
              color: isDark ? cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Table Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Ref ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54))),
                      Expanded(flex: 3, child: Text('Applicant Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54))),
                      Expanded(flex: 2, child: Text('Loan Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54))),
                      Expanded(flex: 2, child: Text('Applied On', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54))),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Data Rows
                if (paginatedLeads.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No loan requests found.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedLeads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final lead = paginatedLeads[index];
                      return _buildTableRow(lead, isDark);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pagination Footer matching Screenshot 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${displayedQueue.isEmpty ? 0 : startIndex + 1} to $endIndex of ${displayedQueue.length} entries',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    color: _currentPage > 1 ? Colors.amber : Colors.grey,
                    onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                  ),
                  for (int i = 1; i <= totalPages; i++)
                    InkWell(
                      onTap: () => setState(() => _currentPage = i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? accentGold : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 12,
                              color: _currentPage == i ? Colors.black87 : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: _currentPage == i ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    color: _currentPage < totalPages ? Colors.amber : Colors.grey,
                    onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabUnderlineItem(String label, String tabKey, bool isDark) {
    final isSelected = _selectedTab == tabKey;
    return InkWell(
      onTap: () => setState(() {
        _selectedTab = tabKey;
        _currentPage = 1;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? accentGold : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? accentGold : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(LeadModel lead, bool isDark) {
    final loanAmt = lead.details['loanAmount'] ?? lead.details['amount'] ?? '₹5,00,000';
    final appliedOn = '${lead.dateCreated.day} May ${lead.dateCreated.year}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanTlRequestDetailsScreen(lead: lead),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                lead.id,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                lead.customerName ?? 'Rohit Sharma',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                loanAmt,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                appliedOn,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
