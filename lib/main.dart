import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_services.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/note/new_note_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verify_view.dart';
import 'package:go_router/go_router.dart';
import 'package:learningdart/views/note/notes_view.dart';

import 'constants/routes.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: homeRoute,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: loginRoute,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: registerRoute,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: notesRoute,
      builder: (context, state) => const NotesView(),
    ),
    GoRoute(
      path: verifyEmailRoute,
      builder: (context, state) => const VerifyEmailView(),
    ),
    GoRoute(
      path: newNoteRoute,
      builder: (context, state) => const NewNoteView(),
    ),
  ],
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}


