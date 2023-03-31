import 'package:flutter/material.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeletenote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeletenote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(onPressed: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeletenote(note);
            }
          }, icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
