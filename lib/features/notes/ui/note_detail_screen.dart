import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../viewmodel/notes_viewmodel.dart';
import '../../tags/viewmodel/tags_viewmodel.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends ConsumerWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  void _shareNote(String title, String content) {
    final shareText = title.isNotEmpty ? '$title\n\n$content' : content;
    Share.share(shareText);
  }

  void _confirmDeleteNote(BuildContext context, WidgetRef ref, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Are you sure you want to permanently delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              ref.read(notesViewModelProvider.notifier).deleteNote(noteId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted permanently')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesViewModelProvider);
    final noteIndex = notes.indexWhere((n) => n.id == noteId);

    if (noteIndex == -1) {
      // Pop the screen on next frame if note is deleted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final note = notes[noteIndex];
    final allTags = ref.watch(tagsViewModelProvider);
    final noteTags = allTags.where((tag) => note.tagIds.contains(tag.id)).toList();

    final theme = Theme.of(context);
    final dateString = DateFormat.yMMMMd().add_jm().format(note.updatedAt);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Note',
            onPressed: () => _shareNote(note.title, note.content),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Note',
            onPressed: () => _confirmDeleteNote(
              context,
              ref,
              note.title.isNotEmpty ? note.title : 'Untitled Note',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title.isNotEmpty ? note.title : 'Untitled Note',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: note.title.isNotEmpty 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: note.title.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            
            // Metadata: Date
            Text(
              'Last updated: $dateString',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tags list
            if (noteTags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: noteTags.map((tag) {
                  final color = Color(int.parse(tag.colorHex.replaceFirst('#', '0xff')));
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Color.alphaBlend(color.withValues(alpha: 0.9), theme.colorScheme.onSurface),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Divider(height: 32),
            ] else ...[
              const Divider(height: 24),
            ],
            
            // Content
            Text(
              note.content.isNotEmpty ? note.content : 'No content in this note.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                letterSpacing: 0.2,
                color: note.content.isNotEmpty
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: note.content.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(noteId: note.id),
            ),
          );
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edit Note'),
      ),
    );
  }
}
