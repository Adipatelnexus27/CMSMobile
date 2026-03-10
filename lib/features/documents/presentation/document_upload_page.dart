import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "../data/document_api_client.dart";

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  static const List<String> _categories = [
    "General",
    "Evidence",
    "AccidentPhoto",
    "PoliceReport",
    "MedicalReport",
    "Invoice",
    "Settlement",
  ];

  final _accessTokenController = TextEditingController();
  final _claimIdController = TextEditingController();
  final _documentGroupIdController = TextEditingController();

  final DocumentApiClient _documentApiClient = DocumentApiClient();

  bool _initializedFromArgs = false;
  bool _loading = false;
  bool _uploading = false;
  bool _latestOnly = true;
  String _category = "General";
  PlatformFile? _selectedFile;
  String? _errorMessage;
  String? _successMessage;
  List<Map<String, dynamic>> _documents = <Map<String, dynamic>>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initializedFromArgs) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final accessToken = args["accessToken"]?.toString() ?? "";
      final claimId = args["claimId"]?.toString() ?? "";

      if (accessToken.isNotEmpty) {
        _accessTokenController.text = accessToken;
      }

      if (claimId.isNotEmpty) {
        _claimIdController.text = claimId;
      }
    }

    _initializedFromArgs = true;
  }

  @override
  void dispose() {
    _accessTokenController.dispose();
    _claimIdController.dispose();
    _documentGroupIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _loadDocuments() async {
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
      final documents = await _documentApiClient.getClaimDocuments(
        claimId: claimId,
        latestOnly: _latestOnly,
        accessToken: accessToken,
      );

      setState(() {
        _documents = documents;
        _successMessage = "Loaded ${documents.length} document(s).";
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

    setState(() {
      _uploading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _documentApiClient.uploadDocument(
        claimId: claimId,
        file: _selectedFile!,
        documentCategory: _category,
        documentGroupId: _documentGroupIdController.text.trim(),
        accessToken: accessToken,
      );

      setState(() {
        _selectedFile = null;
        _documentGroupIdController.clear();
        _successMessage = "Document uploaded successfully.";
      });

      await _loadDocuments();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _openVersions(String claimDocumentId, String fileName) async {
    final accessToken = _accessTokenController.text.trim();
    if (accessToken.isEmpty) {
      setState(() {
        _errorMessage = "Access token is required.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final versions = await _documentApiClient.getDocumentVersions(
        claimDocumentId: claimDocumentId,
        accessToken: accessToken,
      );

      if (!mounted) {
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Versions: $fileName",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (versions.isEmpty) const Text("No versions found."),
                  ...versions.map((version) {
                    final versionNumber = version["versionNumber"]?.toString() ?? "1";
                    final uploadedAt = version["uploadedAtUtc"]?.toString() ?? "";
                    final uploadedBy = version["uploadedByUserId"]?.toString() ?? "System";
                    final versionDocumentId = version["claimDocumentId"]?.toString() ?? "";

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Version $versionNumber"),
                      subtitle: Text("Uploaded by: $uploadedBy"),
                      trailing: Text(uploadedAt),
                      onTap: versionDocumentId.isEmpty
                          ? null
                          : () async {
                              Navigator.of(context).pop();
                              await _previewDocument(versionDocumentId);
                            },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
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

  Future<void> _previewDocument(String claimDocumentId) async {
    final accessToken = _accessTokenController.text.trim();
    if (accessToken.isEmpty) {
      setState(() {
        _errorMessage = "Access token is required.";
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
      final preview = await _documentApiClient.previewDocument(
        claimDocumentId: claimDocumentId,
        accessToken: accessToken,
      );

      if (!mounted) {
        return;
      }

      if (preview.contentType.toLowerCase().startsWith("image/")) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return Dialog(
              child: InteractiveViewer(
                child: Image.memory(preview.bytes, fit: BoxFit.contain),
              ),
            );
          },
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Preview Loaded"),
              content: Text(
                "File: ${preview.fileName}\n"
                "Content-Type: ${preview.contentType}\n"
                "Bytes: ${preview.bytes.length}",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                )
              ],
            );
          },
        );
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Management"),
        actions: [
          IconButton(
            tooltip: "Assigned Claims",
            onPressed: () => Navigator.of(context).pushReplacementNamed("/assigned-claims"),
            icon: const Icon(Icons.assignment_ind),
          ),
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
              decoration: const InputDecoration(labelText: "Access Token"),
              minLines: 1,
              maxLines: 3,
            ),
            TextField(
              controller: _claimIdController,
              decoration: const InputDecoration(labelText: "Claim ID"),
            ),
            Row(
              children: [
                const Text("Latest Only"),
                Switch(
                  value: _latestOnly,
                  onChanged: (value) {
                    setState(() {
                      _latestOnly = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loadDocuments,
                child: Text(_loading ? "Loading..." : "Load Documents"),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((category) => DropdownMenuItem<String>(value: category, child: Text(category)))
                  .toList(growable: false),
              onChanged: _uploading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
              decoration: const InputDecoration(labelText: "Document Category"),
            ),
            TextField(
              controller: _documentGroupIdController,
              decoration: const InputDecoration(labelText: "Document Group ID (optional)"),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select Document"),
            ),
            if (_selectedFile != null) Text("Selected: ${_selectedFile!.name}"),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploading || _selectedFile == null ? null : _uploadDocument,
                child: Text(_uploading ? "Uploading..." : "Upload Document"),
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
            const Text("Documents", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._documents.map((document) {
              final documentId = document["claimDocumentId"]?.toString() ?? "";
              final fileName = document["originalFileName"]?.toString() ?? "N/A";
              final category = document["documentCategory"]?.toString() ?? "General";
              final versionNumber = document["versionNumber"]?.toString() ?? "1";
              final isLatest = document["isLatest"]?.toString() ?? "true";
              final groupId = document["documentGroupId"]?.toString() ?? "";
              final uploadedAt = document["uploadedAtUtc"]?.toString() ?? "";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text("Category: $category"),
                      Text("Version: $versionNumber | Latest: $isLatest"),
                      Text("Group: $groupId"),
                      Text("Uploaded: $uploadedAt"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: documentId.isEmpty || _loading ? null : () => _previewDocument(documentId),
                              child: const Text("Preview"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: documentId.isEmpty || _loading ? null : () => _openVersions(documentId, fileName),
                              child: const Text("Versions"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _documentGroupIdController.text = groupId;
                              _category = category;
                            });
                          },
                          child: const Text("Upload New Version"),
                        ),
                      ),
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
