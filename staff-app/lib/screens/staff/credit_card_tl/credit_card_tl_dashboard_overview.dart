import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'credit_card_application_details.dart';

class CreditCardTlDashboardOverview extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const CreditCardTlDashboardOverview({super.key, this.onNavigateToTab});

  @override
  State<CreditCardTlDashboardOverview> createState() => _CreditCardTlDashboardOverviewState();
}

class _CreditCardTlDashboardOverviewState extends State<CreditCardTlDashboardOverview> {
  String _searchQuery = '';
  String _selectedFilter = 'Action Required';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final creditCardLeads = state.leads.where((l) =>
      l.serviceType == 'Credit Card' || (l.serviceType != null && l.serviceType.toLowerCase().contains('credit'))
    ).toList();

    final actionRequiredLeads = creditCardLeads.where((l) =>
      l.status == LeadStatus.Pending || 
      l.status == LeadStatus.Stage1Pending || 
      l.status == LeadStatus.Stage1Approved || 
      l.status == LeadStatus.Stage2Pending || 
      l.status == LeadStatus.Stage2Approved || 
      l.status == LeadStatus.Stage3Pending || 
      l.status == LeadStatus.Stage3Approved
    ).toList();

    final approvedLeads = creditCardLeads.where((l) =>
      l.status == LeadStatus.Approved
    ).toList();

    final rejectedLeads = creditCardLeads.where((l) =>
      l.status == LeadStatus.Rejected ||
      l.status == LeadStatus.Stage1Rejected ||
      l.status == LeadStatus.Stage2Rejected ||
      l.status == LeadStatus.Stage3Rejected
    ).toList();

    List<LeadModel> displayedLeads;
    if (_selectedFilter == 'All') {
      displayedLeads = creditCardLeads;
    } else if (_selectedFilter == 'Approved') {
      displayedLeads = approvedLeads;
    } else if (_selectedFilter == 'Rejected') {
      displayedLeads = rejectedLeads;
    } else {
      displayedLeads = actionRequiredLeads;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      displayedLeads = displayedLeads.where((l) =>
        l.id.toLowerCase().contains(q) ||
        (l.customerName?.toLowerCase().contains(q) ?? false) ||
        l.agentCode.toLowerCase().contains(q)
      ).toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Credit Card TL Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                    Text(
                      'Review and process credit card applications with ease.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2x2 KPI Counter Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _buildKpiCard('All Applications', creditCardLeads.length.toString(), Icons.folder, Colors.blue, 'All', isDark),
              _buildKpiCard('Action Required', actionRequiredLeads.length.toString(), Icons.pending_actions, Colors.amber, 'Action Required', isDark),
              _buildKpiCard('Approved', approvedLeads.length.toString(), Icons.check_circle, Colors.green, 'Approved', isDark),
              _buildKpiCard('Rejected', rejectedLeads.length.toString(), Icons.cancel, Colors.red, 'Rejected', isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by Customer Name, Agent ID...',
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
                  onChanged: (val) => setState(() => _searchQuery = val),
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
          const SizedBox(height: 24),

          // Section Title & View All Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedFilter (${displayedLeads.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(1); // Navigate to Requests Tab
                  }
                },
                child: const Text('View All', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lead Item List
          if (displayedLeads.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 12),
                    Text(
                      'No $_selectedFilter applications found.',
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
              itemCount: displayedLeads.length,
              itemBuilder: (context, index) {
                final lead = displayedLeads[index];
                return _buildLeadItemCard(lead, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color, String filterKey, bool isDark) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B263B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white10 : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadItemCard(LeadModel lead, bool isDark) {
    final isApproved = lead.status == LeadStatus.Approved;
    final isRejected = lead.status == LeadStatus.Rejected || lead.status == LeadStatus.Stage1Rejected || lead.status == LeadStatus.Stage2Rejected;

    Color statusColor = Colors.amber;
    String badgeText = lead.status.name.replaceAll('Stage1', 'Stage 1 ').replaceAll('Stage2', 'Stage 2 ').replaceAll('Stage3', 'Stage 3 ');

    if (isApproved) {
      statusColor = Colors.green;
      badgeText = 'Approved';
    } else if (isRejected) {
      statusColor = Colors.red;
      badgeText = 'Rejected';
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                builder: (context) => CreditCardApplicationDetailsScreen(lead: lead),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted by Agent: ${lead.agentCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${lead.dateCreated.day}/${lead.dateCreated.month}/${lead.dateCreated.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
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
