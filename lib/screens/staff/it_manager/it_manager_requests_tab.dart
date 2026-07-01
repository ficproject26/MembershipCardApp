import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../models/lead_model.dart';
import 'shared_widgets.dart';

class ITManagerRequestsTab extends StatefulWidget {
  final int initialIndex;
  const ITManagerRequestsTab({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<ITManagerRequestsTab> createState() => _ITManagerRequestsTabState();
}

class _ITManagerRequestsTabState extends State<ITManagerRequestsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void didUpdateWidget(ITManagerRequestsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allLeads = state.leads.where((l) => l.serviceType == 'IT Projects').toList();
    
    final pending = allLeads.where((l) => l.status == LeadStatus.Pending).toList();
    final approved = allLeads.where((l) => l.status == LeadStatus.Stage1Approved).toList();
    final inProgress = allLeads.where((l) => l.status == LeadStatus.Stage2Approved || l.status == LeadStatus.Stage3Approved).toList();
    final completed = allLeads.where((l) => l.status == LeadStatus.Approved).toList();
    final rejected = allLeads.where((l) => l.status == LeadStatus.Rejected).toList();

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
                  Text('IT Project Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('All IT Project Requests', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.filter_alt_outlined, color: Colors.white70), onPressed: () {}),
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
            _buildTabChip('Pending (${pending.length})', 1),
            _buildTabChip('Approved (${approved.length})', 2),
            _buildTabChip('In Progress (${inProgress.length})', 3),
            _buildTabChip('Completed (${completed.length})', 4),
            _buildTabChip('Rejected (${rejected.length})', 5),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(allLeads),
              _buildList(pending),
              _buildList(approved),
              _buildList(inProgress),
              _buildList(completed),
              _buildList(rejected),
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
      return const Center(child: Text('No requests found', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        return ITProjectRequestCard(lead: leads[index]);
      },
    );
  }
}
