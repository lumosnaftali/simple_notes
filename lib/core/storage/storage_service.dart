import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'encrypted_storage.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService has not been initialized');
});

class StorageService {
  final Box<Map> _notesBox;
  final Box<Map> _tagsBox;

  StorageService(this._notesBox, this._tagsBox);

  // Initialize storage service and pre-open the boxes
  static Future<StorageService> init() async {
    await EncryptedStorage.init();
    final notesBox = await EncryptedStorage.openEncryptedBox<Map>('notes_box_v1');
    final tagsBox = await EncryptedStorage.openEncryptedBox<Map>('tags_box_v1');
    return StorageService(notesBox, tagsBox);
  }

  Box<Map> get notesBox => _notesBox;
  Box<Map> get tagsBox => _tagsBox;
}
