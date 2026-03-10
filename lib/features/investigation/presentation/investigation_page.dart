import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "../data/investigation_api_client.dart";

class InvestigationPage extends StatefulWidget {
  const InvestigationPage({super.key});

  @override
  State<InvestigationPage> createState() => _InvestigationPageState();
}

class _InvestigationPageState extends State<InvestigationPage> {
  static const List<String> _categories = [
    "Evidence",
    "AccidentPhoto",
    "PoliceReport",
    "MedicalReport",
  ];

  final _accessTokenController = TextEditingController();
  final _claimIdController = TextEditingController();
  final _noteController = TextEditingController();
  final _noteProgressController = TextEditingController();

  final InvestigationApiClient _investigationApiClient = InvestigationApiClient();

  bool _initializedFromArgs = false;
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  int _progressPercent = 0;
  String _documentCategory = "Evidence";
  PlatformFile? _selectedFile;

  Map<String, dynamic>? _investigation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initializedFromArgs) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final claimId = args["claimId"]?.toString() ?? "";
      final accessToken = args["accessToken"]?.toString() ?? "";

      if (claimId.isNotEmpty) {
        _claimIdController.text = claimId;
      }

      if (accessToken.isNotEmpty) {
        _accessTokenController.text = accessToken;
      }
    }

    _initializedFromArgs = true;
  }

  @override
  void dispose() {
    _accessTokenController.dispose();
    _claimIdController.dispose();
    _noteController.dispose();
    _noteProgressController.dispose();
    super.dispose();
  }

  Future<void> _loadInvestigation() async {
    final accessToken = _accessTokenController.text.trim();
    final claimId = _claimIdController.text.trim();

    if (accessToken.isEmpty || claimId.isEmpty) {
      setState(() {
        _errorMessage = "Access token and Claim ID are required.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _investigationApiClient.getInvestigation(
        claimId: claimId,
        accessToken: accessToken,
      );

      setState(() {
        _investigation = response;
        final responseProgress = response["investigationProgress"];
        if (responseProgress is int) {
          _progressPercent = responseProgress;
        } else {
          _progressPercent = int.tryParse(responseProgress?.toString() ?? "0") ?? 0;
        }
        _successMessage = "Investigation loaded.";
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

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadDocument() async {
    final accessToken = _accessTokenController.text.trim();
    final claimId = _claimIdController.text.trim();

    if (accessToken.isEmpty || claimId.isEmpty || _selectedFile == null) {
      setState(() {
        _errorMessage = "Access token, Claim ID, and selected file are required.";
        _successMessage = null;
      });
      return;
    }

    await _runMutation(
      mutation: () => _investigationApiClient.uploadInvestigationDocument(
        claimId: claimId,
        file: _selectedFile!,
        documentCategory: _documentCategory,
        accessToken: accessToken,
      ),
      successMessage: "$_documentCategory uploaded successfully.",
      clearSelection: true,
    );
  }

  Future<void> _addNote() async {
    final accessToken = _accessTokenController.text.trim();
    final claimId = _claimIdController.text.trim();
    final note = _noteController.text.trim();

    if (accessToken.isEmpty || claimId.isEmpty || note.isEmpty) {
      setState(() {
        _errorMessage = "Access token, Claim ID, and note text are required.";
        _successMessage = null;
      });
      return;
    }

    int? progressSnapshot;
    if (_noteProgressController.text.trim().isNotEmpty) {
      progressSnapshot = int.tryParse(_noteProgressController.text.trim());
      if (progressSnapshot == null || progressSnapshot < 0 || progressSnapshot > 100) {
        setState(() {
          _errorMessage = "Note progress snapshot must be between 0 and 100.";
          _successMessage = null;
        });
        return;
      }
    }

    await _runMutation(
      mutation: () => _investigationApiClient.addInvestigatorNote(
        claimId: claimId,
        noteText: note,
        progressPercentSnapshot: progressSnapshot,
        accessToken: accessToken,
      ),
      successMessage: "Investigator note added.",
      clearNote: true,
    );
  }

  Future<void> _updateProgress() async {
    final accessToken = _accessTokenController.text.trim();
    final claimId = _claimIdController.text.trim();

    if (accessToken.isEmpty || claimId.isEmpty) {
      setState(() {
        _errorMessage = "Access token and Claim ID are required.";
        _successMessage = null;
      });
      return;
    }

    if (_progressPercent < 0 || _progressPercent > 100) {
      setState(() {
        _errorMessage = "Progress must be between 0 and 100.";
        _successMessage = null;
      });
      return;
    }

    await _runMutation(
      mutation: () => _investigationApiClient.updateInvestigationProgress(
        claimId: claimId,
        progressPercent: _progressPercent,
        accessToken: accessToken,
      ),
      successMessage: "Investigation progress updated.",
    );
  }

  Future<void> _runMutation({
    required Future<void> Function() mutation,
    required String successMessage,
    bool clearSelection = false,
    bool clearNote = false,
  }) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await mutation();
      await _loadInvestigation();

      setState(() {
        _successMessage = successMessage;
        if (clearSelection) {
          _selectedFile = null;
        }

        if (clearNote) {
          _noteController.clear();
          _noteProgressController.clear();
        }
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

  @override
  Widget build(BuildContext context) {
    final documents = (_investigation?["documents"] as List?)?.whereType<Map>().toList() ?? const [];
    final notes = (_investigation?["notes"] as List?)?.whereType<Map>().toList() ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Claim Investigation"),
        actions: [
          IconButton(
            tooltip: "Assigned Claims",
            onPressed: () => Navigator.of(context).pushReplacementNamed("/assigned-claims"),
            icon: const Icon(Icons.assignment_ind),
          ),
          IconButton(
            tooltip: "Documents",
            onPressed: () => Navigator.of(context).pushNamed(
              "/documents",
              arguments: {
                "claimId": _claimIdController.text.trim(),
                "accessToken": _accessTokenController.text.trim(),
              },
            ),
            icon: const Icon(Icons.folder),
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
              decoration: const InputDecoration(labelText: "Access Token"),
              minLines: 1,
              maxLines: 3,
            ),
            TextField(
              controller: _claimIdController,
              decoration: const InputDecoration(labelText: "Claim ID"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loadInvestigation,
                child: Text(_loading ? "Loading..." : "Load Investigation"),
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
            if (_investigation != null) ...[
              Text(
                "Claim Number: ${_investigation?["claimNumber"] ?? "N/A"}",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text("Claim Status: ${_investigation?["claimStatus"] ?? "N/A"}"),
              Text("Investigation Progress: $_progressPercent%"),
              const SizedBox(height: 8),
              Slider(
                value: _progressPercent.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: "$_progressPercent%",
                onChanged: _loading
                    ? null
                    : (value) {
                        setState(() {
                          _progressPercent = value.round();
                        });
                      },
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loading ? null : _updateProgress,
                  child: const Text("Update Investigation Progress"),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Investigator Note"),
              ),
              TextField(
                controller: _noteProgressController,
                decoration: const InputDecoration(labelText: "Progress Snapshot (optional)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loading ? null : _addNote,
                  child: const Text("Add Investigator Note"),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _documentCategory,
                items: _categories
                    .map((category) => DropdownMenuItem<String>(value: category, child: Text(category)))
                    .toList(growable: false),
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _documentCategory = value;
                          });
                        }
                      },
                decoration: const InputDecoration(labelText: "Document Category"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading ? null : _pickDocument,
                icon: const Icon(Icons.upload_file),
                label: const Text("Select Document"),
              ),
              if (_selectedFile != null) Text("Selected: ${_selectedFile!.name}"),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading || _selectedFile == null ? null : _uploadDocument,
                  child: const Text("Upload Investigation Document"),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Documents", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...documents.map((item) {
                final map = item.map((key, value) => MapEntry(key.toString(), value));
                return Card(
                  child: ListTile(
                    title: Text(map["originalFileName"]?.toString() ?? "N/A"),
                    subtitle: Text("${map["documentCategory"] ?? "N/A"} | ${map["contentType"] ?? "N/A"}"),
                    trailing: Text(map["uploadedAtUtc"]?.toString() ?? ""),
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text("Investigator Notes", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...notes.map((item) {
                final map = item.map((key, value) => MapEntry(key.toString(), value));
                return Card(
                  child: ListTile(
                    title: Text(map["noteText"]?.toString() ?? ""),
                    subtitle: Text("Progress Snapshot: ${map["progressPercentSnapshot"] ?? "-"}"),
                    trailing: Text(map["createdAtUtc"]?.toString() ?? ""),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
