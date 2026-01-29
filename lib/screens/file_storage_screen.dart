import 'package:flutter/material.dart';
import '../services/file_storage_service.dart';

class FileStorageScreen extends StatefulWidget {
  const FileStorageScreen({super.key});

  @override
  State<FileStorageScreen> createState() => _FileStorageScreenState();
}

class _FileStorageScreenState extends State<FileStorageScreen> {
  final _filenameController = TextEditingController();
  final _contentController = TextEditingController();
  final _fileService = FileStorageService();
  List<String> _files = [];
  String _selectedFileContent = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await _fileService.listFiles();
    setState(() {
      _files = files;
    });
  }

  Future<void> _saveFile() async {
    if (_filenameController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      await _fileService.writeFile(
        _filenameController.text,
        _contentController.text,
      );
      _filenameController.clear();
      _contentController.clear();
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved!')),
        );
      }
    }
  }

  Future<void> _readFile(String filename) async {
    final content = await _fileService.readFile(filename);
    setState(() {
      _selectedFileContent = content;
    });
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(filename),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteFile(String filename) async {
    await _fileService.deleteFile(filename);
    _loadFiles();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Storage'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _filenameController,
                  decoration: const InputDecoration(
                    labelText: 'Filename (e.g., mydoc.txt)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveFile,
                  child: const Text('Save File'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _files.isEmpty
                ? const Center(child: Text('No files yet. Create one above!'))
                : ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final filename = _files[index];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(filename),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _readFile(filename),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFile(filename),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _filenameController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}