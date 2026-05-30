import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/notes_viewmodel.dart';
import '../../tags/viewmodel/tags_viewmodel.dart';
import '../../tags/ui/tag_filter_chip.dart';
import '../../../shared/widgets/note_card.dart';
import '../data/note_model.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  // Beautiful modern colors for tags
  static const List<Map<String, String>> tagColors = [
    {'name': 'Indigo', 'hex': '#FF3F51B5'},
    {'name': 'Teal', 'hex': '#FF009688'},
    {'name': 'Green', 'hex': '#FF4CAF50'},
    {'name': 'Orange', 'hex': '#FFFF9800'},
    {'name': 'Red', 'hex': '#FFE53935'},
    {'name': 'Pink', 'hex': '#FFE91E63'},
    {'name': 'Purple', 'hex': '#FF9C27B0'},
    {'name': 'Blue', 'hex': '#FF2196F3'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(filteredNotesProvider);
    final tags = ref.watch(tagsViewModelProvider);
    final selectedTagId = ref.watch(selectedTagFilterProvider);
    final searchQuery = ref.watch(noteSearchQueryProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Private Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sell_outlined),
            tooltip: 'Manage Tags',
            onPressed: () => _showManageTagsBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Search title or content...',
              leading: const Icon(Icons.search),
              trailing: searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(noteSearchQueryProvider.notifier).state = '';
                        },
                      ),
                    ]
                  : null,
              onChanged: (value) {
                ref.read(noteSearchQueryProvider.notifier).state = value;
              },
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade900,
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Tag Filter Bar
          if (tags.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAllSelected = selectedTagId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: isAllSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedTagFilterProvider.notifier).state = null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }

                  final tag = tags[index - 1];
                  final isSelected = selectedTagId == tag.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TagFilterChip(
                      tag: tag,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedTagFilterProvider.notifier).state =
                            selected ? tag.id : null;
                      },
                    ),
                  );
                },
              ),
            ),

          // Notes List / Grid
          Expanded(
            child: notes.isEmpty
                ? _buildEmptyState(context, searchQuery, selectedTagId)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88, top: 8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(noteId: note.id),
                            ),
                          );
                        },
                        onLongPress: () => _confirmDeleteNote(context, ref, note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String query, String? tagId) {
    final theme = Theme.of(context);
    final isFiltering = query.isNotEmpty || tagId != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltering ? Icons.search_off_rounded : Icons.note_alt_outlined,
              size: 72,
              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltering ? 'No notes match your filters' : 'Your private safe is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltering
                  ? 'Try clearing search keywords or selecting another tag.'
                  : 'Tap the "+" button below to write your first secure note. It will be AES encrypted on your device.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Are you sure you want to permanently delete "${note.title.isNotEmpty ? note.title : 'Untitled Note'}"? This action cannot be undone.'),
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
              ref.read(notesViewModelProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
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

  void _showManageTagsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const _ManageTagsSheet(),
        );
      },
    );
  }
}

// Separate StatefulWidget for ManageTags BottomSheet to manage local text editing state
class _ManageTagsSheet extends ConsumerStatefulWidget {
  const _ManageTagsSheet();

  @override
  ConsumerState<_ManageTagsSheet> createState() => _ManageTagsSheetState();
}

class _ManageTagsSheetState extends ConsumerState<_ManageTagsSheet> {
  final _textController = TextEditingController();
  String _selectedHexColor = NotesListScreen.tagColors.first['hex']!;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsViewModelProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Manage Tags',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Add Tag Input Form
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'New tag name...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      final name = _textController.text.trim();
                      if (name.isNotEmpty) {
                        await ref.read(tagsViewModelProvider.notifier).addTag(name, _selectedHexColor);
                        _textController.clear();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Color selection palette
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: NotesListScreen.tagColors.length,
                  itemBuilder: (context, index) {
                    final colorMap = NotesListScreen.tagColors[index];
                    final hex = colorMap['hex']!;
                    final color = Color(int.parse(hex.replaceFirst('#', '0xff')));
                    final isColorSelected = _selectedHexColor == hex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedHexColor = hex;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isColorSelected
                              ? Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 2.5,
                                )
                              : null,
                          boxShadow: isColorSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32),
              
              // Tag List
              Expanded(
                child: tags.isEmpty
                    ? Center(
                        child: Text(
                          'No tags created yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          final color = Color(int.parse(tag.colorHex.replaceFirst('#', '0xff')));

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color,
                                  radius: 12,
                                ),
                                title: Text(
                                  tag.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: theme.colorScheme.error,
                                  onPressed: () {
                                    ref.read(tagsViewModelProvider.notifier).deleteTag(tag.id);
                                    // Reset note selected tag if it was deleted
                                    if (ref.read(selectedTagFilterProvider) == tag.id) {
                                      ref.read(selectedTagFilterProvider.notifier).state = null;
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
