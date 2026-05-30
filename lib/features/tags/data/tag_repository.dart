import 'package:hive_flutter/hive_flutter.dart';
import 'tag_model.dart';

class TagRepository {
  final Box<Map> _tagsBox;

  TagRepository(this._tagsBox);

  // Retrieve all tags
  List<Tag> getTags() {
    return _tagsBox.values
        .map((map) => Tag.fromJson(Map<dynamic, dynamic>.from(map)))
        .toList();
  }

  // Save or update a tag
  Future<void> saveTag(Tag tag) async {
    await _tagsBox.put(tag.id, tag.toJson());
  }

  // Delete a tag
  Future<void> deleteTag(String id) async {
    await _tagsBox.delete(id);
  }
}
