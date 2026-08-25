import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/features/note/demo/demo_note.dart';
import 'package:my_notes/features/note/provider/note_provider.dart';
import 'package:my_notes/features/note/view/pages/note_editing_page.dart';
import 'package:my_notes/features/note/view/widgets/note_tile.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_notes/features/note/view/pages/note_creating_page.dart';

class NotePage extends ConsumerStatefulWidget {
  const NotePage({super.key});

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  @override
  void initState() {
    ref.read(noteControllerProvider.notifier).startNoteSyncingService();

    super.initState();
  }

  Document _parseDocument(String? content) {
    if (content == null || content.isEmpty) return Document();
    try {
      final json = jsonDecode(content);
      return Document.fromJson(json);
    } catch (_) {
      return Document()..insert(0, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteListProvider);
    return Scaffold(
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Tap + to create one!',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemCount: notes.length,
              itemBuilder: (ctx, index) => NoteTile(
                isPinned: notes[index].isPinned,
                content: _parseDocument(notes[index].content),
                dateTime: DateTime.now(),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => NoteEditingPage(
                        id: notes[index].id,
                        content: _parseDocument(notes[index].content),
                        isPinned: notes[index].isPinned,
                      ),
                    ),
                  );
                  ref.invalidate(noteListProvider, asReload: true);
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => NoteCreatingPage()));
          ref.invalidate(noteListProvider, asReload: true);
        },
      ),
    );
  }
}
