import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'dashboard_tab.dart';
import 'services_tab.dart';
import 'wallet_tab.dart';
import 'share_tab.dart';
import 'training_tab.dart';

class AgentShell extends StatefulWidget {
  const AgentShell({Key? key}) : super(key: key);

  @override
  State<AgentShell> createState() => _AgentShellState();
}

class _AgentShellState extends State<AgentShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppStateProvider>();
      final agent = state.currentAgent;
      if (agent != null) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.init(agent.id, 'Agent');
        if (chatProvider.socket != null) {
          context.read<CallProvider>().init(
            socket: chatProvider.socket!,
            currentUserId: agent.id,
            currentUserName: agent.name,
            currentUserType: 'Agent',
          );
        }
      }
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent;
    final isDark = state.isDarkMode;

    if (agent == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session expired or Agent not found'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> tabs = [
      AgentDashboardTab(onNavigate: _navigateToTab),
      const AgentServicesTab(),
      const AgentWalletTab(),
      const AgentShareTab(),
      SharedMessagesTab(currentUserId: agent.id, currentUserName: agent.name, currentUserRole: 'Agent'),
      const AgentTrainingTab(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0C1017),
            border: Border(
              bottom: BorderSide(color: Color(0xFF1F2937), width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // FIC Logo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.all_inclusive, color: Color(0xFFFACC15), size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Name & Code
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFACC15).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                agent.membership.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFFFACC15),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              agent.agentCode,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('No new notifications'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, color: Colors.white60, size: 20),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFACC15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings / Logout
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.white60, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        color: const Color(0xFF0C1017),
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0C1017),
        selectedItemColor: const Color(0xFFFACC15),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_outlined),
            activeIcon: Icon(Icons.share),
            label: 'Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Academy',
          ),
        ],
      ),
    );
  }
}
