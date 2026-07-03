import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'shared_widgets.dart'; // We will create this for reusable cards

class ITManagerDashboardTab extends StatefulWidget {
  final void Function(int, {int? subIndex})? onNavigate;
  const ITManagerDashboardTab({super.key, this.onNavigate});

  @override
  State<ITManagerDashboardTab> createState() => _ITManagerDashboardTabState();
}

class _ITManagerDashboardTabState extends State<ITManagerDashboardTab> {
  late String _pipelineFilter;
  late List<DateTime> _availableMonths;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availableMonths = List.generate(12, (index) => DateTime(now.year, now.month - index, 1));
    _pipelineFilter = _formatMonth(_availableMonths.first);
  }

  String _formatMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allLeads = state.leads.where((l) => l.serviceType == 'IT Projects').toList();
    
    int pending = allLeads.where((l) => l.status == LeadStatus.Pending).length;
    int approved = allLeads.where((l) => l.status == LeadStatus.Stage1Approved).length;
    int inProgress = allLeads.where((l) => l.status == LeadStatus.Stage2Approved || l.status == LeadStatus.Stage3Approved).length;
    int completed = allLeads.where((l) => l.status == LeadStatus.Approved).length;
    int rejected = allLeads.where((l) => l.status == LeadStatus.Rejected).length;

    final selectedDate = _availableMonths.firstWhere((d) => _formatMonth(d) == _pipelineFilter, orElse: () => _availableMonths.first);
    DateTime startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime endDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    final pipelineLeads = allLeads.where((l) => l.dateCreated.isAfter(startDate) && l.dateCreated.isBefore(endDate)).toList();
    int pipePending = pipelineLeads.where((l) => l.status == LeadStatus.Pending).length;
    int pipeApproved = pipelineLeads.where((l) => l.status == LeadStatus.Stage1Approved || l.status == LeadStatus.Stage2Approved || l.status == LeadStatus.Stage3Approved).length;
    int pipeInProgress = pipelineLeads.where((l) => l.status == LeadStatus.Stage2Approved).length;
    int pipeTesting = pipelineLeads.where((l) => l.status == LeadStatus.Stage3Approved).length;
    int pipeCompleted = pipelineLeads.where((l) => l.status == LeadStatus.Approved).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard('Total Requests', '${allLeads.length}', 'All Time', Icons.file_copy, Colors.blue, HoverEffectType.sweep, () => widget.onNavigate?.call(1, subIndex: 0)),
              _buildStatCard('Pending Requests', '$pending', 'Awaiting Review', Icons.hourglass_empty, Colors.orange, HoverEffectType.glow, () => widget.onNavigate?.call(1, subIndex: 1)),
              _buildStatCard('Approved', '$approved', 'Projects', Icons.check_circle, Colors.green, HoverEffectType.lift, () => widget.onNavigate?.call(1, subIndex: 2)),
              _buildStatCard('Rejected', '$rejected', 'Requests', Icons.cancel, Colors.red, HoverEffectType.lift, () => widget.onNavigate?.call(1, subIndex: 5)),
              _buildStatCard('In Progress', '$inProgress', 'Projects', Icons.pending, Colors.purple, HoverEffectType.glow, () => widget.onNavigate?.call(1, subIndex: 3)),
              _buildStatCard('Completed', '$completed', 'Projects', Icons.flag, Colors.teal, HoverEffectType.sweep, () => widget.onNavigate?.call(1, subIndex: 4)),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('IT Project Requests', 'View All >', () { widget.onNavigate?.call(1, subIndex: 0); }),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('All', true, () => widget.onNavigate?.call(1, subIndex: 0)),
                _buildChip('Pending', false, () => widget.onNavigate?.call(1, subIndex: 1)),
                _buildChip('Approved', false, () => widget.onNavigate?.call(1, subIndex: 2)),
                _buildChip('In Progress', false, () => widget.onNavigate?.call(1, subIndex: 3)),
                _buildChip('Rejected', false, () => widget.onNavigate?.call(1, subIndex: 5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allLeads.length > 3 ? 3 : allLeads.length,
            itemBuilder: (context, index) {
              final lead = allLeads[index];
              return ITProjectRequestCard(lead: lead);
            },
          ),
          
          const SizedBox(height: 24),
          _buildDropdownHeader('Project Pipeline'),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPipelineStep(Icons.file_copy, '$pipePending', 'New\nRequests', Colors.blue, true),
                _buildPipelineStep(Icons.check_circle, '$pipeApproved', 'Approved', Colors.green, true),
                _buildPipelineStep(Icons.code, '$pipeInProgress', 'In\nDevelopment', Colors.purple, true),
                _buildPipelineStep(Icons.assignment, '$pipeTesting', 'Testing', Colors.orange, true),
                _buildPipelineStep(Icons.flag, '$pipeCompleted', 'Completed', Colors.teal, false),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Requests', 'View All >', () { widget.onNavigate?.call(1, subIndex: 0); }),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF162032),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allLeads.length > 3 ? 3 : allLeads.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final lead = allLeads[index];
                return ListTile(
                  onTap: () { widget.onNavigate?.call(1); },
                  leading: const Icon(Icons.circle, color: Colors.purple, size: 12),
                  title: Text(lead.serviceType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${lead.customerName} - ${lead.details['Company Name'] ?? "No Company"}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Agent: User ${lead.agentCode}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const Text('1 hour ago', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(lead.status.name.replaceAll('Stage1', '').replaceAll('Stage2', ''), style: const TextStyle(color: Colors.orange, fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle, IconData icon, Color color, HoverEffectType effectType, VoidCallback onTap) {
    return AdvancedHoverCard(
      onTap: onTap,
      effectType: effectType,
      effectColor: color,
      backgroundColor: const Color(0xFF162032),
      builder: (context, isHovered) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon, 
                  color: color, 
                  size: 24,
                  shadows: isHovered ? [Shadow(color: color, blurRadius: 12)] : [],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isHovered && effectType == HoverEffectType.glow ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.centerLeft,
                      child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: TextStyle(color: color, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Text(actionText, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        PopupMenuButton<String>(
          color: const Color(0xFF162032),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Text(_pipelineFilter, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.blueAccent, size: 16),
              ],
            ),
          ),
          onSelected: (value) {
            setState(() {
              _pipelineFilter = value;
            });
          },
          itemBuilder: (context) {
            return _availableMonths.map((date) {
              final formatted = _formatMonth(date);
              return PopupMenuItem(
                value: formatted,
                child: Text(formatted, style: const TextStyle(color: Colors.white)),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
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
      ),
    );
  }

  Widget _buildPipelineStep(IconData icon, String count, String label, Color color, bool hasNext) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(count, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        if (hasNext)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.chevron_right, color: Colors.white54, size: 24),
          ),
      ],
    );
  }
}
