import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/bloc/auth_event.dart';
import 'package:learningdart/utilities/dialogs/error_dialog.dart';
import 'package:learningdart/utilities/dialogs/passwird_reset_email_sent_dialog.dart';

import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: ((context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Please enter a valid email');
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context,
                'You did not register using this email yet. Please go back one step to create new account');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
                context, "We are unable to send your Reset Password Email!");
          }
        }
      }),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                    'If you forgot your password, please enter your email for us to send a password reset link'),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Your Email Address',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send email Password reset link'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text('Back to login page'),
                ),
              ],
            ),
          )),
    );
  }
}
