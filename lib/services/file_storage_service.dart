import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<File> writeFile(String filename, String content) async {
    final file = await _localFile(filename);
    return file.writeAsString(content);
  }

  Future<String> readFile(String filename) async {
    try {
      final file = await _localFile(filename);
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }

  Future<bool> deleteFile(String filename) async {
    try {
      final file = await _localFile(filename);
      await file.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> listFiles() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      final files = dir.listSync();
      return files
          .where((item) => item is File)
          .map((item) => item.path.split('/').last)
          .toList();
    } catch (e) {
      return [];
    }
  }
}