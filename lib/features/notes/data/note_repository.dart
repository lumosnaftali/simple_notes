import 'package:hive_flutter/hive_flutter.dart';
import 'note_model.dart';

class NoteRepository {
  final Box<Map> _notesBox;

  NoteRepository(this._notesBox);

  // Retrieve all notes
  List<Note> getNotes() {
    return _notesBox.values
        .map((map) => Note.fromJson(Map<dynamic, dynamic>.from(map)))
        .toList();
  }

  // Save or update a note
  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note.toJson());
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }
}
