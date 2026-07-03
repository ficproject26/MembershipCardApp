import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class ITManagerProjectsTab extends StatefulWidget {
  const ITManagerProjectsTab({super.key});

  @override
  State<ITManagerProjectsTab> createState() => _ITManagerProjectsTabState();
}

class _ITManagerProjectsTabState extends State<ITManagerProjectsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allLeads = state.leads.where((l) => l.serviceType == 'IT Projects' && (l.status == LeadStatus.Stage1Approved || l.status == LeadStatus.Stage2Approved || l.status == LeadStatus.Stage3Approved || l.status == LeadStatus.Approved)).toList();
    
    final inProgress = allLeads.where((l) => l.status != LeadStatus.Approved).toList();
    final completed = allLeads.where((l) => l.status == LeadStatus.Approved).toList();
    final onHold = <LeadModel>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Projects', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('All IT Projects', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.add, color: Colors.white70), onPressed: () {}),
                ],
              )
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            _buildTabChip('All (${allLeads.length})', 0),
            _buildTabChip('In Progress (${inProgress.length})', 1),
            _buildTabChip('Completed (${completed.length})', 2),
            _buildTabChip('On Hold (0)', 3),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(allLeads),
              _buildList(inProgress),
              _buildList(completed),
              _buildList(onHold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip(String label, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFC107) : const Color(0xFF162032),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<LeadModel> leads) {
    if (leads.isEmpty) {
      return const Center(child: Text('No projects found', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(leads[index]);
      },
    );
  }

  Widget _buildProjectCard(LeadModel lead) {
    Color statusColor;
    String statusText;
    double progress;
    Widget? actionButton;

    if (lead.status == LeadStatus.Stage1Approved) {
      statusColor = Colors.redAccent;
      statusText = 'Requirements';
      progress = 0.3;
      actionButton = _buildActionBtn(context, lead, LeadStatus.Stage2Approved, 'Start Development', Colors.purpleAccent);
    } else if (lead.status == LeadStatus.Stage2Approved) {
      statusColor = Colors.purpleAccent;
      statusText = 'In Development';
      progress = 0.75;
      actionButton = _buildActionBtn(context, lead, LeadStatus.Stage3Approved, 'Send to QA', Colors.orange);
    } else if (lead.status == LeadStatus.Stage3Approved) {
      statusColor = Colors.orange;
      statusText = 'Testing';
      progress = 0.9;
      actionButton = _buildActionBtn(context, lead, LeadStatus.Approved, 'Deliver Project', Colors.green);
    } else {
      statusColor = Colors.green;
      statusText = 'Completed';
      progress = 1.0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('PRJ-${lead.id.length > 8 ? lead.id.substring(0, 8).toUpperCase() : lead.id.toString().padLeft(3, '0')}', 
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${lead.customerName} - ${lead.serviceType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue.shade900,
                    child: const Icon(Icons.person, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Developer', style: TextStyle(color: Colors.white38, fontSize: 9)),
                      Text('Assigned Agent', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Start Date', style: TextStyle(color: Colors.white38, fontSize: 9)),
                  Text('10 May 2024', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Due Date', style: TextStyle(color: Colors.white38, fontSize: 9)),
                  Text('10 Jun 2024', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: actionButton,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, LeadModel lead, LeadStatus nextStatus, String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
      ),
      onPressed: () {
        Provider.of<AppStateProvider>(context, listen: false).verifyLead(lead.id, nextStatus);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project updated to $label')));
      },
      child: Text(label),
    );
  }
}
