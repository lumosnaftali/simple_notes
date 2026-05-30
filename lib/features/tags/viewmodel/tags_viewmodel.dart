import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/tag_model.dart';
import '../data/tag_repository.dart';
import '../../../core/storage/storage_service.dart';

// Repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return TagRepository(storageService.tagsBox);
});

// ViewModel notifier
class TagsViewModel extends StateNotifier<List<Tag>> {
  final TagRepository _repository;
  static const _uuid = Uuid();

  TagsViewModel(this._repository) : super([]) {
    _loadTags();
  }

  void _loadTags() {
    state = _repository.getTags();
  }

  Future<void> addTag(String name, String colorHex) async {
    final newTag = Tag(
      id: _uuid.v4(),
      name: name,
      colorHex: colorHex,
    );
    await _repository.saveTag(newTag);
    state = [...state, newTag];
  }

  Future<void> updateTag(Tag updatedTag) async {
    await _repository.saveTag(updatedTag);
    state = [
      for (final tag in state)
        if (tag.id == updatedTag.id) updatedTag else tag
    ];
  }

  Future<void> deleteTag(String id) async {
    await _repository.deleteTag(id);
    state = state.where((tag) => tag.id != id).toList();
  }
}

// ViewModel provider
final tagsViewModelProvider = StateNotifierProvider<TagsViewModel, List<Tag>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return TagsViewModel(repository);
});
