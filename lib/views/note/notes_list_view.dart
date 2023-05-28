import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

typedef FileCallback = void Function(FileSystemEntity file);

class FilesListView extends StatelessWidget {
  final List<FileSystemEntity> fileEntities;
  final FileCallback onDeletefile;

  const FilesListView({
    Key? key,
    required this.fileEntities,
    required this.onDeletefile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fileEntities.length,
      itemBuilder: (context, index) {
        final file = fileEntities.elementAt(index);
        return ListTile(
          title: Text(
            path.basename(file.path),
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(onPressed: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeletefile(file);
            }
          }, icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
