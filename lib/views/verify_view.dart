import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_services.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(children: [
        const Text(
            "We've sent you an email verification. Please open it to verify your account "),
        const Text(
            "If you haven't received any email, please press the button below"),
        TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send Email Verification')),
        TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              if (mounted) context.go(registerRoute);
            },
            child: const Text('Restart'))
      ]),
    );
  }
}
