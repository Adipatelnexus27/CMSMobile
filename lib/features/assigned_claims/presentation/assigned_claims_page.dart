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
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Role",
                    border: OutlineInputBorder(),
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
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loadClaims,
                    child: Text(isLoading ? "Loading..." : "Load Assigned Claims"),
                  ),
                ),
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 12),
                if (state.claims.isEmpty && state.status == AssignedClaimsStatus.success)
                  const Text("No assigned claims found."),
                ...state.claims.map(
                  (claim) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${claim.claimNumber} (${claim.claimStatus})",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text("Policy: ${claim.policyNumber}"),
                          Text("Type: ${claim.claimType}"),
                          Text("Priority: ${claim.priority}"),
                          Text("Workflow: ${claim.workflowStep}"),
                          Text("Reporter: ${claim.reporterName}"),
                          Text("Incident: ${claim.incidentDateUtc.toLocal()}".split(".").first),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      "/investigation",
                                      arguments: {"claimId": claim.claimId},
                                    );
                                  },
                                  child: const Text("Investigation"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      "/document-upload",
                                      arguments: {"claimId": claim.claimId},
                                    );
                                  },
                                  child: const Text("Documents"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
