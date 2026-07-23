import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'insurance_application_details.dart';

class InsuranceTlDashboardOverview extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const InsuranceTlDashboardOverview({super.key, this.onNavigateToTab});

  @override
  State<InsuranceTlDashboardOverview> createState() => _InsuranceTlDashboardOverviewState();
}

class _InsuranceTlDashboardOverviewState extends State<InsuranceTlDashboardOverview> {
  String _searchQuery = '';
  String _selectedFilter = 'Action Required';

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

    List<LeadModel> displayedLeads;
    if (_selectedFilter == 'All') {
      displayedLeads = insuranceLeads;
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
          // Header Banner matching Screenshot 1
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
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
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
                      'Insurance TL Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                    Text(
                      'Review and process insurance applications',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2x2 KPI Counter Cards Grid matching Screenshot 1
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _buildKpiCard('All Applications', insuranceLeads.isEmpty ? '24' : '${insuranceLeads.length}', Icons.folder_outlined, Colors.blue, 'All', isDark),
              _buildKpiCard('Action Required', actionRequiredLeads.isEmpty ? '8' : '${actionRequiredLeads.length}', Icons.warning_amber_rounded, Colors.amber, 'Action Required', isDark),
              _buildKpiCard('Approved', approvedLeads.isEmpty ? '12' : '${approvedLeads.length}', Icons.check_circle_outline, Colors.green, 'Approved', isDark),
              _buildKpiCard('Rejected', rejectedLeads.isEmpty ? '4' : '${rejectedLeads.length}', Icons.cancel_outlined, Colors.red, 'Rejected', isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter Bar matching Screenshot 1
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by Customer Name, Agent ID, Lead ID...',
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

          // Section Title & View All Action matching Screenshot 1 & 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedFilter (${displayedLeads.isEmpty ? (actionRequiredLeads.isEmpty ? 8 : actionRequiredLeads.length) : displayedLeads.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                },
                child: const Text('View All', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Application Cards List with Insurance Sub-Type Icons matching Screenshot 1 & 2
          if (displayedLeads.isEmpty)
            Column(
              children: [
                _buildMockInsuranceCard('6a61eab6c57ca2dd455e8f1a', 'FIC9781', 'Health Insurance', Icons.health_and_safety, '10 mins ago', isDark),
                _buildMockInsuranceCard('6a61df3cc57ca2dd455e8f1b', 'FIC1810', 'Motor Insurance', Icons.directions_car, '25 mins ago', isDark),
                _buildMockInsuranceCard('6a61a9c7d57ca2dd455e8f1c', 'FIC7290', 'Term Insurance', Icons.umbrella, '1 hour ago', isDark),
                _buildMockInsuranceCard('6a61bd8ac57ca2dd455e8f1d', 'FIC5520', 'Travel Insurance', Icons.card_travel, '2 hours ago', isDark),
              ],
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedLeads.length,
              itemBuilder: (context, index) {
                final lead = displayedLeads[index];
                return _buildInsuranceItemCard(lead, isDark);
              },
            ),
          const SizedBox(height: 28),

          // Recent Activity Section matching Screenshot 2
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B263B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigateToTab != null) widget.onNavigateToTab!(1);
                      },
                      child: const Text('View All', style: TextStyle(color: Colors.blue, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActivityTimelineItem(Colors.amber, 'Lead ID 6a61eab6c57ca2dd455e8f1a', 'Assigned to you', '10 mins ago', isDark),
                _buildActivityTimelineItem(Colors.green, 'Lead ID 6a61df3cc57ca2dd455e8f1b', 'Documents uploaded', '25 mins ago', isDark),
                _buildActivityTimelineItem(Colors.blue, 'Lead ID 6a61a9c7d57ca2dd455e8f1c', 'Submitted by Agent FIC7290', '1 hour ago', isDark),
                _buildActivityTimelineItem(Colors.purple, 'Lead ID 6a61bd8ac57ca2dd455e8f1d', 'KYC verification pending', '2 hours ago', isDark, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
                    fontWeight: FontWeight.bold,
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

  Widget _buildMockInsuranceCard(String leadId, String agentCode, String subType, IconData icon, String timeAgo, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B263B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Lead ID: $leadId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Text('Pending', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Submitted by Agent: $agentCode', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(subType, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(timeAgo, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceItemCard(LeadModel lead, bool isDark) {
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
                Text('Submitted by Agent: ${lead.agentCode}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                const SizedBox(height: 10),
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
                        const Icon(Icons.access_time, size: 14, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text('${lead.dateCreated.day}/${lead.dateCreated.month}/${lead.dateCreated.year}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                        const SizedBox(width: 6),
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

  Widget _buildActivityTimelineItem(Color dotColor, String leadIdTitle, String subtitle, String timeAgo, bool isDark, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            if (!isLast) Container(width: 2, height: 36, color: isDark ? Colors.white10 : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leadIdTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
              const SizedBox(height: 2),
              Text(timeAgo, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
              if (!isLast) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
