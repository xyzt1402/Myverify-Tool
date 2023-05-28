import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learningdart/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudToken {
  final String documentId;
  final String ownerUserId;
  final String token;

  const CloudToken({
    required this.documentId,
    required this.ownerUserId,
    required this.token,
  });

  CloudToken.fromSnapshot(QueryDocumentSnapshot<Map<String,dynamic>> snapshot) : 
  documentId = snapshot.id,
  ownerUserId = snapshot.data()[ownerUserIdFieldName],
  token = snapshot.data()[tokenFieldName] as String;
}