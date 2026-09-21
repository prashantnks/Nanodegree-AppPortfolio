import 'dart:convert';

import 'package:file_picker/file_picker.dart';

class ContentLoader {
  const ContentLoader();

  static const allowedExtensions = ['txt', 'md', 'text'];

  Future<LoadedContent?> pickTextFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    return LoadedContent(
      title: _titleFromName(file.name),
      body: utf8.decode(bytes, allowMalformed: true).trim(),
    );
  }

  String _titleFromName(String name) {
    final withoutExtension = name.replaceAll(RegExp(r'\.[A-Za-z0-9]+$'), '');
    return withoutExtension.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  }
}

class LoadedContent {
  const LoadedContent({required this.title, required this.body});

  final String title;
  final String body;
}
