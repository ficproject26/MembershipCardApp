import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AgentMessagesTab extends StatefulWidget {
  const AgentMessagesTab({Key? key}) : super(key: key);

  @override
  State<AgentMessagesTab> createState() => _AgentMessagesTabState();
}

class _AgentMessagesTabState extends State<AgentMessagesTab> {
  final List<_StaffContact> _contacts = [
    _StaffContact(
      name: 'FIC Admin',
      role: 'ADMIN',
      avatar: Icons.admin_panel_settings,
      gradientColors: [Color(0xFF1A3B6E), Color(0xFF2563EB)],
      isOnline: true,
      lastMessage: '🔥 Double Commission Week is LIVE!',
      lastTime: '2:00 PM',
      unreadCount: 2,
    ),
    _StaffContact(
      name: 'Suresh Kumar',
      role: 'TEAM LEADER',
      avatar: Icons.supervisor_account,
      gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
      isOnline: true,
      lastMessage: 'Tomorrow training at 11 AM on Insurance.',
      lastTime: '11:15 AM',
      unreadCount: 1,
    ),
    _StaffContact(
      name: 'Meena HR',
      role: 'HR',
      avatar: Icons.badge,
      gradientColors: [Color(0xFFDB2777), Color(0xFFF472B6)],
      isOnline: false,
      lastMessage: 'Your onboarding documents are approved ✅',
      lastTime: 'Yesterday',
      unreadCount: 0,
    ),
    _StaffContact(
      name: 'FIC Help Desk',
      role: 'HELP',
      avatar: Icons.support_agent,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      isOnline: true,
      lastMessage: 'How can we assist you today?',
      lastTime: 'Yesterday',
      unreadCount: 0,
    ),
    _StaffContact(
      name: 'Accounts Team',
      role: 'ACCOUNTS',
      avatar: Icons.account_balance,
      gradientColors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
      isOnline: false,
      lastMessage: 'Payout of ₹15,000 processed to your bank.',
      lastTime: 'Mon',
      unreadCount: 0,
    ),
    _StaffContact(
      name: 'KYC Department',
      role: 'KYC',
      avatar: Icons.verified_user,
      gradientColors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
      isOnline: false,
      lastMessage: 'Please re-upload your PAN card image.',
      lastTime: 'Mon',
      unreadCount: 0,
    ),
    _StaffContact(
      name: 'IT Support',
      role: 'IT',
      avatar: Icons.computer,
      gradientColors: [Color(0xFFEA580C), Color(0xFFFB923C)],
      isOnline: true,
      lastMessage: 'App update v2.1 is now available.',
      lastTime: 'Sun',
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              const Spacer(),
              // Search
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search, color: Colors.white54, size: 20),
              ),
              const SizedBox(width: 8),
              // New message
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_square, color: Color(0xFFFFC107), size: 20),
              ),
            ],
          ),
        ),

        // Online staff stories row
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              // User's own "Add Status" bubble
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Status feature coming soon!'), backgroundColor: Color(0xFF1A3B6E)),
                  );
                },
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                          ),
                          child: const Icon(Icons.person, color: Colors.white54, size: 24),
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
                              child: const Icon(Icons.add, color: Colors.black, size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your Story',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'Add Status',
                      style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ),
              ),
              // Staff online stories
              ..._contacts.where((c) => c.isOnline).map((contact) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => _StoryViewScreen(contact: contact)));
                },
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    // Story ring
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0C1017),
                        ),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: contact.gradientColors),
                          ),
                          child: Icon(contact.avatar, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.name.split(' ').first,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      contact.role,
                      style: TextStyle(
                        color: contact.gradientColors.last,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                ),
              );
            }).toList(),
          ],
        ),
      ),

        Divider(height: 1, color: Colors.white.withOpacity(0.06)),

        // Chat list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (context, idx) {
              final contact = _contacts[idx];
              return _buildChatTile(context, contact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(BuildContext context, _StaffContact contact) {
    final hasUnread = contact.unreadCount > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ChatScreen(contact: contact),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: contact.gradientColors),
                    boxShadow: [
                      BoxShadow(
                        color: contact.gradientColors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(contact.avatar, color: Colors.white, size: 24),
                ),
                if (contact.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0C1017), width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Name, role, message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: contact.gradientColors.first.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          contact.role,
                          style: TextStyle(
                            color: contact.gradientColors.last,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.lastMessage,
                    style: TextStyle(
                      color: hasUnread ? Colors.white.withOpacity(0.8) : Colors.white38,
                      fontSize: 12,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time & unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  contact.lastTime,
                  style: TextStyle(
                    color: hasUnread ? const Color(0xFFFFC107) : Colors.white30,
                    fontSize: 10,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${contact.unreadCount}',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CHAT SCREEN ─────────────────────────────────────────────
class _ChatScreen extends StatefulWidget {
  final _StaffContact contact;
  const _ChatScreen({required this.contact});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Msg> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_getDefaultMessages(widget.contact));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Msg> _getDefaultMessages(_StaffContact contact) {
    switch (contact.role) {
      case 'ADMIN':
        return [
          _Msg('Welcome to FIC Membership Club! Your account has been activated successfully. 🎉', false, '10:30 AM'),
          _Msg('Thank you! Happy to be here.', true, '10:32 AM'),
          _Msg('🔥 Double Commission Week is LIVE! All Credit Card & Loan leads submitted this week earn 2x commissions.', false, '2:00 PM'),
          _Msg('New policy update: All agents must complete KYC within 7 days of registration.', false, '2:05 PM'),
        ];
      case 'TEAM LEADER':
        return [
          _Msg('Hi Rajesh, great work on the IT Projects lead! Keep it up.', false, '11:00 AM'),
          _Msg('Thanks TL! Working on more leads.', true, '11:05 AM'),
          _Msg('Let me know if you need help with BPO referrals.', false, '11:10 AM'),
          _Msg('Tomorrow we have a training session at 11 AM on Insurance lead conversions. Please join on time.', false, '11:15 AM'),
        ];
      case 'HR':
        return [
          _Msg('Hi Rajesh, welcome aboard! Please complete your onboarding profile.', false, '9:00 AM'),
          _Msg('Done! I have uploaded all the documents.', true, '9:30 AM'),
          _Msg('Your onboarding documents are approved ✅', false, 'Yesterday'),
        ];
      case 'HELP':
        return [
          _Msg('Hello! Welcome to FIC Help Desk. How can we assist you today?', false, '10:00 AM'),
          _Msg('I have a question about commission payouts.', true, '10:05 AM'),
          _Msg('Sure! Commission payouts are processed every Monday. You can check your wallet for the status.', false, '10:08 AM'),
        ];
      case 'ACCOUNTS':
        return [
          _Msg('Your wallet balance has been credited with ₹5,500 for approved leads.', false, 'Mon'),
          _Msg('Payout of ₹15,000 processed to your bank. Transaction ID: TXN-8921', false, 'Mon'),
          _Msg('Got it, thanks!', true, 'Mon'),
        ];
      case 'KYC':
        return [
          _Msg('Your Aadhaar card has been verified successfully.', false, 'Mon'),
          _Msg('Please re-upload your PAN card image. The current one is blurry.', false, 'Mon'),
        ];
      case 'IT':
        return [
          _Msg('App update v2.1 is now available. Please update for bug fixes and new features.', false, 'Sun'),
          _Msg('If you face any app issues, please share a screenshot here.', false, 'Sun'),
        ];
      default:
        return [_Msg('Hello!', false, 'Now')];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1017),
        elevation: 0,
        leadingWidth: 30,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: widget.contact.gradientColors),
                  ),
                  child: Icon(widget.contact.avatar, color: Colors.white, size: 18),
                ),
                if (widget.contact.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0C1017), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    widget.contact.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.contact.isOnline ? const Color(0xFF22C55E) : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone, color: Colors.white54, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Role badge
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: widget.contact.gradientColors.first.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.contact.gradientColors.first.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                '${widget.contact.role} • Messages are monitored',
                style: TextStyle(
                  color: widget.contact.gradientColors.last,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return _buildBubble(msg);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.attach_file, color: Colors.white38, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.trim().isNotEmpty) {
                        setState(() {
                          _messages.add(_Msg(_controller.text.trim(), true, 'Just now'));
                        });
                        _controller.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFC107), Color(0xFFFF8F00)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC107).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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

  Widget _buildBubble(_Msg msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
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
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
          border: Border.all(
            color: msg.isMe
                ? const Color(0xFFFFC107).withOpacity(0.2)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isMe ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg.time, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 12, color: const Color(0xFFFFC107).withOpacity(0.5)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MODELS ─────────────────────────────────────────────
class _StaffContact {
  final String name;
  final String role;
  final IconData avatar;
  final List<Color> gradientColors;
  final bool isOnline;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;

  _StaffContact({
    required this.name,
    required this.role,
    required this.avatar,
    required this.gradientColors,
    required this.isOnline,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });
}

class _Msg {
  final String text;
  final bool isMe;
  final String time;

  _Msg(this.text, this.isMe, this.time);
}

// ─── STORY VIEW SCREEN ─────────────────────────────────────────
class _StoryViewScreen extends StatefulWidget {
  final _StaffContact contact;
  const _StoryViewScreen({required this.contact});

  @override
  State<_StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<_StoryViewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (_) => _animationController.stop(),
          onTapUp: (_) => _animationController.forward(),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.contact.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.contact.avatar, color: Colors.white.withOpacity(0.5), size: 80),
                          const SizedBox(height: 30),
                          Text(
                            widget.contact.lastMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Progress Bar
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _animationController.value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 3,
                      ),
                    );
                  },
                ),
              ),
              // Header
              Positioned(
                top: 30,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                      child: Icon(widget.contact.avatar, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.contact.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(widget.contact.role, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Bottom reply area
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Reply to story...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.favorite_border, color: Colors.white, size: 22),
                      const SizedBox(width: 16),
                      const Icon(Icons.send, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
