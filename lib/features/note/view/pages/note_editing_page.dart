import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/authentication/provider/auth_provider.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';
import 'dart:convert';

class NoteEditingPage extends ConsumerStatefulWidget {
  const NoteEditingPage({
    super.key,
    this.content,
    required this.id,
    required this.isPinned,
  });
  final Document? content;
  final String id;
  final bool isPinned;

  @override
  ConsumerState<NoteEditingPage> createState() => _NoteEditingPageState();
}

class _NoteEditingPageState extends ConsumerState<NoteEditingPage> {
  late bool _isPinned;
  late final QuillController _quillController;
  bool _isSaved = false;
  bool _isDirty = false;
  @override
  void initState() {
    super.initState();
    _quillController = QuillController(
      document: widget.content == null ? Document() : widget.content!,
      selection: TextSelection.collapsed(offset: 0),
    );
    _isPinned = widget.isPinned;

    _quillController.addListener(_onDocumentChange);
  }

  bool get _hasUnsavedChanges => _isDirty && !_isSaved;

  void _onDocumentChange() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  Future<void> _handlePopAttempt(bool didPop) async {
    if (didPop) return;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveNote({bool pendingDelete = false}) async {
    final doc = _quillController.document.toDelta();
    final json = doc.toJson();

    await ref
        .read(noteControllerProvider.notifier)
        .editNote(
          id: widget.id,
          content: jsonEncode(json),
          isPinned: _isPinned,
          pendingDelete: pendingDelete,
        );
    _isSaved = true;
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) => _handlePopAttempt(didPop),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Note'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPinned = !_isPinned;
                  });
                },
                icon: Icon(
                  _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete note'),
                      content: Text(
                        'Do you want to permanently delete this note?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _saveNote(pendingDelete: true);
                          },
                          child: Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _quillController,
                  config: QuillSimpleToolbarConfig(),
                ),
                Divider(),
                Expanded(
                  child: QuillEditor.basic(controller: _quillController),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.large(
            child: Icon(Icons.done),
            onPressed: () => _saveNote(pendingDelete: false),
          ),
        ),
      ),
    );
  }
}
