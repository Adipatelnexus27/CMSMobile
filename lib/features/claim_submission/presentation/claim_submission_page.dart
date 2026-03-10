import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "../data/claim_api_client.dart";

class ClaimSubmissionPage extends StatefulWidget {
  const ClaimSubmissionPage({super.key});

  @override
  State<ClaimSubmissionPage> createState() => _ClaimSubmissionPageState();
}

class _ClaimSubmissionPageState extends State<ClaimSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _policyNumberController = TextEditingController(text: "POL-2026-0001");
  final _claimTypeController = TextEditingController(text: "Property Damage");
  final _reporterNameController = TextEditingController();
  final _incidentLocationController = TextEditingController();
  final _incidentDescriptionController = TextEditingController();
  final _relatedClaimsController = TextEditingController();
  final _accessTokenController = TextEditingController();

  final ClaimApiClient _claimApiClient = ClaimApiClient();

  DateTime _incidentDateTime = DateTime.now();
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;
  List<PlatformFile> _selectedDocuments = <PlatformFile>[];

  @override
  void dispose() {
    _policyNumberController.dispose();
    _claimTypeController.dispose();
    _reporterNameController.dispose();
    _incidentLocationController.dispose();
    _incidentDescriptionController.dispose();
    _relatedClaimsController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedDocuments = result.files;
      });
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final relatedClaimIds = _relatedClaimsController.text
          .split(",")
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final claim = await _claimApiClient.registerClaim(
        policyNumber: _policyNumberController.text.trim(),
        claimType: _claimTypeController.text.trim(),
        reporterName: _reporterNameController.text.trim(),
        incidentDateUtc: _incidentDateTime,
        incidentLocation: _incidentLocationController.text.trim(),
        incidentDescription: _incidentDescriptionController.text.trim(),
        relatedClaimIds: relatedClaimIds,
        accessToken: _accessTokenController.text.trim().isEmpty ? null : _accessTokenController.text.trim(),
      );

      final claimId = claim["claimId"]?.toString();
      if (claimId == null) {
        throw Exception("Claim response did not return claimId.");
      }

      for (final file in _selectedDocuments) {
        await _claimApiClient.uploadDocument(
          claimId: claimId,
          file: file,
          accessToken: _accessTokenController.text.trim().isEmpty ? null : _accessTokenController.text.trim(),
        );
      }

      setState(() {
        _successMessage = "Claim submitted successfully. Claim Number: ${claim["claimNumber"] ?? "N/A"}";
        _selectedDocuments = <PlatformFile>[];
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Claim Submission"),
        actions: [
          IconButton(
            tooltip: "Assigned Claims",
            onPressed: () => Navigator.of(context).pushReplacementNamed("/assigned-claims"),
            icon: const Icon(Icons.assignment_ind),
          ),
          IconButton(
            tooltip: "Documents",
            onPressed: () => Navigator.of(context).pushReplacementNamed(
              "/documents",
              arguments: {"accessToken": _accessTokenController.text.trim()},
            ),
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _policyNumberController,
                decoration: const InputDecoration(labelText: "Policy Number"),
                validator: (value) => value == null || value.trim().isEmpty ? "Policy number is required" : null,
              ),
              TextFormField(
                controller: _claimTypeController,
                decoration: const InputDecoration(labelText: "Claim Type"),
                validator: (value) => value == null || value.trim().isEmpty ? "Claim type is required" : null,
              ),
              TextFormField(
                controller: _reporterNameController,
                decoration: const InputDecoration(labelText: "Reporter Name"),
                validator: (value) => value == null || value.trim().isEmpty ? "Reporter name is required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Incident Date: ${_incidentDateTime.toLocal()}".split(".").first,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _incidentDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );

                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_incidentDateTime),
                        );

                        if (selectedTime != null) {
                          setState(() {
                            _incidentDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text("Select"),
                  )
                ],
              ),
              TextFormField(
                controller: _incidentLocationController,
                decoration: const InputDecoration(labelText: "Incident Location"),
                validator: (value) => value == null || value.trim().isEmpty ? "Location is required" : null,
              ),
              TextFormField(
                controller: _incidentDescriptionController,
                decoration: const InputDecoration(labelText: "Incident Description"),
                minLines: 3,
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty ? "Description is required" : null,
              ),
              TextFormField(
                controller: _relatedClaimsController,
                decoration: const InputDecoration(labelText: "Related Claim IDs (comma separated, optional)"),
              ),
              TextFormField(
                controller: _accessTokenController,
                decoration: const InputDecoration(labelText: "Access Token (required if API auth is enabled)"),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDocuments,
                icon: const Icon(Icons.upload_file),
                label: const Text("Select Documents"),
              ),
              const SizedBox(height: 8),
              ..._selectedDocuments.map((file) => Text("- ${file.name}")),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_successMessage != null)
                Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitClaim,
                  child: Text(_submitting ? "Submitting..." : "Submit Claim"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
