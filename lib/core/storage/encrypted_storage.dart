import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EncryptedStorage {
  static const String _keyName = 'secure_notes_aes_key_v1';
  static const _secureStorage = FlutterSecureStorage();
  
  static Uint8List? _cachedEncryptionKey;

  // Initialize Hive and retrieve or generate the encryption key
  static Future<void> init() async {
    await Hive.initFlutter();
    await _getOrCreateEncryptionKey();
  }

  // Get the encryption key or create one if it doesn't exist
  static Future<Uint8List> _getOrCreateEncryptionKey() async {
    if (_cachedEncryptionKey != null) {
      return _cachedEncryptionKey!;
    }

    try {
      // Try to read key from secure storage
      final hexKey = await _secureStorage.read(key: _keyName);
      
      if (hexKey != null) {
        final keyBytes = _hexDecode(hexKey);
        if (keyBytes.length == 32) {
          _cachedEncryptionKey = keyBytes;
          return keyBytes;
        }
      }
    } catch (e) {
      // Fallback or log if secure storage fails
      // In some environments, secure storage might fail initially or during testing
    }

    // Generate a new 256-bit (32-byte) key
    final newKey = Hive.generateSecureKey();
    final hexKey = _hexEncode(newKey);
    
    try {
      await _secureStorage.write(key: _keyName, value: hexKey);
    } catch (e) {
      // If secure storage fails (e.g. not configured on some test env), 
      // we still use the key in-memory but it won't persist securely across launches.
    }
    
    _cachedEncryptionKey = Uint8List.fromList(newKey);
    return _cachedEncryptionKey!;
  }

  // Helper to open an encrypted Hive box
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    final key = await _getOrCreateEncryptionKey();
    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }

  // Clear all data (e.g. for reset)
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    await _secureStorage.delete(key: _keyName);
    _cachedEncryptionKey = null;
  }

  // Simple Hex encode/decode helpers to store key as string
  static String _hexEncode(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _hexDecode(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      final num = hex.substring(i, i + 2);
      result[i ~/ 2] = int.parse(num, radix: 16);
    }
    return result;
  }
}
