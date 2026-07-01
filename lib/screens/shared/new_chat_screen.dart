import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/staff_model.dart';

class NewChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  
  const NewChatScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Build contact list from all staff and agents
    List<Map<String, dynamic>> allContacts = [];
    
    if (widget.currentUserRole != 'Admin') {
      allContacts.add({
        'id': 'admin',
        'name': 'FIC Admin',
        'role': 'ADMIN',
        'subtitle': 'System Administrator',
        'icon': Icons.admin_panel_settings,
        'colors': [const Color(0xFF1A3B6E), const Color(0xFF2563EB)],
      });
    }

    for (final staff in state.staff) {
      if (staff.id == widget.currentUserId) continue;
      allContacts.add({
        'id': staff.id,
        'name': staff.name,
        'role': staff.role.displayName.toUpperCase(),
        'subtitle': staff.role.displayName,
        'icon': Icons.person,
        'colors': [const Color(0xFF6B7280), const Color(0xFF9CA3AF)],
      });
    }

    for (final agent in state.agents) {
      if (agent.id == widget.currentUserId) continue;
      allContacts.add({
        'id': agent.id,
        'name': agent.name,
        'role': 'AGENT',
        'subtitle': 'Agent Code: ${agent.agentCode}',
        'icon': Icons.person,
        'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      });
    }

    final filtered = _searchQuery.isEmpty 
        ? allContacts 
        : allContacts.where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1017),
        elevation: 0,
        title: const Text('Select Contact', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search for someone...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white30, size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final contact = filtered[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: contact['colors']),
                    ),
                    child: Icon(contact['icon'], color: Colors.white, size: 20),
                  ),
                  title: Text(contact['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  subtitle: Text(contact['subtitle'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
