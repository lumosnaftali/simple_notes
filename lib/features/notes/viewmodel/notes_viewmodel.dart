import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/note_model.dart';
import '../data/note_repository.dart';
import '../../../core/storage/storage_service.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return NoteRepository(storageService.notesBox);
});

class NotesViewModel extends StateNotifier<List<Note>> {
  final NoteRepository _repository;
  static const _uuid = Uuid();

  NotesViewModel(this._repository) : super([]) {
    _loadNotes();
  }

  void _loadNotes() {
    state = _repository.getNotes()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by updated time desc by default
  }

  Future<Note> addNote({
    required String title,
    required String content,
    required List<String> tagIds,
  }) async {
    final now = DateTime.now();
    final newNote = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      tagIds: tagIds,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveNote(newNote);
    state = [newNote, ...state];
    return newNote;
  }

  Future<void> updateNote(Note updatedNote) async {
    final noteToSave = updatedNote.copyWith(updatedAt: DateTime.now());
    await _repository.saveNote(noteToSave);
    state = [
      for (final note in state)
        if (note.id == noteToSave.id) noteToSave else note
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    state = state.where((note) => note.id != id).toList();
  }
}

// Raw notes list provider
final notesViewModelProvider = StateNotifierProvider<NotesViewModel, List<Note>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NotesViewModel(repository);
});

// Search query provider
final noteSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected tag filter provider
final selectedTagFilterProvider = StateProvider<String?>((ref) => null);

// Filtered notes provider combining search + tag filters
final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesViewModelProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();
  final selectedTagId = ref.watch(selectedTagFilterProvider);

  return notes.where((note) {
    final matchesTag = selectedTagId == null || note.tagIds.contains(selectedTagId);
    final matchesSearch = query.isEmpty ||
        note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query);
    return matchesTag && matchesSearch;
  }).toList();
});
