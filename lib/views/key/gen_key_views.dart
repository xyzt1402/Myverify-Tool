import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/services/auth/auth_services.dart';
import 'package:learningdart/services/cloud/cloud_public_key.dart';
import 'package:learningdart/services/cloud/firebase_cloud_storage.dart';
import 'package:learningdart/views/key/key_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:basic_utils/basic_utils.dart' as basic_ultis;

class GenerateKeyPairView extends StatefulWidget {
  const GenerateKeyPairView({Key? key}) : super(key: key);

  @override
  State<GenerateKeyPairView> createState() => _GenerateKeyPairViewState();
}

class _GenerateKeyPairViewState extends State<GenerateKeyPairView> {
  late final FirebaseCloudStorage _publicKeysService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _publicKeysService = FirebaseCloudStorage();
    super.initState();
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
    var secureRandom = FortunaRandom();

    var random = Random.secure();

    var seeds = <int>[];

    for (var i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    final keyParams = ECKeyGeneratorParameters(ECCurve_secp256k1());
    final keyGenerator = ECKeyGenerator()
      ..init(ParametersWithRandom(keyParams, secureRandom));
    return keyGenerator.generateKeyPair();
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;

    return appDocumentsPath;
  }

  Future<CloudPublicKey> createKeyPair() async {
    final keypair = generateKeyPair();
    final publicKeyValue = keypair.publicKey as ECPublicKey;
    final privateKeyValue = keypair.privateKey as ECPrivateKey;
    late final currentUser = AuthService.firebase().currentUser!;
    late final userId = currentUser.id;
    String pubPem = basic_ultis.CryptoUtils.encodeEcPublicKeyToPem(publicKeyValue);
    final newPublicKey = await _publicKeysService.uploadNewKey(
        ownerUserId: userId, publicKeyValue: pubPem);
    String privPem =
        basic_ultis.CryptoUtils.encodeEcPrivateKeyToPem(privateKeyValue);

    File file =
        File('${await getFilePath()}/${currentUser.email}.privatekey.pem');
    file.writeAsString(privPem);
    return newPublicKey;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create EC Pair'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: _publicKeysService.allPublickeys(ownerUserId: userId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allPublickeys =
                        snapshot.data as Iterable<CloudPublicKey>;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (allPublickeys.isEmpty)
                          ElevatedButton(
                            onPressed: createKeyPair,
                            child: const Text('Generate Key Pair'),
                          ),
                        PublicKeyView(
                            publicKeys: allPublickeys,
                            onDeletenote: (note) async {
                              await _publicKeysService.deleteKey(
                                  documentId: note.documentId);
                            }),
                      ],
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
    );
  }
}
