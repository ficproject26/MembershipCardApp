import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'staff_dashboards.dart';
import 'loan_tl/loan_tl_dashboard_overview.dart';
import 'loan_tl/loan_tl_requests_tab.dart';
import 'loan_tl/loan_tl_tasks_tab.dart';
import 'loan_tl/loan_tl_reports_tab.dart';
import 'credit_card_tl/credit_card_tl_dashboard_overview.dart';
import 'credit_card_tl/credit_card_tl_requests_tab.dart';
import 'shared/staff_profile_settings.dart';
import 'hr/hr_dashboard_main.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppStateProvider>();
      final staff = state.currentStaff;
      if (staff != null) {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.init(staff.id, 'Staff');
        if (chatProvider.socket != null) {
          context.read<CallProvider>().init(
            socket: chatProvider.socket!,
            currentUserId: staff.id,
            currentUserName: staff.name,
            currentUserType: 'Staff',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    
    final staff = state.currentStaff;
    if (staff == null) {
      return const Scaffold(body: Center(child: Text('Not logged in as staff')));
    }

    List<Widget> tabs;
    List<NavigationRailDestination> navDestinations;
    List<BottomNavigationBarItem> bottomNavItems;

    if (staff.role == StaffRole.hr) {
      tabs = [
        const HrDashboardMain(),
        StaffDashboardFactory.buildDashboardForRole(StaffRole.hr, isDark),
        StaffDashboardFactory.buildDashboardForRole(StaffRole.hr, isDark),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.group_add_outlined), selectedIcon: Icon(Icons.group_add), label: Text('Referrals')),
        NavigationRailDestination(icon: Icon(Icons.contact_mail_outlined), selectedIcon: Icon(Icons.contact_mail), label: Text('Leads')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.group_add_outlined), activeIcon: Icon(Icons.group_add), label: 'Referrals'),
        BottomNavigationBarItem(icon: Icon(Icons.contact_mail_outlined), activeIcon: Icon(Icons.contact_mail), label: 'Leads'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else if (staff.role == StaffRole.creditCardTL) {
      tabs = [
        CreditCardTlDashboardOverview(onNavigateToTab: (idx) => setState(() => _currentIndex = idx)),
        const CreditCardTlRequestsTab(),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text('Requests')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else if (staff.role == StaffRole.loanTL) {
      tabs = [
        LoanTlDashboardOverview(onNavigateToTab: (idx) => setState(() => _currentIndex = idx)),
        const LoanTlRequestsTab(),
        const LoanTlTasksTab(),
        const LoanTlReportsTab(),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text('Loan Requests')),
        NavigationRailDestination(icon: Icon(Icons.check_box_outlined), selectedIcon: Icon(Icons.check_box), label: Text('My Tasks')),
        NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Reports')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), activeIcon: Icon(Icons.check_box), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else {
      tabs = [
        StaffDashboardFactory.buildDashboardForRole(staff.role, isDark),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    }

    // Safety check if we dynamically change roles and index goes out of bounds
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3B6E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.work, color: Color(0xFFFFC107), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${staff.role.displayName} Portal',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isLargeScreen)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  'Welcome, ${staff.name}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
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
              Navigator.pop(context);
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
                ? [const Color(0xFF0D1B2A), const Color(0xFF0A1628)]
                : [const Color(0xFFF8F9FC), const Color(0xFFF0F4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLargeScreen
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.transparent,
                    indicatorColor: const Color(0xFF1A3B6E).withValues(alpha: 0.2),
                    selectedIconTheme: IconThemeData(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
                    unselectedIconTheme: IconThemeData(color: isDark ? Colors.white54 : Colors.black54),
                    selectedLabelTextStyle: TextStyle(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E), fontWeight: FontWeight.bold),
                    unselectedLabelTextStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    destinations: navDestinations,
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: tabs[_currentIndex]),
                ],
              )
            : tabs[_currentIndex],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF0A1628) : Colors.white,
              selectedItemColor: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E),
              unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
              items: bottomNavItems,
            ),
    );
  }
}
