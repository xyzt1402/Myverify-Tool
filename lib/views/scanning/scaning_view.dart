import 'package:flutter/material.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:learningdart/services/auth/auth_services.dart';
import 'package:learningdart/services/cloud/cloud_public_key.dart';
import 'package:learningdart/services/cloud/cloud_token.dart';
import 'package:learningdart/services/cloud/firebase_cloud_storage.dart';
import '../../constants/routes.dart';
import 'dart:developer' as dev show log;

class ScanningView extends StatefulWidget {
  final String value;
  const ScanningView({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<ScanningView> {
  late final FirebaseCloudStorage _publickeysService;
  String get userId => AuthService.firebase().currentUser!.id;
  String? token;

  @override
  void initState() {
    _publickeysService = FirebaseCloudStorage();
    super.initState();
  }

  String verifyToken(publickey, token) {
    dev.log(publickey);
    dev.log(token);
    final key = ECPublicKey(publickey);
    try {
      final jwt = JWT.verify(token, key);
      return ''' Status: Verified
                 Signature Information
                 ${jwt.payload} 
      ''';
    } on JWTError {
      return 'Status: Invalid Signature'; // ex: invalid signature
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Document"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(scannerRoute);
                  },
                  child: const Text('Click to start Scanning!')),
              const SizedBox(
                height: 20,
              ),
              if (widget.value != '')
                StreamBuilder(
                  stream: _publickeysService.allToken(documentId: widget.value),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final tokenSnapshot =
                              snapshot.data as Iterable<CloudToken>;
                          final tken = tokenSnapshot.elementAt(0);
                          return StreamBuilder(
                            stream: _publickeysService.allPublickeys(
                                ownerUserId: tken.ownerUserId),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  if (snapshot.hasData) {
                                    final publicKeySnapshot = snapshot.data
                                        as Iterable<CloudPublicKey>;
                                    final pkey = publicKeySnapshot.elementAt(0);
                                    return Text(
                                      verifyToken(pkey.publicKey, tken.token),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                default:
                                  return const CircularProgressIndicator();
                              }
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
