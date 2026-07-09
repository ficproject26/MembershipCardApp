import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/status_provider.dart';
import '../../models/staff_model.dart';
import '../../models/message_model.dart';
import 'new_chat_screen.dart';
import 'video_player_widget.dart';
import 'full_screen_viewer.dart';
import 'story_viewer_widget.dart';
import 'status_upload_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../services/api_client.dart';
/// Shared Messages Tab — Works for Admin, Staff, and Agents
class SharedMessagesTab extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserRole; // 'Admin', 'Staff', 'Agent'

  const SharedMessagesTab({
    Key? key,
    required this.currentUserId,
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init(widget.currentUserId, widget.currentUserRole);
      context.read<StatusProvider>().fetchStatuses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ContactItem> _buildContacts(AppStateProvider state, ChatProvider chat) {
    final List<_ContactItem> contacts = [];

    // Admin is always a contact (unless you ARE admin)
    if (widget.currentUserRole != 'Admin') {
      final adminMsg = chat.getLastMessageFor('admin');
      contacts.add(_ContactItem(
        id: 'admin',
        name: 'FIC Admin',
        role: 'ADMIN',
        subtitle: 'System Administrator',
        icon: Icons.admin_panel_settings,
        gradientColors: [const Color(0xFF1A3B6E), const Color(0xFF2563EB)],
        isOnline: true,
        lastMessage: adminMsg?.content ?? 'Welcome to FIC! Let us know if you need help.',
        lastTime: adminMsg != null ? _formatTime(adminMsg.createdAt) : 'Now',
        lastMessageTime: adminMsg?.createdAt ?? DateTime.now(),
        unreadCount: 0,
      ));
    }

    // Add all staff members as contacts
    for (final staff in state.staff) {
      if (widget.currentUserRole == 'Staff' && staff.id == widget.currentUserId) continue;
      
      final msg = chat.getLastMessageFor(staff.id);

      if (msg == null) continue; // Only show active chats

      contacts.add(_ContactItem(
        id: staff.id,
        name: staff.name,
        role: staff.role.displayName.toUpperCase(),
        subtitle: staff.role.displayName,
        icon: _iconForRole(staff.role),
        gradientColors: _colorsForRole(staff.role),
        isOnline: true,
        lastMessage: msg.content,
        lastTime: _formatTime(msg.createdAt),
        lastMessageTime: msg.createdAt,
        unreadCount: 0,
      ));
    }

    // Add agents as contacts (for admin/staff, show top agents)
    if (widget.currentUserRole == 'Admin' || widget.currentUserRole == 'Staff' || widget.currentUserRole == 'Project Manager') {
      for (int i = 0; i < state.agents.length; i++) {
        final agent = state.agents[i];
        final msg = chat.getLastMessageFor(agent.id);

        if (msg == null) continue; // Only show active chats

        contacts.add(_ContactItem(
          id: agent.id,
          name: agent.name,
          role: 'AGENT',
          subtitle: 'Agent Code: ${agent.agentCode}',
          icon: Icons.person,
          gradientColors: [const Color(0xFF059669), const Color(0xFF10B981)],
          isOnline: true,
          lastMessage: msg.content,
          lastTime: _formatTime(msg.createdAt),
          lastMessageTime: msg.createdAt,
          unreadCount: 0,
        ));
      }
    }

    // Built-in system channels removed

    // Sort by recent messages
    contacts.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final chat = Provider.of<ChatProvider>(context);
    final contacts = _buildContacts(state, chat);

    final filtered = _searchQuery.isEmpty
        ? contacts
        : contacts.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final statusProvider = Provider.of<StatusProvider>(context);
    final activeStatuses = statusProvider.statuses;
    final myStatuses = activeStatuses.where((s) => s.userId == widget.currentUserId).toList();
    final otherStatuses = activeStatuses.where((s) => s.userId != widget.currentUserId).toList();
    
    final Map<String, List<StatusUpdate>> groupedOtherStatuses = {};
    for (var s in otherStatuses) {
      groupedOtherStatuses.putIfAbsent(s.userId, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.chat, color: Colors.black),
        onPressed: () async {
          final selectedContact = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewChatScreen(
                currentUserId: widget.currentUserId,
                currentUserRole: widget.currentUserRole,
              ),
            ),
          );
          if (selectedContact != null && mounted) {
            _openChat(
              context,
              _ContactItem(
                id: selectedContact['id'],
                name: selectedContact['name'],
                role: selectedContact['role'],
                subtitle: selectedContact['subtitle'],
                icon: selectedContact['icon'],
                gradientColors: selectedContact['colors'],
                isOnline: true,
                lastMessage: '',
                lastTime: '',
                unreadCount: 0,
              ),
            );
          }
        },
      ),
      body: Column(
        children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8F9FC),
            border: Border(
              bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
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
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Broadcast message feature coming soon!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
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
          color: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8F9FC),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search contacts...',
              hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white30 : Colors.black38, size: 18),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Online contacts row (stories style)
        if (activeStatuses.isNotEmpty || true)
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
                          GestureDetector(
                            onTap: () {
                              if (myStatuses.isNotEmpty) {
                                _showStoryViewer(context, myStatuses, true);
                              } else {
                                _showStatusOptionsBottomSheet(context);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(myStatuses.isNotEmpty ? 2.5 : 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: myStatuses.isNotEmpty 
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFFC107), Color(0xFFFF6B35), Color(0xFFE91E63)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ) 
                                  : null,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(myStatuses.isNotEmpty ? 2 : 0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: myStatuses.isNotEmpty ? const Color(0xFF0C1017) : Colors.transparent,
                                ),
                                child: Container(
                                  width: myStatuses.isNotEmpty ? 42 : 50,
                                  height: myStatuses.isNotEmpty ? 42 : 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.05),
                                    border: myStatuses.isEmpty ? Border.all(color: Colors.white.withOpacity(0.1), width: 1.5) : null,
                                  ),
                                  child: statusProvider.isUploading && statusProvider.uploadingFile != null
                                      ? ClipOval(
                                          child: (kIsWeb 
                                              ? Image.network(statusProvider.uploadingFile!.path, fit: BoxFit.cover, width: 50, height: 50)
                                              : Image.file(statusProvider.uploadingFile!, fit: BoxFit.cover, width: 50, height: 50)),
                                        )
                                      : const Icon(Icons.person, color: Colors.white54, size: 22),
                                ),
                              ),
                            ),
                          ),
                          if (statusProvider.isUploading)
                            Positioned.fill(
                              child: const CircularProgressIndicator(
                                color: Color(0xFFFFC107),
                                strokeWidth: 2.5,
                              ),
                            ),
                          if (statusProvider.isUploading)
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () {
                                  // In future: cancel upload token
                                },
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          if (!statusProvider.isUploading)
                            Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                _showStatusOptionsBottomSheet(context);
                              },
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Other Statuses
                ...groupedOtherStatuses.values.map((userStatuses) {
                  final status = userStatuses.first;
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showStoryViewer(context, userStatuses, false);
                      },
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
                                    gradient: LinearGradient(colors: [const Color(0xFF0891B2), const Color(0xFF22D3EE)]),
                                  ),
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 54,
                              child: Text(
                                status.userName.split(' ').first,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
      ),
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

  void _showStatusOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Text Status', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddStatusDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text('Photo Status', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatusUploadScreen(
                        file: File(image.path),
                        type: 'IMAGE',
                        currentUserId: widget.currentUserId,
                        currentUserName: widget.currentUserName,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: const Text('Video Status', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final ImagePicker picker = ImagePicker();
                final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                if (video != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatusUploadScreen(
                        file: File(video.path),
                        type: 'VIDEO',
                        currentUserId: widget.currentUserId,
                        currentUserName: widget.currentUserName,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStatusDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('Add Status Update', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'What are you working on?',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                final success = await Provider.of<StatusProvider>(context, listen: false).postStatus(
                  widget.currentUserId,
                  widget.currentUserName,
                  textController.text.trim(),
                );
                Navigator.pop(ctx);
                if (success && mounted) {
                  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Status updated!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                }
              }
            },
            child: const Text('Post', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showStoryViewer(BuildContext context, List<StatusUpdate> statuses, bool isCurrentUser) {
    showDialog(
      context: context,
      builder: (ctx) => StoryViewerWidget(
        statuses: statuses,
        isCurrentUser: isCurrentUser,
        currentUserId: widget.currentUserId,
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
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchHistory(widget.contact.id);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final role = widget.contact.role.contains('AGENT') ? 'Agent' : 
                 widget.contact.id == 'admin' ? 'Admin' : 'Staff';

    context.read<ChatProvider>().sendMessage(widget.contact.id, role, text);
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
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final messages = context.watch<ChatProvider>().getMessagesFor(contact.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1017),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF131A22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: contact.gradientColors),
                      ),
                      child: Icon(contact.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                          Text(contact.role, style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                content: const Text('Full profile details will be implemented in a future update.', style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(color: Color(0xFFFFC107))),
                  ),
                ],
              ),
            );
          },
          child: Row(
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white54),
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Video call coming soon!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white54),
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Voice call coming soon!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('More options coming soon!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
            },
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
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                final isMe = msg.senderId != contact.id;
                final localTime = msg.createdAt.toLocal();
                final hour = localTime.hour > 12 ? localTime.hour - 12 : (localTime.hour == 0 ? 12 : localTime.hour);
                final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
                final time = '$hour:${localTime.minute.toString().padLeft(2, '0')} $amPm';
                return _buildMessageBubble(msg, isMe, time, contact);
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
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2630),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 32,
                            runSpacing: 24,
                            children: [
                              _buildAttachIcon(Icons.insert_drive_file, Colors.indigo, 'Document', ctx),
                              _buildAttachIcon(Icons.camera_alt, Colors.pink, 'Camera', ctx),
                              _buildAttachIcon(Icons.photo, Colors.purple, 'Gallery', ctx),
                              _buildAttachIcon(Icons.headset, Colors.orange, 'Audio', ctx),
                              _buildAttachIcon(Icons.location_on, Colors.green, 'Location', ctx),
                              _buildAttachIcon(Icons.person, Colors.blue, 'Contact', ctx),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white54, size: 20),
                    ),
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
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _showEmojiPicker = !_showEmojiPicker;
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        if (_showEmojiPicker) {
                          setState(() {
                            _showEmojiPicker = false;
                          });
                        }
                      },
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
          
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _msgController,
                config: const Config(
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: Color(0xFF131A22),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, String time, _ContactItem contact) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFFFC107).withOpacity(0.15)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isMe
                ? const Color(0xFFFFC107).withOpacity(0.2)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.type == 'IMAGE' && msg.mediaUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenViewer(
                    url: '${ApiClient.instance.options.baseUrl}${msg.mediaUrl}',
                    isVideo: false,
                  )));
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      '${ApiClient.instance.options.baseUrl}${msg.mediaUrl}',
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else if (msg.type == 'VIDEO' && msg.mediaUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenViewer(
                    url: '${ApiClient.instance.options.baseUrl}${msg.mediaUrl}',
                    isVideo: true,
                  )));
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      // The VideoPlayerWidget already handles internal tap for play/pause,
                      // so we use AbsorbPointer to prevent it from absorbing the tap
                      child: AbsorbPointer(
                        child: VideoPlayerWidget(
                          url: '${ApiClient.instance.options.baseUrl}${msg.mediaUrl}',
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (msg.type == 'DOCUMENT' || msg.type == 'AUDIO')
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(msg.type == 'AUDIO' ? Icons.headset : Icons.insert_drive_file, color: isMe ? const Color(0xFFFFC107) : Colors.white70),
                    const SizedBox(width: 8),
                    Flexible(child: Text(msg.content, style: TextStyle(color: isMe ? const Color(0xFFFFC107) : Colors.white))),
                  ],
                ),
              )
            else if (msg.type == 'LOCATION')
              GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://maps.google.com/?q=${msg.content}')),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: isMe ? const Color(0xFFFFC107) : Colors.white70),
                      const SizedBox(width: 8),
                      Text('View Location', style: TextStyle(color: isMe ? const Color(0xFFFFC107) : Colors.white, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              )
            else if (msg.type == 'CONTACT')
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: isMe ? const Color(0xFFFFC107) : Colors.white70),
                    const SizedBox(width: 8),
                    Text(msg.content, style: TextStyle(color: isMe ? const Color(0xFFFFC107) : Colors.white)),
                  ],
                ),
              ),
            
            if (msg.type == 'TEXT')
              Text(
                msg.content,
                style: TextStyle(
                  color: isMe ? const Color(0xFFFFC107) : Colors.white,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
                if (isMe) ...[
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

  Widget _buildAttachIcon(IconData icon, Color color, String label, BuildContext ctx) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        await _handleAttachAction(label);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _handleAttachAction(String action) async {
    final provider = context.read<ChatProvider>();
    final role = widget.contact.role.contains('AGENT') ? 'Agent' : 
                 widget.contact.id == 'admin' ? 'Admin' : 'Staff';

    try {
      if (action == 'Camera' || action == 'Gallery') {
        final picker = ImagePicker();
        XFile? mediaFile;
        String type = 'IMAGE';
        String msgContent = '📷 Image';

        if (action == 'Gallery') {
          mediaFile = await picker.pickMedia();
          if (mediaFile != null) {
            final ext = mediaFile.path.toLowerCase();
            if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi') || ext.endsWith('.mkv')) {
              type = 'VIDEO';
              msgContent = '🎥 Video';
            }
          }
        } else {
          mediaFile = await picker.pickImage(source: ImageSource.camera);
        }

        if (mediaFile != null) {
          provider.sendMediaMessage(widget.contact.id, role, File(mediaFile.path), type, msgContent);
        }
      } else if (action == 'Document' || action == 'Audio') {
        final result = await FilePicker.platform.pickFiles(
          type: action == 'Audio' ? FileType.audio : FileType.any,
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final content = action == 'Audio' ? '🎵 Audio Message' : '📄 ${result.files.single.name}';
          provider.sendMediaMessage(widget.contact.id, role, file, action.toUpperCase(), content);
        }
      } else if (action == 'Location') {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        final position = await Geolocator.getCurrentPosition();
        final loc = '${position.latitude},${position.longitude}';
        provider.sendMessage(widget.contact.id, role, loc, type: 'LOCATION');
      } else if (action == 'Contact') {
        final status = await FlutterContacts.permissions.request(PermissionType.read);
        if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
          final contact = await FlutterContacts.native.showPicker();
          if (contact != null) {
            final fullContact = await FlutterContacts.get(contact.id!);
            if (fullContact != null && fullContact.phones.isNotEmpty) {
              final content = '${fullContact.displayName}\n${fullContact.phones.first.number}';
              provider.sendMessage(widget.contact.id, role, content, type: 'CONTACT');
            }
          }
        }
      }
    } catch (e) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Error processing $action: $e'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
    }
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
  final DateTime? lastMessageTime;
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
    this.lastMessageTime,
    required this.unreadCount,
  });
}


