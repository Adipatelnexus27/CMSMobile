import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../auth/presentation/bloc/auth_bloc.dart";
import "../../auth/presentation/bloc/auth_state.dart";
import "bloc/document_bloc.dart";
import "bloc/document_event.dart";
import "bloc/document_state.dart";

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  static const categories = [
    "General",
    "Evidence",
    "AccidentPhoto",
    "PoliceReport",
    "MedicalReport",
    "Invoice",
    "Settlement",
  ];

  final _claimIdController = TextEditingController();
  final _documentGroupIdController = TextEditingController();

  bool _latestOnly = true;
  String _category = "General";
  PlatformFile? _selectedFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final claimId = args["claimId"]?.toString();
      if (claimId != null && claimId.isNotEmpty && _claimIdController.text != claimId) {
        _claimIdController.text = claimId;
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
      }
    }
  }

  @override
  void dispose() {
    _claimIdController.dispose();
    _documentGroupIdController.dispose();
    super.dispose();
  }

  String? get _accessToken => context.read<AuthBloc>().state.session?.accessToken;

  void _loadDocuments() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    if (token == null || token.isEmpty || claimId.isEmpty) {
      return;
    }

    context.read<DocumentBloc>().add(
          DocumentListRequested(
            claimId: claimId,
            latestOnly: _latestOnly,
            accessToken: token,
          ),
        );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _uploadDocument() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    final file = _selectedFile;

    if (token == null || token.isEmpty || claimId.isEmpty || file == null || file.path == null) {
      return;
    }

    context.read<DocumentBloc>().add(
          DocumentUploadRequested(
            claimId: claimId,
            latestOnly: _latestOnly,
            filePath: file.path!,
            fileName: file.name,
            documentCategory: _category,
            documentGroupId: _documentGroupIdController.text.trim().isEmpty ? null : _documentGroupIdController.text.trim(),
            accessToken: token,
          ),
        );

    setState(() {
      _selectedFile = null;
      _documentGroupIdController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.session == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to manage documents.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Document Upload")),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final isBusy = state.status == DocumentStatus.loading || state.status == DocumentStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _claimIdController,
                decoration: const InputDecoration(
                  labelText: "Claim ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text("Latest Versions Only"),
                value: _latestOnly,
                onChanged: isBusy
                    ? null
                    : (value) {
                        setState(() {
                          _latestOnly = value;
                        });
                      },
              ),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _loadDocuments,
                  child: Text(isBusy ? "Loading..." : "Load Documents"),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: "Document Category",
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(growable: false),
                onChanged: isBusy
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _category = value;
                        });
                      },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _documentGroupIdController,
                decoration: const InputDecoration(
                  labelText: "Document Group ID (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isBusy ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text("Pick File"),
              ),
              if (_selectedFile != null)
                Text("Selected: ${_selectedFile!.name}"),
              const SizedBox(height: 8),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isBusy || _selectedFile == null ? null : _uploadDocument,
                  child: const Text("Upload Document"),
                ),
              ),
              if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              if (state.successMessage != null && state.successMessage!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(state.successMessage!, style: const TextStyle(color: Colors.green)),
              ],
              const SizedBox(height: 16),
              if (state.documents.isEmpty && state.status == DocumentStatus.ready)
                const Text("No documents found for this claim."),
              ...state.documents.map(
                (document) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(document.originalFileName),
                    subtitle: Text(
                      "${document.documentCategory} | v${document.versionNumber} | Latest: ${document.isLatest}",
                    ),
                    trailing: Text(document.uploadedAtUtc.toLocal().toString().split(".").first),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
