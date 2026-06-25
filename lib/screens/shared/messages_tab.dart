import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/staff_model.dart';

/// Shared Messages Tab — Works for Admin, Staff, and Agents
class SharedMessagesTab extends StatefulWidget {
  final String currentUserName;
  final String currentUserRole; // 'Admin', 'Staff', 'Agent'

  const SharedMessagesTab({
    Key? key,
    required this.currentUserName,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  State<SharedMessagesTab> createState() => _SharedMessagesTabState();
}

class _SharedMessagesTabState extends State<SharedMessagesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ContactItem> _buildContacts(AppStateProvider state) {
    final List<_ContactItem> contacts = [];

    // Admin is always a contact (unless you ARE admin)
    if (widget.currentUserRole != 'Admin') {
      contacts.add(_ContactItem(
        id: 'admin',
        name: 'FIC Admin',
        role: 'ADMIN',
        subtitle: 'System Administrator',
        icon: Icons.admin_panel_settings,
        gradientColors: [const Color(0xFF1A3B6E), const Color(0xFF2563EB)],
        isOnline: true,
        lastMessage: 'Welcome to FIC! Let us know if you need help.',
        lastTime: 'Now',
        unreadCount: 1,
      ));
    }

    // Add all staff members as contacts
    for (final staff in state.staff) {
      // Skip self
      if (widget.currentUserRole == 'Staff' && staff.name == widget.currentUserName) continue;

      contacts.add(_ContactItem(
        id: staff.id,
        name: staff.name,
        role: staff.role.displayName.toUpperCase(),
        subtitle: staff.role.displayName,
        icon: _iconForRole(staff.role),
        gradientColors: _colorsForRole(staff.role),
        isOnline: _randomOnline(staff.name),
        lastMessage: _defaultMessage(staff.role),
        lastTime: _randomTime(staff.name),
        unreadCount: staff.name.hashCode % 3 == 0 ? 1 : 0,
      ));
    }

    // Add agents as contacts (for admin/staff, show top agents)
    if (widget.currentUserRole == 'Admin' || widget.currentUserRole == 'Staff') {
      for (int i = 0; i < state.agents.length && i < 10; i++) {
        final agent = state.agents[i];
        contacts.add(_ContactItem(
          id: agent.id,
          name: agent.name,
          role: 'AGENT • ${agent.membership.name}',
          subtitle: 'Agent Code: ${agent.agentCode}',
          icon: Icons.person,
          gradientColors: [const Color(0xFF059669), const Color(0xFF10B981)],
          isOnline: i % 3 == 0,
          lastMessage: 'Lead update pending',
          lastTime: i == 0 ? 'Today' : 'Yesterday',
          unreadCount: i == 0 ? 2 : 0,
        ));
      }
    }

    // Built-in system channels
    contacts.add(_ContactItem(
      id: 'announcements',
      name: 'FIC Announcements',
      role: 'CHANNEL',
      subtitle: 'Official Updates',
      icon: Icons.campaign,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      isOnline: true,
      lastMessage: '🔥 Double Commission Week is LIVE!',
      lastTime: '2:00 PM',
      unreadCount: 3,
    ));

    contacts.add(_ContactItem(
      id: 'helpdesk',
      name: 'FIC Help Desk',
      role: 'SUPPORT',
      subtitle: 'Support & Queries',
      icon: Icons.support_agent,
      gradientColors: [const Color(0xFFDB2777), const Color(0xFFF472B6)],
      isOnline: true,
      lastMessage: 'How can we help you today?',
      lastTime: 'Online',
      unreadCount: 0,
    ));

    return contacts;
  }

  IconData _iconForRole(StaffRole role) {
    switch (role) {
      case StaffRole.creditCardTL:
        return Icons.credit_card;
      case StaffRole.loanTL:
        return Icons.account_balance;
      case StaffRole.insuranceTL:
        return Icons.shield;
      case StaffRole.itProjectManager:
        return Icons.code;
      case StaffRole.hr:
        return Icons.badge;
      case StaffRole.itSupport:
        return Icons.computer;
      case StaffRole.kycDepartment:
        return Icons.verified_user;
      case StaffRole.accountTeam:
        return Icons.account_balance_wallet;
      case StaffRole.ficHelpDesk:
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  List<Color> _colorsForRole(StaffRole role) {
    switch (role) {
      case StaffRole.creditCardTL:
        return [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)];
      case StaffRole.loanTL:
        return [const Color(0xFF0891B2), const Color(0xFF22D3EE)];
      case StaffRole.insuranceTL:
        return [const Color(0xFFEA580C), const Color(0xFFFB923C)];
      case StaffRole.itProjectManager:
        return [const Color(0xFF4F46E5), const Color(0xFF818CF8)];
      case StaffRole.hr:
        return [const Color(0xFFDB2777), const Color(0xFFF472B6)];
      case StaffRole.itSupport:
        return [const Color(0xFFEA580C), const Color(0xFFFB923C)];
      case StaffRole.kycDepartment:
        return [const Color(0xFF0891B2), const Color(0xFF22D3EE)];
      case StaffRole.accountTeam:
        return [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)];
      case StaffRole.ficHelpDesk:
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      default:
        return [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
    }
  }

  String _defaultMessage(StaffRole role) {
    switch (role) {
      case StaffRole.creditCardTL:
        return 'New credit card leads assigned.';
      case StaffRole.loanTL:
        return 'Loan application status updated.';
      case StaffRole.insuranceTL:
        return 'Insurance policy review pending.';
      case StaffRole.itProjectManager:
        return 'Sprint meeting at 3 PM today.';
      case StaffRole.hr:
        return 'Onboarding documents received ✅';
      case StaffRole.itSupport:
        return 'App update v2.1 available.';
      case StaffRole.kycDepartment:
        return 'KYC verification completed.';
      case StaffRole.accountTeam:
        return 'Payout processed to bank.';
      case StaffRole.ficHelpDesk:
        return 'Ticket #1024 resolved.';
      default:
        return 'Hey, how can I help?';
    }
  }

  bool _randomOnline(String name) => name.hashCode % 3 != 0;
  String _randomTime(String name) {
    final options = ['Now', '5m ago', '1h ago', 'Today', 'Yesterday'];
    return options[name.hashCode.abs() % options.length];
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final contacts = _buildContacts(state);

    final filtered = _searchQuery.isEmpty
        ? contacts
        : contacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final onlineContacts = contacts.where((c) => c.isOnline).toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1017),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.currentUserRole,
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: Colors.white54, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Broadcast message feature coming soon!'), backgroundColor: Color(0xFF1A3B6E)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_square, color: Color(0xFFFFC107), size: 20),
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF0C1017),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
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

        // Online contacts row (stories style)
        if (onlineContacts.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // Your status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                            ),
                            child: const Icon(Icons.person, color: Colors.white54, size: 22),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0C1017),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC107),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.black, size: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Online contacts
                ...onlineContacts.map((contact) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _openChat(context, contact),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [const Color(0xFFFFC107), const Color(0xFFFF6B35), const Color(0xFFE91E63)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0C1017)),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: contact.gradientColors),
                                  ),
                                  child: Icon(contact.icon, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 54,
                              child: Text(
                                contact.name.split(' ').first,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),

        Divider(height: 1, color: Colors.white.withOpacity(0.06)),

        // Contact list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty ? 'No contacts yet' : 'No contacts matching "$_searchQuery"',
                        style: const TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final contact = filtered[i];
                    return _buildContactTile(context, contact);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildContactTile(BuildContext context, _ContactItem contact) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openChat(context, contact),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: contact.gradientColors),
                    ),
                    child: Icon(contact.icon, color: Colors.white, size: 24),
                  ),
                  if (contact.isOnline)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0C1017), width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Name + Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: contact.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          contact.lastTime,
                          style: TextStyle(
                            color: contact.unreadCount > 0 ? const Color(0xFFFFC107) : Colors.white30,
                            fontSize: 11,
                            fontWeight: contact.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: contact.gradientColors.first.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            contact.role,
                            style: TextStyle(
                              color: contact.gradientColors.last,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.lastMessage,
                            style: TextStyle(
                              color: contact.unreadCount > 0 ? Colors.white70 : Colors.white38,
                              fontSize: 12,
                              fontWeight: contact.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC107),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${contact.unreadCount}',
                              style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, _ContactItem contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatScreen(
          contact: contact,
          currentUserName: widget.currentUserName,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
  }
}

// ─── Chat Screen ──────────────────────────────────────────────────────────────

class _ChatScreen extends StatefulWidget {
  final _ContactItem contact;
  final String currentUserName;
  final String currentUserRole;

  const _ChatScreen({
    required this.contact,
    required this.currentUserName,
    required this.currentUserRole,
  });

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_generateDemoMessages());
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_ChatMessage> _generateDemoMessages() {
    final contact = widget.contact;
    return [
      _ChatMessage(
        text: 'Hi ${widget.currentUserName}! 👋',
        isMe: false,
        time: '10:00 AM',
      ),
      _ChatMessage(
        text: contact.lastMessage,
        isMe: false,
        time: '10:02 AM',
      ),
      _ChatMessage(
        text: 'Thank you! I will check on that.',
        isMe: true,
        time: '10:05 AM',
      ),
      _ChatMessage(
        text: 'Sure! Let me know if you need anything else.',
        isMe: false,
        time: '10:06 AM',
      ),
    ];
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        time: TimeOfDay.now().format(context),
      ));
    });
    _msgController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: _getAutoReply(),
            isMe: false,
            time: TimeOfDay.now().format(context),
          ));
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  String _getAutoReply() {
    final replies = [
      'Got it! Will update you shortly. 👍',
      'Thanks for the update! I\'ll look into this.',
      'Sure, processing now. You\'ll get a notification.',
      'Noted! This has been forwarded to the team.',
      'Thanks! We\'ll get back to you within 24 hours.',
      'Great to hear! Keep up the good work! 🌟',
    ];
    return replies[DateTime.now().second % replies.length];
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1017),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: contact.gradientColors),
              ),
              child: Icon(contact.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  contact.isOnline ? 'Online' : 'Last seen recently',
                  style: TextStyle(
                    color: contact.isOnline ? const Color(0xFF10B981) : Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call coming soon!'), backgroundColor: Color(0xFF1A3B6E)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call coming soon!'), backgroundColor: Color(0xFF1A3B6E)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                return _buildMessageBubble(msg, contact);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF131A22),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white30, size: 20),
                          onPressed: () {},
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 20),
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

  Widget _buildMessageBubble(_ChatMessage msg, _ContactItem contact) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: msg.isMe ? 60 : 0,
          right: msg.isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe
              ? const Color(0xFFFFC107).withOpacity(0.15)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: msg.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: Border.all(
            color: msg.isMe
                ? const Color(0xFFFFC107).withOpacity(0.2)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isMe ? const Color(0xFFFFC107) : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Color(0xFF22D3EE), size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Models ────────────────────────────────────────────────────────────────────

class _ContactItem {
  final String id;
  final String name;
  final String role;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isOnline;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;

  _ContactItem({
    required this.id,
    required this.name,
    required this.role,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.isOnline,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}
