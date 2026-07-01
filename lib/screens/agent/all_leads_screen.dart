import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/lead_model.dart';

class AllLeadsScreen extends StatefulWidget {
  final String initialFilter;
  const AllLeadsScreen({Key? key, required this.initialFilter}) : super(key: key);

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter == 'Total' ? 'All' : widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final myLeads = state.leads.where((l) => l.agentCode == state.currentAgent?.agentCode).toList();

    final filteredLeads = _selectedFilter == 'All' 
        ? myLeads 
        : myLeads.where((l) {
            if (_selectedFilter == 'Approved') return l.status == LeadStatus.Approved;
            if (_selectedFilter == 'Pending') return l.status == LeadStatus.Pending || l.status == LeadStatus.Stage1Pending || l.status == LeadStatus.Stage2Pending || l.status == LeadStatus.Stage3Pending;
            if (_selectedFilter == 'Rejected') return l.status == LeadStatus.Rejected || l.status == LeadStatus.Stage1Rejected || l.status == LeadStatus.Stage2Rejected || l.status == LeadStatus.Stage3Rejected;
            return false;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Referrals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Approved'),
                _buildFilterChip('Rejected'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredLeads.isEmpty 
              ? Center(child: Text('No $_selectedFilter leads found.', style: const TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: filteredLeads.length,
                  itemBuilder: (context, index) {
                    final lead = filteredLeads[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForStatus(lead.status).withOpacity(0.2),
                        child: Icon(Icons.person, color: _getColorForStatus(lead.status)),
                      ),
                      title: Text(lead.customerName ?? 'Customer', style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${lead.serviceType} - ${lead.status.name}', style: const TextStyle(color: Colors.white70)),
                      trailing: Text(lead.dateCreated.toString().split(' ')[0], style: const TextStyle(color: Colors.white54)),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: const Color(0xFFFACC15).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? const Color(0xFFFACC15) : Colors.white70),
    );
  }

  Color _getColorForStatus(LeadStatus status) {
    if (status == LeadStatus.Approved) return Colors.green;
    if (status == LeadStatus.Rejected || status == LeadStatus.Stage1Rejected || status == LeadStatus.Stage2Rejected || status == LeadStatus.Stage3Rejected) return Colors.red;
    return Colors.amber;
  }
}
