import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/staff_model.dart';
import 'staff_dashboards.dart';
import '../shared/messages_tab.dart';
import '../admin/settings_tab.dart';
import 'loan_tl/loan_tl_dashboard_overview.dart';
import 'loan_tl/loan_tl_requests_tab.dart';
import 'loan_tl/loan_tl_tasks_tab.dart';
import 'loan_tl/loan_tl_reports_tab.dart';
import 'kyc_team/kyc_team_dashboard_overview.dart';
import 'kyc_team/kyc_team_requests_tab.dart';
import 'kyc_team/kyc_team_tasks_tab.dart';
import 'kyc_team/kyc_team_documents_tab.dart';
import 'kyc_team/kyc_team_reports_tab.dart';
import 'shared/staff_profile_settings.dart';
import '../admin/settings_tab.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({Key? key}) : super(key: key);

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    
    final staff = state.currentStaff;
    if (staff == null) {
      return const Scaffold(body: Center(child: Text('Not logged in as staff')));
    }

    List<Widget> _tabs;
    List<NavigationRailDestination> _navDestinations;
    List<BottomNavigationBarItem> _bottomNavItems;

    if (staff.role == StaffRole.loanTL) {
      _tabs = [
        const LoanTlDashboardOverview(),
        const LoanTlRequestsTab(),
        const LoanTlTasksTab(),
        const LoanTlReportsTab(),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      _navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text('Loan Requests')),
        NavigationRailDestination(icon: Icon(Icons.check_box_outlined), selectedIcon: Icon(Icons.check_box), label: Text('My Tasks')),
        NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Reports')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      _bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), activeIcon: Icon(Icons.check_box), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else if (staff.role == StaffRole.kycDepartment) {
      _tabs = [
        const KycTeamDashboardOverview(),
        const KycTeamRequestsTab(),
        const KycTeamDocumentsTab(),
        const KycTeamReportsTab(),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const StaffProfileSettingsTab(),
      ];
      _navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: Text('KYC Requests')),
        NavigationRailDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: Text('Documents')),
        NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Reports')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
      ];
      _bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.security_outlined), activeIcon: Icon(Icons.security), label: 'KYC'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Docs'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      _tabs = [
        StaffDashboardFactory.buildDashboardForRole(staff.role, isDark),
        SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Staff'),
        const AdminSettingsTab(),
      ];
      _navDestinations = const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Messages')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
      ];
      _bottomNavItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ];
    }

    // Safety check if we dynamically change roles and index goes out of bounds
    if (_currentIndex >= _tabs.length) {
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
                    indicatorColor: const Color(0xFF1A3B6E).withOpacity(0.2),
                    selectedIconTheme: IconThemeData(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
                    unselectedIconTheme: IconThemeData(color: isDark ? Colors.white54 : Colors.black54),
                    selectedLabelTextStyle: TextStyle(color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E), fontWeight: FontWeight.bold),
                    unselectedLabelTextStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    destinations: _navDestinations,
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
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF0A1628) : Colors.white,
              selectedItemColor: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E),
              unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
              items: _bottomNavItems,
            ),
    );
  }
}
