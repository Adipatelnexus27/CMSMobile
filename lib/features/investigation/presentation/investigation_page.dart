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
              TextField(
                controller: _claimIdController,
                decoration: const InputDecoration(
                  labelText: "Claim ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isBusy ? null : _loadInvestigation,
                  child: Text(isBusy ? "Loading..." : "Load Investigation"),
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
              if (state.detail != null) ...[
                const SizedBox(height: 16),
                Text(
                  "${state.detail!.claimNumber} (${state.detail!.claimStatus})",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("Progress: ${state.detail!.investigationProgress}%"),
                const SizedBox(height: 8),
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
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : _updateProgress,
                    child: const Text("Update Progress"),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Investigation Note",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteProgressController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Progress Snapshot (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : _submitNote,
                    child: const Text("Add Note"),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
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
                            _selectedCategory = value;
                          });
                        },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : _pickDocument,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Pick Document"),
                ),
                if (_selectedFile != null) Text("Selected: ${_selectedFile!.name}"),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isBusy || _selectedFile == null ? null : _uploadSelectedDocument,
                    child: const Text("Upload Document"),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : _capturePhotoAndUpload,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Capture Photo & Upload"),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Uploaded Documents", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...state.detail!.documents.map(
                  (document) => ListTile(
                    dense: true,
                    title: Text(document.originalFileName),
                    subtitle: Text("${document.documentCategory} | ${document.contentType}"),
                    trailing: Text(document.uploadedAtUtc.toLocal().toString().split(".").first),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Notes", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...state.detail!.notes.map(
                  (note) => ListTile(
                    dense: true,
                    title: Text(note.noteText),
                    subtitle: Text("Progress Snapshot: ${note.progressPercentSnapshot ?? "-"}"),
                    trailing: Text(note.createdAtUtc.toLocal().toString().split(".").first),
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
