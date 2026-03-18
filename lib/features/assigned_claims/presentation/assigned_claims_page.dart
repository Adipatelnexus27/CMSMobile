import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../auth/presentation/bloc/auth_bloc.dart";
import "../../auth/presentation/bloc/auth_state.dart";
import "bloc/assigned_claims_bloc.dart";
import "bloc/assigned_claims_event.dart";
import "bloc/assigned_claims_state.dart";

class AssignedClaimsPage extends StatefulWidget {
  const AssignedClaimsPage({super.key});

  @override
  State<AssignedClaimsPage> createState() => _AssignedClaimsPageState();
}

class _AssignedClaimsPageState extends State<AssignedClaimsPage> {
  String _selectedRole = "Investigator";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClaims();
    });
  }

  void _loadClaims() {
    final authState = context.read<AuthBloc>().state;
    final token = authState.session?.accessToken;
    if (token == null || token.trim().isEmpty) {
      return;
    }

    context.read<AssignedClaimsBloc>().add(
          AssignedClaimsRequested(accessToken: token, role: _selectedRole),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.session == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to access assigned claims.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Claims"),
        elevation: 0,
      ),
      body: BlocBuilder<AssignedClaimsBloc, AssignedClaimsState>(
        builder: (context, state) {
          final isLoading = state.status == AssignedClaimsStatus.loading;

          return RefreshIndicator(
            onRefresh: () async {
              _loadClaims();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Filters Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filter by Role",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          labelText: "Select Role",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Investigator", child: Text("Investigator")),
                          DropdownMenuItem(value: "Adjuster", child: Text("Adjuster")),
                        ],
                        onChanged: isLoading
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  _selectedRole = value;
                                });
                                _loadClaims();
                              },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _loadClaims,
                          icon: isLoading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(isLoading ? "Loading..." : "Load Claims"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error Message
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Empty State
                if (state.claims.isEmpty && state.status == AssignedClaimsStatus.success) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No claims found",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No assigned claims for the selected role",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Claims List
                  Text(
                    "Claims (${state.claims.length})",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.claims.map(
                    (claim) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        claim.claimNumber,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        claim.policyNumber,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(claim.claimStatus).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    claim.claimStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(claim.claimStatus),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Details Grid
                            Grid(
                              columns: [
                                (icon: Icons.category, label: "Type", value: claim.claimType),
                                (icon: Icons.flag, label: "Priority", value: claim.priority.toString()),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Grid(
                              columns: [
                                (icon: Icons.timeline, label: "Step", value: claim.workflowStep),
                                (icon: Icons.person, label: "Reporter", value: claim.reporterName),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  "Incident: ${claim.incidentDateUtc.toLocal().toString().split(" ")[0]}",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        "/investigation",
                                        arguments: {"claimId": claim.claimId},
                                      );
                                    },
                                    icon: const Icon(Icons.security, size: 18),
                                    label: const Text("Investigation"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        "/document-upload",
                                        arguments: {"claimId": claim.claimId},
                                      );
                                    },
                                    icon: const Icon(Icons.upload_file, size: 18),
                                    label: const Text("Documents"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Grid extends StatelessWidget {
  final List<({IconData icon, String label, String value})> columns;

  const Grid({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: columns.asMap().entries.map((entry) {
        final isLast = entry.key == columns.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: Row(
              children: [
                Icon(entry.value.icon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${entry.value.label}: ${entry.value.value}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
