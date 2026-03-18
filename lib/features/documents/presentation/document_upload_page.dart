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
      appBar: AppBar(title: const Text("Document Management")),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final isBusy = state.status == DocumentStatus.loading || state.status == DocumentStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Load Documents Section
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
                      "Load Claim Documents",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _claimIdController,
                      enabled: !isBusy,
                      decoration: InputDecoration(
                        labelText: "Claim ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.assignment),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Latest Versions Only"),
                      subtitle: const Text("Show only the newest version of each document"),
                      value: _latestOnly,
                      onChanged: isBusy
                          ? null
                          : (value) {
                              setState(() {
                                _latestOnly = value;
                              });
                            },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isBusy ? null : _loadDocuments,
                        icon: isBusy
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
                            : const Icon(Icons.autorenew),
                        label: Text(isBusy ? "Loading..." : "Load Documents"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Error Message
              if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) ...[
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

              // Success Message
              if (state.successMessage != null && state.successMessage!.trim().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upload New Document Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.orange.withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload New Document",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: "Document Category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _documentGroupIdController,
                      enabled: !isBusy,
                      decoration: InputDecoration(
                        labelText: "Document Group ID (optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.tag),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Pick File"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFile!.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: isBusy || _selectedFile == null ? null : _uploadDocument,
                        child: const Text("Upload Document"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Documents List
              if (state.documents.isEmpty && state.status == DocumentStatus.ready) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No documents found",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Load documents or upload a new one to get started",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (state.documents.isNotEmpty) ...[
                Text(
                  "Documents (${state.documents.length})",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...state.documents.map(
                  (document) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  document.originalFileName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  document.documentCategory,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "v${document.versionNumber}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (document.isLatest)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "Latest",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            document.uploadedAtUtc.toLocal().toString().split(".").first,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
