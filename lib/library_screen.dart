import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

class LibraryScreen extends StatefulWidget {
  final Function(String path) playSound;

  LibraryScreen({required this.playSound});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Box<String> mp3Box;

  @override
  void initState() {
    super.initState();
    mp3Box = Hive.box<String>('mp3_files');
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final newFileName = path.split('/').last;

      final alreadyExists = mp3Box.values.any((storedPath) {
        return storedPath.split('/').last == newFileName;
      });

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This file is already added.")),
        );
      } else {
        mp3Box.add(path);
        setState(() {});
      }
    }
  }

  void _deleteFile(int index) {
    mp3Box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mp3Files = mp3Box.values.toList();

    return Scaffold(
      body: mp3Files.isEmpty
          ? Center(child: Text("No MP3 files added yet."))
          : ListView.builder(
        itemCount: mp3Files.length,
        itemBuilder: (context, index) {
          final fileName = mp3Files[index].split('/').last;

          return ListTile(
            leading: Icon(Icons.music_note),
            title: Text(fileName),
            onTap: () {
              widget.playSound(mp3Files[index]);
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteFile(index);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: Icon(Icons.add),
      ),
    );
  }
}
