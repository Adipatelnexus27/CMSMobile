import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../auth/presentation/bloc/auth_bloc.dart";
import "../../../auth/presentation/bloc/auth_event.dart";
import "../../../auth/presentation/bloc/auth_state.dart";

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final session = state.session;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    session?.email ?? "User",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Welcome back!",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session?.fullName ?? session?.email ?? "User",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Roles: ${(session?.roles ?? const []).join(", ")}",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Actions Section Title
                Text(
                  "Quick Actions",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Action Cards
                _DashboardActionCard(
                  title: "Submit Claim",
                  subtitle: "Register a new claim and upload documents.",
                  icon: Icons.assignment_add,
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).pushNamed("/claim-submission"),
                ),
                _DashboardActionCard(
                  title: "Assigned Claims",
                  subtitle: "View and manage assigned claims.",
                  icon: Icons.assignment_ind,
                  color: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed("/assigned-claims"),
                ),
                _DashboardActionCard(
                  title: "Investigation Upload",
                  subtitle: "Upload evidence, photos and reports.",
                  icon: Icons.security,
                  color: Colors.orange,
                  onTap: () => Navigator.of(context).pushNamed("/investigation"),
                ),
                _DashboardActionCard(
                  title: "Document Management",
                  subtitle: "Upload and review documents.",
                  icon: Icons.upload_file,
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).pushNamed("/document-upload"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}