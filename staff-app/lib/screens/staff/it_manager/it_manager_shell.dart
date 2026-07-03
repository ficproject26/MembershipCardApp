import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'it_manager_settings_tab.dart';
import 'it_manager_dashboard_tab.dart';
import 'it_manager_requests_tab.dart';
import 'it_manager_projects_tab.dart';

class ITProjectManagerShell extends StatefulWidget {
  const ITProjectManagerShell({super.key});

  @override
  State<ITProjectManagerShell> createState() => _ITProjectManagerShellState();
}

class _ITProjectManagerShellState extends State<ITProjectManagerShell> {
  int _currentIndex = 0;
  int _requestsTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final staff = state.currentStaff;

    if (staff == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final List<Widget> tabs = [
      ITManagerDashboardTab(
        onNavigate: (index, {subIndex}) {
          setState(() {
            _currentIndex = index;
            if (index == 1 && subIndex != null) _requestsTabIndex = subIndex;
          });
        },
      ),
      ITManagerRequestsTab(initialIndex: _requestsTabIndex),
      const ITManagerProjectsTab(),
      SharedMessagesTab(currentUserId: staff.id, currentUserName: staff.name, currentUserRole: 'Project Manager'),
      const ITManagerSettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: Color(0xFFFFC107), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Manager Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('IT Project Requests', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: Badge(
              label: const Text('3'),
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.notifications_none, color: Colors.white70),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0F172A),
        child: tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
