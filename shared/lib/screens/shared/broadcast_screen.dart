import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/staff_model.dart';

class BroadcastScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  
  const BroadcastScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  
  List<Map<String, dynamic>> _allContacts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  void _loadContacts() {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    List<Map<String, dynamic>> contacts = [];
    
    if (widget.currentUserRole != 'Admin') {
      contacts.add({
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
      contacts.add({
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
      contacts.add({
        'id': agent.id,
        'name': agent.name,
        'role': 'AGENT',
        'subtitle': 'Agent Code: ${agent.agentCode}',
        'icon': Icons.person,
        'colors': [const Color(0xFF059669), const Color(0xFF10B981)],
      });
    }

    setState(() {
      _allContacts = contacts;
    });
  }

  void _sendBroadcast() {
    final text = _msgController.text.trim();
    if (text.isEmpty || _selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message and select at least one recipient.')),
      );
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    for (final contactId in _selectedIds) {
      final contact = _allContacts.firstWhere((c) => c['id'] == contactId);
      final role = contact['role'].toString().contains('AGENT') ? 'Agent' : 
                   contact['id'] == 'admin' ? 'Admin' : 'Staff';
      chatProvider.sendMessage(contactId, role, text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Broadcast message sent!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty 
        ? _allContacts 
        : _allContacts.where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1017),
        elevation: 0,
        title: const Text('New Broadcast', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_selectedIds.length == _allContacts.length) {
                  _selectedIds.clear();
                } else {
                  _selectedIds.addAll(_allContacts.map((c) => c['id'] as String));
                }
              });
            },
            child: Text(
              _selectedIds.length == _allContacts.length ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: Color(0xFFFFC107)),
            ),
          )
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  '${_selectedIds.length} selected',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final contact = filtered[index];
                final isSelected = _selectedIds.contains(contact['id']);
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
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: const Color(0xFFFFC107),
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white54),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(contact['id']);
                        } else {
                          _selectedIds.remove(contact['id']);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(contact['id']);
                      } else {
                        _selectedIds.add(contact['id']);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131A22),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type broadcast message...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendBroadcast,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
