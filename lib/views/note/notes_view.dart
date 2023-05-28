import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/enums/menu_action.dart';
import 'package:learningdart/services/auth/auth_services.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';
import 'package:learningdart/utilities/dialogs/logout_dialog.dart';
import 'package:learningdart/views/note/notes_list_view.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late Future<List<FileSystemEntity>> listOfFiles;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    listOfFiles = getAllFiles();
    super.initState();
  }

  Future<List<FileSystemEntity>> getAllFiles() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory appDocDirFolder =
        Directory('${appDocDir.path}/pdf-signed-storage/');
    final List<FileSystemEntity> entities =
        appDocDirFolder.listSync(recursive: true, followLinks: false);
    return entities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Signed Doc'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(generateKeyPairRoute);
                },
                icon: const Icon(Icons.key)),
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(signatureRoute)
                      .then((value) => setState(() {
                            listOfFiles = getAllFiles();
                          }));
                },
                icon: const Icon(Icons.verified)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(scanViewRoute);
                },
                icon: const Icon(Icons.qr_code_scanner)),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout && mounted) {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Log out'),
                  ),
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: listOfFiles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final allfileEntities = snapshot.data as List<FileSystemEntity>;
              return FilesListView(
                  fileEntities: allfileEntities,
                  onDeletefile: (filecall) async {
                    await filecall.delete();
                    setState(() {
                      listOfFiles = getAllFiles();
                    });
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }
}
