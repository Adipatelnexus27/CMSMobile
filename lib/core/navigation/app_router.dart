import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/otp_verification_screen.dart';
import '../../features/claim_submission/presentation/pages/claims_list_screen.dart';
import '../../features/claim_submission/presentation/pages/claim_detail_screen.dart';
import '../../features/claim_submission/presentation/pages/tasks_screen.dart';
import '../../features/claim_submission/presentation/pages/approval_screen.dart';
import '../../features/claim_submission/presentation/pages/complaint_screen.dart';
import '../../features/claim_submission/presentation/pages/sync_screen.dart';
import '../../features/claim_submission/presentation/pages/profile_screen.dart';
import '../../features/documents/presentation/pages/camera_screen.dart';
import '../../features/documents/presentation/pages/upload_evidence_screen.dart';
import '../../features/investigation/presentation/pages/add_note_screen.dart';
import '../../features/investigation/presentation/pages/fraud_flag_screen.dart';
import '../navigation/main_navigation.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/otp':
        return MaterialPageRoute(builder: (_) => const OTPVerificationPage());

      // Main Navigation
      case '/dashboard':
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());

      // Claims Routes
      case '/claims':
        return MaterialPageRoute(builder: (_) => const ClaimsListPage());
      case '/claim-detail':
        final claimId = settings.arguments as String? ?? 'CLM-000001';
        return MaterialPageRoute(
          builder: (_) => ClaimDetailPage(claimId: claimId),
        );

      // Tasks Routes
      case '/tasks':
        return MaterialPageRoute(builder: (_) => const TasksPage());
      case '/task/create':
        final claimId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CreateTaskPage(claimId: claimId),
        );

      // Documents Routes
      case '/camera':
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case '/evidence/upload':
        final claimId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => UploadEvidencePage(claimId: claimId),
        );

      // Investigation Routes
      case '/note/add':
        final claimId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AddNotePage(claimId: claimId),
        );
      case '/fraud-flag':
        final claimId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => FraudFlagPage(claimId: claimId),
        );

      // Approval Routes
      case '/approval':
        final claimId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ApprovalPage(claimId: claimId),
        );

      // Complaint Routes
      case '/complaint':
        return MaterialPageRoute(builder: (_) => const ComplaintPage());

      // Sync Routes
      case '/sync':
        return MaterialPageRoute(builder: (_) => const SyncPage());

      // Profile Routes
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // Notifications (placeholder)
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: const Center(child: Text('Notifications')),
          ),
        );

      // Fallback
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Navigation Error'),
              backgroundColor: Colors.red.shade100,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route Not Found',
                    style: Theme.of(_).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No route defined for: ${settings.name}',
                    style: Theme.of(_).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(_).pushReplacementNamed('/home'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> routes = {
    '/login': (BuildContext context) => const LoginPage(),
    '/otp': (BuildContext context) => const OTPVerificationPage(),
    '/dashboard': (BuildContext context) => const MainNavigationPage(),
    '/home': (BuildContext context) => const MainNavigationPage(),
  };
}
