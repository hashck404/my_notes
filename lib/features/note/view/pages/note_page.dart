import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_notes/app_theme/theme_provider.dart';
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
  bool _isSelecting = false;
  final Set<String> _selectedNotes = {};

  void _onToggleSelection(String id) {
    setState(() {
      if (_selectedNotes.isNotEmpty && _selectedNotes.contains(id)) {
        _selectedNotes.remove(id);
      } else {
        _selectedNotes.add(id);
      }

      if (_selectedNotes.isEmpty) {
        _isSelecting = false;
      } else {
        _isSelecting = true;
      }
    });
  }

  void _deleteSelectedNotes(Set<String> selectedNotes) {
    final controller = ref.read(noteControllerProvider.notifier);
    for (String id in _selectedNotes) {
      controller.deleteNote(id);
    }
    setState(() {
      _isSelecting = false;
      _selectedNotes.clear();
    });
  }

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
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'my notes',
          style: TextStyle(fontFamily: 'junicode', fontStyle: FontStyle.italic),
        ),
        actions: [
          if (_isSelecting)
            IconButton(
              onPressed: () {
                _deleteSelectedNotes(_selectedNotes);
              },
              icon: Icon(Icons.delete),
            ),

          IconButton(
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            icon: Icon(switch (themeMode) {
              ThemeMode.dark => Icons.mode_night,
              ThemeMode.light => Icons.wb_sunny,
              ThemeMode.system =>
                Icons.brightness_auto, // or Icons.phone_android
            }),
          ),
        ],
      ),
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
                key: ValueKey(notes[index].id),
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
                isSelected: _selectedNotes.contains(notes[index].id),
                isSelecting: _isSelecting,
                onSelectionToggle: () => _onToggleSelection(notes[index].id),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
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
