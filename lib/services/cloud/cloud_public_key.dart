import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learningdart/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudPublicKey {
  final String documentId;
  final String ownerUserId;
  final String publicKey;

  const CloudPublicKey({
    required this.documentId,
    required this.ownerUserId,
    required this.publicKey,
  });

  CloudPublicKey.fromSnapshot(QueryDocumentSnapshot<Map<String,dynamic>> snapshot) : 
  documentId = snapshot.id,
  ownerUserId = snapshot.data()[ownerUserIdFieldName],
  publicKey = snapshot.data()[publicKeyFieldName] as String;
}
