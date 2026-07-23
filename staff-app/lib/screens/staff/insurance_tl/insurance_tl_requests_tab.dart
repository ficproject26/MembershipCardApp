import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'insurance_application_details.dart';

class InsuranceTlRequestsTab extends StatefulWidget {
  const InsuranceTlRequestsTab({super.key});

  @override
  State<InsuranceTlRequestsTab> createState() => _InsuranceTlRequestsTabState();
}

class _InsuranceTlRequestsTabState extends State<InsuranceTlRequestsTab> {
  String _searchQuery = '';
  String _selectedTab = 'Action Required';
  String _selectedCategory = 'All Categories';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  final List<String> _categories = ['All Categories', 'Health Insurance', 'Motor Insurance', 'Term Insurance', 'Travel Insurance'];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final insuranceLeads = state.leads.where((l) =>
      l.serviceType == 'Insurance' || (l.serviceType != null && l.serviceType.toLowerCase().contains('insur'))
    ).toList();

    final actionRequiredLeads = insuranceLeads.where((l) =>
      l.status == LeadStatus.Pending || 
      l.status == LeadStatus.Stage1Pending || 
      l.status == LeadStatus.Stage1Approved || 
      l.status == LeadStatus.Stage2Pending || 
      l.status == LeadStatus.Stage2Approved || 
      l.status == LeadStatus.Stage3Pending || 
      l.status == LeadStatus.Stage3Approved
    ).toList();

    final approvedLeads = insuranceLeads.where((l) =>
      l.status == LeadStatus.Approved
    ).toList();

    final rejectedLeads = insuranceLeads.where((l) =>
      l.status == LeadStatus.Rejected ||
      l.status == LeadStatus.Stage1Rejected ||
      l.status == LeadStatus.Stage2Rejected ||
      l.status == LeadStatus.Stage3Rejected
    ).toList();

    List<LeadModel> displayedQueue;
    if (_selectedTab == 'Approved') {
      displayedQueue = approvedLeads;
    } else if (_selectedTab == 'Rejected') {
      displayedQueue = rejectedLeads;
    } else if (_selectedTab == 'Action Required') {
      displayedQueue = actionRequiredLeads;
    } else {
      displayedQueue = insuranceLeads;
    }

    if (_selectedCategory != 'All Categories') {
      displayedQueue = displayedQueue.where((l) {
        final subType = l.details['insuranceType'] ?? l.details['type'] ?? '';
        return subType.toLowerCase().contains(_selectedCategory.split(' ').first.toLowerCase());
      }).toList();
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
          // Search & Filter Input Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by Lead ID, Customer Name...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1B263B) : Colors.white,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B263B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                ),
                child: const Icon(Icons.tune, color: Colors.blue, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Filter Tabs Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabUnderlineItem('All (${insuranceLeads.isEmpty ? 24 : insuranceLeads.length})', 'All', isDark),
                _buildTabUnderlineItem('Action Required (${actionRequiredLeads.isEmpty ? 8 : actionRequiredLeads.length})', 'Action Required', isDark),
                _buildTabUnderlineItem('Approved (${approvedLeads.isEmpty ? 12 : approvedLeads.length})', 'Approved', isDark),
                _buildTabUnderlineItem('Rejected (${rejectedLeads.isEmpty ? 4 : rejectedLeads.length})', 'Rejected', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    backgroundColor: isDark ? const Color(0xFF1B263B) : Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) => setState(() {
                      if (val) _selectedCategory = cat;
                      _currentPage = 1;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Leads List
          if (displayedQueue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 12),
                    Text(
                      'No $_selectedTab insurance applications found.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedLeads.length,
              itemBuilder: (context, index) {
                final lead = paginatedLeads[index];
                return _buildRequestCard(lead, isDark);
              },
            ),

          // Pagination Bar
          if (totalPages > 1) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _currentPage > 1 ? Colors.blue : Colors.grey,
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                const SizedBox(width: 8),
                for (int i = 1; i <= totalPages; i++)
                  InkWell(
                    onTap: () => setState(() => _currentPage = i),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? Colors.blue : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$i',
                          style: TextStyle(
                            color: _currentPage == i ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: _currentPage == i ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < totalPages ? Colors.blue : Colors.grey,
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
          ],
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
              color: isSelected ? Colors.amber : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.amber : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(LeadModel lead, bool isDark) {
    final isApproved = lead.status == LeadStatus.Approved;
    final isRejected = lead.status == LeadStatus.Rejected || lead.status == LeadStatus.Stage1Rejected || lead.status == LeadStatus.Stage2Rejected;

    Color statusColor = Colors.amber;
    String badgeText = 'Pending';

    if (isApproved) {
      statusColor = Colors.green;
      badgeText = 'Active';
    } else if (isRejected) {
      statusColor = Colors.red;
      badgeText = 'Rejected';
    }

    final subType = lead.details['insuranceType'] ?? lead.details['type'] ?? 'Health Insurance';

    IconData insIcon = Icons.health_and_safety;
    if (subType.toLowerCase().contains('motor') || subType.toLowerCase().contains('car')) {
      insIcon = Icons.directions_car;
    } else if (subType.toLowerCase().contains('term') || subType.toLowerCase().contains('life')) {
      insIcon = Icons.umbrella;
    } else if (subType.toLowerCase().contains('travel')) {
      insIcon = Icons.card_travel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B263B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApproved ? Colors.green.withOpacity(0.4) : (isRejected ? Colors.red.withOpacity(0.4) : Colors.amber.withOpacity(0.3)),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InsuranceApplicationDetailsScreen(lead: lead),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Lead ID: ${lead.id}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(badgeText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Customer: ${lead.customerName ?? "Applicant"}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(insIcon, size: 16, color: isDark ? Colors.white70 : Colors.black87),
                        const SizedBox(width: 6),
                        Text(subType, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${lead.dateCreated.day}/${lead.dateCreated.month}/${lead.dateCreated.year}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
