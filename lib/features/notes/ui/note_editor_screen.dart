import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../viewmodel/notes_viewmodel.dart';
import '../../tags/viewmodel/tags_viewmodel.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String? _noteId;
  List<String> _selectedTagIds = [];
  bool _isSaving = false;
  Timer? _debounceTimer;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;
    
    // Schedule controller listeners after initial frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_noteId != null) {
        final notes = ref.read(notesViewModelProvider);
        final note = notes.firstWhere((n) => n.id == _noteId);
        
        _titleController.text = note.title;
        _contentController.text = note.content;
        setState(() {
          _selectedTagIds = List.from(note.tagIds);
        });
      }
      
      _titleController.addListener(_onTextChanged);
      _contentController.addListener(_onTextChanged);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _hasChanges = true;
    setState(() {
      _isSaving = true;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _saveNote();
    });
  }

  Future<void> _saveNote() async {
    if (!_hasChanges) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Don't save empty notes unless they already exist (in which case we can save them as empty or delete)
    if (title.isEmpty && content.isEmpty && _noteId == null) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (_noteId == null) {
      // Create new note
      final newNote = await ref.read(notesViewModelProvider.notifier).addNote(
        title: title,
        content: content,
        tagIds: _selectedTagIds,
      );
      _noteId = newNote.id;
    } else {
      // Update existing note
      final notes = ref.read(notesViewModelProvider);
      final noteIndex = notes.indexWhere((n) => n.id == _noteId);
      if (noteIndex != -1) {
        final existingNote = notes[noteIndex];
        final updatedNote = existingNote.copyWith(
          title: title,
          content: content,
          tagIds: _selectedTagIds,
        );
        await ref.read(notesViewModelProvider.notifier).updateNote(updatedNote);
      }
    }

    _hasChanges = false;
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
      _hasChanges = true;
      _isSaving = true;
    });

    _debounceTimer?.cancel();
    _saveNote();
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share an empty note')),
      );
      return;
    }

    final shareText = title.isNotEmpty ? '$title\n\n$content' : content;
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsViewModelProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Trigger one final save when user backs out
        if (_hasChanges) {
          _saveNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // Saving Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSaving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Text(
                          _noteId != null ? 'Saved' : 'Draft',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Note',
              onPressed: _shareNote,
            ),
            IconButton(
              icon: const Icon(Icons.sell_outlined),
              tooltip: 'Associate Tags',
              onPressed: () => _showTagsPickerBottomSheet(context, tags),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
              const Divider(height: 16),
              // Body Content Field
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your private note...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagsPickerBottomSheet(BuildContext context, List<dynamic> tags) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Note Tags',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  tags.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              'No tags available. Create tags on the home screen.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            final isSelected = _selectedTagIds.contains(tag.id);
                            final color = Color(int.parse(tag.colorHex.replaceFirst('#', '0xff')));
                            
                            return FilterChip(
                              label: Text(tag.name),
                              selected: isSelected,
                              selectedColor: color.withValues(alpha: 0.2),
                              checkmarkColor: color,
                              onSelected: (selected) {
                                setModalState(() {
                                  _toggleTag(tag.id);
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
