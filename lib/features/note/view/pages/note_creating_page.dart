import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';

class NoteCreatingPage extends ConsumerStatefulWidget {
  const NoteCreatingPage({super.key});

  @override
  ConsumerState<NoteCreatingPage> createState() => _NoteCreatingPageState();
}

class _NoteCreatingPageState extends ConsumerState<NoteCreatingPage> {
  bool _isPinned = false;
  final _quillController = QuillController(
    document: Document(),
    selection: TextSelection.collapsed(offset: 0),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Note'),

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
              Expanded(child: QuillEditor.basic(controller: _quillController)),
            ],
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) => FloatingActionButton(
            child: Icon(Icons.done),
            onPressed: () {
              final document = _quillController.document.toDelta();
              final json = jsonEncode(document);
              ref
                  .read(noteControllerProvider.notifier)
                  .createNote(content: json, isPinned: _isPinned);

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
