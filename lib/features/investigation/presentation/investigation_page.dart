import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:image_picker/image_picker.dart";

import "../../auth/presentation/bloc/auth_bloc.dart";
import "../../auth/presentation/bloc/auth_state.dart";
import "bloc/investigation_bloc.dart";
import "bloc/investigation_event.dart";
import "bloc/investigation_state.dart";

class InvestigationPage extends StatefulWidget {
  const InvestigationPage({super.key});

  @override
  State<InvestigationPage> createState() => _InvestigationPageState();
}

class _InvestigationPageState extends State<InvestigationPage> {
  static const categories = ["Evidence", "AccidentPhoto", "PoliceReport", "MedicalReport"];

  final _claimIdController = TextEditingController();
  final _noteController = TextEditingController();
  final _noteProgressController = TextEditingController();
  final _imagePicker = ImagePicker();

  int _progressPercent = 0;
  String _selectedCategory = "Evidence";
  PlatformFile? _selectedFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final claimId = args["claimId"]?.toString();
      if (claimId != null && claimId.isNotEmpty && _claimIdController.text != claimId) {
        _claimIdController.text = claimId;
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadInvestigation());
      }
    }
  }

  @override
  void dispose() {
    _claimIdController.dispose();
    _noteController.dispose();
    _noteProgressController.dispose();
    super.dispose();
  }

  String? get _accessToken {
    return context.read<AuthBloc>().state.session?.accessToken;
  }

  void _loadInvestigation() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    if (token == null || token.isEmpty || claimId.isEmpty) {
      return;
    }

    context.read<InvestigationBloc>().add(
          InvestigationLoaded(claimId: claimId, accessToken: token),
        );
  }

  void _updateProgress() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    if (token == null || token.isEmpty || claimId.isEmpty) {
      return;
    }

    if (_progressPercent < 0 || _progressPercent > 100) {
      return;
    }

    context.read<InvestigationBloc>().add(
          InvestigationProgressUpdated(
            claimId: claimId,
            progressPercent: _progressPercent,
            accessToken: token,
          ),
        );
  }

  void _submitNote() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    final note = _noteController.text.trim();

    if (token == null || token.isEmpty || claimId.isEmpty || note.isEmpty) {
      return;
    }

    int? snapshot;
    final snapshotText = _noteProgressController.text.trim();
    if (snapshotText.isNotEmpty) {
      snapshot = int.tryParse(snapshotText);
      if (snapshot == null || snapshot < 0 || snapshot > 100) {
        return;
      }
    }

    context.read<InvestigationBloc>().add(
          InvestigationNoteSubmitted(
            claimId: claimId,
            noteText: note,
            progressPercentSnapshot: snapshot,
            accessToken: token,
          ),
        );

    _noteController.clear();
    _noteProgressController.clear();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _uploadSelectedDocument() {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();
    final selected = _selectedFile;

    if (token == null || token.isEmpty || claimId.isEmpty || selected == null || selected.path == null) {
      return;
    }

    context.read<InvestigationBloc>().add(
          InvestigationDocumentUploaded(
            claimId: claimId,
            filePath: selected.path!,
            fileName: selected.name,
            documentCategory: _selectedCategory,
            accessToken: token,
          ),
        );

    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _capturePhotoAndUpload() async {
    final token = _accessToken;
    final claimId = _claimIdController.text.trim();

    if (token == null || token.isEmpty || claimId.isEmpty) {
      return;
    }

    final image = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    context.read<InvestigationBloc>().add(
          InvestigationDocumentUploaded(
            claimId: claimId,
            filePath: image.path,
            fileName: image.name,
            documentCategory: "AccidentPhoto",
            accessToken: token,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.session == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to use investigation tools.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Investigation Upload")),
      body: BlocConsumer<InvestigationBloc, InvestigationState>(
        listener: (context, state) {
          if (state.detail != null) {
            _progressPercent = state.detail!.investigationProgress;
          }
        },
        builder: (context, state) {
          final isBusy = state.status == InvestigationStatus.loading || state.status == InvestigationStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Load Investigation Section
              _SectionCard(
                title: "Load Investigation",
                children: [
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
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : _loadInvestigation,
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
                      label: Text(isBusy ? "Loading..." : "Load Investigation"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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

              // Investigation Details
              if (state.detail != null) ...[
                // Claim Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.detail!.claimNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state.detail!.claimStatus,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Section
                _SectionCard(
                  title: "Investigation Progress",
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${_progressPercent}%",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(_progressPercent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progressPercent / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(_progressPercent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _progressPercent.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: "$_progressPercent%",
                      onChanged: isBusy
                          ? null
                          : (value) {
                              setState(() {
                                _progressPercent = value.round();
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: isBusy ? null : _updateProgress,
                        child: const Text("Update Progress"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes Section
                _SectionCard(
                  title: "Add Investigation Note",
                  children: [
                    TextField(
                      controller: _noteController,
                      enabled: !isBusy,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Investigation Note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteProgressController,
                      enabled: !isBusy,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Progress Snapshot (0-100, optional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.percent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isBusy ? null : _submitNote,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Note"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Document Upload Section
                _SectionCard(
                  title: "Upload Documents & Photos",
                  children: [
                    IgnorePointer(
                      ignoring: isBusy,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
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
                                _selectedCategory = value;
                              });
                            },
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _pickDocument,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Pick Document"),
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
                        onPressed: isBusy || _selectedFile == null ? null : _uploadSelectedDocument,
                        child: const Text("Upload Document"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isBusy ? null : _capturePhotoAndUpload,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text("Capture Photo & Upload"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Uploaded Documents
                if (state.detail!.documents.isNotEmpty) ...[
                  _SectionCard(
                    title: "Uploaded Documents (${state.detail!.documents.length})",
                    children: [
                      ...state.detail!.documents.map(
                        (document) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      document.originalFileName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${document.documentCategory} • ${document.contentType}",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes List
                if (state.detail!.notes.isNotEmpty) ...[
                  _SectionCard(
                    title: "Investigation Notes (${state.detail!.notes.length})",
                    children: [
                      ...state.detail!.notes.map(
                        (note) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.noteText,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Progress: ${note.progressPercentSnapshot ?? "-"}%",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    note.createdAtUtc.toLocal().toString().split(".").first,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 25) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 75) return Colors.amber;
    return Colors.green;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
