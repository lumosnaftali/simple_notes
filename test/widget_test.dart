import 'package:flutter_test/flutter_test.dart';
import 'package:simple_notes/features/notes/data/note_model.dart';
import 'package:simple_notes/features/tags/data/tag_model.dart';

void main() {
  group('Tag Model Tests', () {
    test('Tag serialization and deserialization', () {
      final tag = Tag(id: '1', name: 'Work', colorHex: '0xFF4CAF50');
      final json = tag.toJson();
      final fromJson = Tag.fromJson(json);

      expect(fromJson.id, '1');
      expect(fromJson.name, 'Work');
      expect(fromJson.colorHex, '0xFF4CAF50');
    });
  });

  group('Note Model Tests', () {
    test('Note serialization and deserialization', () {
      final now = DateTime.now();
      final note = Note(
        id: '101',
        title: 'Meeting Notes',
        content: 'Discuss budget allocation 🚀',
        tagIds: ['1'],
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      final fromJson = Note.fromJson(json);

      expect(fromJson.id, '101');
      expect(fromJson.title, 'Meeting Notes');
      expect(fromJson.content, 'Discuss budget allocation 🚀');
      expect(fromJson.tagIds, contains('1'));
      expect(fromJson.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(fromJson.updatedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('Note copyWith works correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: '101',
        title: 'Meeting Notes',
        content: 'Discuss budget allocation 🚀',
        tagIds: ['1'],
        createdAt: now,
        updatedAt: now,
      );

      final updated = note.copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );

      expect(updated.id, '101');
      expect(updated.title, 'Updated Title');
      expect(updated.content, 'Updated Content');
      expect(updated.tagIds, contains('1'));
    });
  });
}
