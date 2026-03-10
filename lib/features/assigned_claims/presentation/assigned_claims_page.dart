import "dart:convert";

import "package:flutter/material.dart";

import "../data/assigned_claim_api_client.dart";

class AssignedClaimsPage extends StatefulWidget {
  const AssignedClaimsPage({super.key});

  @override
  State<AssignedClaimsPage> createState() => _AssignedClaimsPageState();
}

class _AssignedClaimsPageState extends State<AssignedClaimsPage> {
  final _accessTokenController = TextEditingController();
  final _assigneeUserIdController = TextEditingController();

  final AssignedClaimApiClient _assignedClaimApiClient = AssignedClaimApiClient();

  String _role = "Investigator";
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;
  List<Map<String, dynamic>> _claims = <Map<String, dynamic>>[];

  @override
  void dispose() {
    _accessTokenController.dispose();
    _assigneeUserIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedClaims() async {
    final accessToken = _accessTokenController.text.trim();
    if (accessToken.isEmpty) {
      setState(() {
        _errorMessage = "Access token is required.";
        _successMessage = null;
      });
      return;
    }

    var assigneeUserId = _assigneeUserIdController.text.trim();
    assigneeUserId = assigneeUserId.isNotEmpty ? assigneeUserId : (_extractUserIdFromToken(accessToken) ?? "");

    if (assigneeUserId.isEmpty) {
      setState(() {
        _errorMessage = "Assignee User ID is required. Provide it manually or use a token with name identifier claim.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
      _assigneeUserIdController.text = assigneeUserId;
    });

    try {
      final claims = await _assignedClaimApiClient.getAssignedClaims(
        assigneeUserId: assigneeUserId,
        role: _role,
        accessToken: accessToken,
      );

      setState(() {
        _claims = claims;
        _successMessage = "Loaded ${claims.length} assigned claim(s).";
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateClaimStatus(Map<String, dynamic> claim) async {
    final claimId = claim["claimId"]?.toString() ?? "";
    final currentStatus = claim["claimStatus"]?.toString() ?? "";
    if (claimId.isEmpty) {
      setState(() {
        _errorMessage = "Claim ID is missing.";
      });
      return;
    }

    final statusController = TextEditingController(text: currentStatus);
    final status = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Claim Status"),
          content: TextField(
            controller: statusController,
            decoration: const InputDecoration(labelText: "Claim Status"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(statusController.text.trim()),
              child: const Text("Save"),
            )
          ],
        );
      },
    );

    if (status == null || status.isEmpty) {
      return;
    }

    await _runClaimMutation(
      action: () => _assignedClaimApiClient.updateClaimStatus(
        claimId: claimId,
        claimStatus: status,
        accessToken: _accessTokenController.text.trim(),
      ),
      successMessage: "Claim status updated.",
    );
  }

  Future<void> _updateWorkflowStep(Map<String, dynamic> claim) async {
    final claimId = claim["claimId"]?.toString() ?? "";
    final currentStep = claim["workflowStep"]?.toString() ?? "Registration";
    if (claimId.isEmpty) {
      setState(() {
        _errorMessage = "Claim ID is missing.";
      });
      return;
    }

    final stepController = TextEditingController(text: currentStep);
    final step = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Workflow Step"),
          content: TextField(
            controller: stepController,
            decoration: const InputDecoration(labelText: "Workflow Step"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(stepController.text.trim()),
              child: const Text("Save"),
            )
          ],
        );
      },
    );

    if (step == null || step.isEmpty) {
      return;
    }

    await _runClaimMutation(
      action: () => _assignedClaimApiClient.updateWorkflowStep(
        claimId: claimId,
        workflowStep: step,
        accessToken: _accessTokenController.text.trim(),
      ),
      successMessage: "Workflow step updated.",
    );
  }

  Future<void> _runClaimMutation({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await action();
      await _loadAssignedClaims();
      setState(() {
        _successMessage = successMessage;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String? _extractUserIdFromToken(String token) {
    final parts = token.split(".");
    if (parts.length < 2) {
      return null;
    }

    try {
      final payloadBytes = base64Url.decode(base64Url.normalize(parts[1]));
      final payloadMap = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;

      const candidateKeys = [
        "nameid",
        "sub",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
      ];

      for (final key in candidateKeys) {
        final value = payloadMap[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Claims"),
        actions: [
          IconButton(
            tooltip: "Claim Submission",
            onPressed: () => Navigator.of(context).pushReplacementNamed("/claim-submission"),
            icon: const Icon(Icons.assignment_add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _accessTokenController,
              decoration: const InputDecoration(
                labelText: "Access Token",
                helperText: "Required for API authorization",
              ),
              minLines: 1,
              maxLines: 3,
            ),
            TextField(
              controller: _assigneeUserIdController,
              decoration: const InputDecoration(
                labelText: "Assignee User ID",
                helperText: "Optional if token contains NameIdentifier claim",
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: "Investigator", child: Text("Investigator")),
                DropdownMenuItem(value: "Adjuster", child: Text("Adjuster")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _role = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loadAssignedClaims,
                child: Text(_loading ? "Loading..." : "Load Assigned Claims"),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_successMessage!, style: const TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 16),
            ..._claims.map((claim) {
              final claimId = claim["claimId"]?.toString() ?? "";
              final claimNumber = claim["claimNumber"]?.toString() ?? "N/A";
              final policyNumber = claim["policyNumber"]?.toString() ?? "N/A";
              final claimType = claim["claimType"]?.toString() ?? "N/A";
              final claimStatus = claim["claimStatus"]?.toString() ?? "N/A";
              final priority = claim["priority"]?.toString() ?? "N/A";
              final workflowStep = claim["workflowStep"]?.toString() ?? "N/A";
              final reporterName = claim["reporterName"]?.toString() ?? "N/A";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Claim Number: $claimNumber", style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text("Claim ID: $claimId"),
                      Text("Policy: $policyNumber"),
                      Text("Type: $claimType"),
                      Text("Status: $claimStatus"),
                      Text("Priority: $priority"),
                      Text("Workflow Step: $workflowStep"),
                      Text("Reporter: $reporterName"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading ? null : () => _updateClaimStatus(claim),
                              child: const Text("Update Status"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading ? null : () => _updateWorkflowStep(claim),
                              child: const Text("Update Workflow"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
