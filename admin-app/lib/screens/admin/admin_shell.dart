import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'dashboard_tab.dart';
import 'membership_tab.dart';
import 'commission_tab.dart';
import 'agents_tab.dart';
import 'staff_tab.dart';
import 'leads_tab.dart';
import 'payouts_tab.dart';
import 'settings_tab.dart';
import '../admin_login_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({Key? key}) : super(key: key);

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.init('admin', 'Admin');
      if (chatProvider.socket != null) {
        context.read<CallProvider>().init(
          socket: chatProvider.socket!,
          currentUserId: 'admin',
          currentUserName: 'Admin',
          currentUserType: 'Admin',
        );
      }
    });
  }

  final List<Widget> _tabs = [
    const AdminDashboardTab(),
    const AdminLeadsTab(),
    const AdminAgentsTab(),
    const SharedMessagesTab(currentUserId: 'admin', currentUserName: 'Admin', currentUserRole: 'Admin'),
    const AdminSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    // We check screen size for side navigation layout (enterprise layout for web/tablet)
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1017) : const Color(0xFFF8F9FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Color(0xFFFFC107), size: 26),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                children: [
                  const TextSpan(text: 'FIC ', style: TextStyle(color: Color(0xFFFFC107))),
                  TextSpan(
                    text: 'Admin Portal',
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A3B6E)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: state.isDarkMode ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E),
            ),
            onPressed: () => state.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0C1017), const Color(0xFF0C1017)]
                : [const Color(0xFFF8F9FC), const Color(0xFFF0F4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLargeScreen
            ? Row(
                children: [
                  // Sidebar navigation
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: _currentIndex,
                              onDestinationSelected: (idx) {
                                setState(() {
                                  _currentIndex = idx;
                                });
                              },
                              labelType: NavigationRailLabelType.all,
                              backgroundColor: Colors.transparent,
                              indicatorColor: const Color(0xFF1A3B6E).withOpacity(0.2),
                              selectedIconTheme: IconThemeData(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
                              unselectedIconTheme: IconThemeData(color: isDark ? Colors.white54 : Colors.black54),
                              selectedLabelTextStyle: TextStyle(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E), fontWeight: FontWeight.bold),
                              unselectedLabelTextStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.dashboard_outlined),
                                  selectedIcon: Icon(Icons.dashboard),
                                  label: Text('Dashboard'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.assignment_outlined),
                                  selectedIcon: Icon(Icons.assignment),
                                  label: Text('Leads'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.people_outline),
                                  selectedIcon: Icon(Icons.people),
                                  label: Text('Agents & KYC'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.chat_outlined),
                                  selectedIcon: Icon(Icons.chat),
                                  label: Text('Messages'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.settings_outlined),
                                  selectedIcon: Icon(Icons.settings),
                                  label: Text('Settings'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: _tabs[_currentIndex]),
                ],
              )
            : _tabs[_currentIndex],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) {
                setState(() {
                  _currentIndex = idx;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF0C1017) : Colors.white,
              selectedItemColor: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E),
              unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'Leads',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Agents',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  activeIcon: Icon(Icons.chat),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
