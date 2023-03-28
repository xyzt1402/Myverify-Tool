import 'package:flutter/material.dart';
import 'package:learningdart/services/crud/notes_services.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeletenote;
  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeletenote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
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
