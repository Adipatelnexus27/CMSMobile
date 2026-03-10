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
            title: const Text("CMS Mobile Dashboard"),
            actions: [
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
                Text(
                  "Welcome ${session?.fullName ?? session?.email ?? "User"}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  "Roles: ${(session?.roles ?? const []).join(", ")}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _DashboardActionCard(
                  title: "Assigned Claims",
                  subtitle: "View and manage claims assigned to your role.",
                  icon: Icons.assignment_ind,
                  onTap: () => Navigator.of(context).pushNamed("/assigned-claims"),
                ),
                _DashboardActionCard(
                  title: "Investigation Upload",
                  subtitle: "Upload evidence, accident photos, and police/medical reports.",
                  icon: Icons.security,
                  onTap: () => Navigator.of(context).pushNamed("/investigation"),
                ),
                _DashboardActionCard(
                  title: "Document Upload",
                  subtitle: "Upload and review claim-level documents.",
                  icon: Icons.upload_file,
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
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
