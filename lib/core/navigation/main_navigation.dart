import 'package:flutter/material.dart';
import '../../../core/widgets/index.dart';
import '../../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../../features/claim_submission/presentation/pages/claims_list_screen.dart';
import '../../../features/claim_submission/presentation/pages/tasks_screen.dart';
import '../../../features/claim_submission/presentation/pages/profile_screen.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildPage(_currentIndex),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineIndicator(isOnline: _isOnline),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Claims',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              activeIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ClaimsListPage();
      case 2:
        return const TasksPage();
      case 3:
        return const ProfilePage();
      default:
        return const DashboardPage();
    }
  }
}
