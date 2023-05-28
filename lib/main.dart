import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/helpers/loading/loading_screen.dart';
import 'package:learningdart/services/auth/bloc/auth_bloc.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/services/auth/bloc/auth_state.dart';
import 'package:learningdart/services/auth/firebase_auth_provider.dart';
import 'package:learningdart/views/forgot_password_view.dart';
import 'package:learningdart/views/key/gen_key_views.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/note/create_update_note_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/scanning/scaning_view.dart';
import 'package:learningdart/views/scanning/scanning_qr.dart';
import 'package:learningdart/views/signing/sign_pdf.dart';
import 'package:learningdart/views/verify_view.dart';
import 'package:learningdart/views/note/notes_view.dart';
import 'package:learningdart/constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
          generateKeyPairRoute: (context) => const GenerateKeyPairView(),
          signatureRoute: (context) => const SignatureView(),
          scannerRoute: (context) => const QRCodeScanner(),
          scanViewRoute: (context) => const ScanningView(value: '',)
        })
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a momment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        }
        {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
