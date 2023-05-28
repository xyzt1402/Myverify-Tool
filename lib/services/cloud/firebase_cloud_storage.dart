import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learningdart/services/cloud/cloud_note.dart';
import 'package:learningdart/services/cloud/cloud_public_key.dart';
import 'package:learningdart/services/cloud/cloud_storage_constants.dart';

import 'cloud_storage_exceptions.dart';
import 'cloud_token.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  final publickeys = FirebaseFirestore.instance.collection('publicKey');

  final token = FirebaseFirestore.instance.collection('token');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> deleteKey({required String documentId}) async {
    try {
      await publickeys.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeletePublicKeyException();
    }
  }

  Future<void> deleteToken({required String documentId}) async {
    try {
      await token.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteTokenException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Stream<Iterable<CloudPublicKey>> allPublickeys(
          {required String ownerUserId}) =>
      publickeys.snapshots().map((event) => event.docs
          .map((doc) => CloudPublicKey.fromSnapshot(doc))
          .where((publickey) => publickey.ownerUserId == ownerUserId));

  Stream<Iterable<CloudToken>> allToken({required String documentId}) =>
      token.snapshots().map((event) => event.docs
          .map((doc) => CloudToken.fromSnapshot(doc))
          .where((token) => (token.documentId == documentId)));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException;
    }
  }

  Future<Iterable<CloudPublicKey>> getKeys(
      {required String ownerUserId}) async {
    try {
      return await publickeys
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudPublicKey.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetPublicKeyException();
    }
  }

  Future<Iterable<CloudToken>> getToken({required String documentId}) async {
    try {
      return await token
          .where(
            tokenFieldName,
            isEqualTo: documentId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudToken.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetTokenException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchNote = await document.get();
    return CloudNote(
      documentId: fetchNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  Future<CloudPublicKey> uploadNewKey(
      {required String ownerUserId, required String publicKeyValue}) async {
    final document = await publickeys.add({
      ownerUserIdFieldName: ownerUserId,
      publicKeyFieldName: publicKeyValue,
    });
    final fetchPublicKey = await document.get();
    return CloudPublicKey(
      documentId: fetchPublicKey.id,
      ownerUserId: ownerUserId,
      publicKey: publicKeyValue,
    );
  }

  Future<CloudToken> uploadNewToken(
      {required String ownerUserId, required String tokenValue}) async {
    final document = await token.add({
      ownerUserIdFieldName: ownerUserId,
      tokenFieldName: tokenValue,
    });
    final fetchToken = await document.get();
    return CloudToken(
      documentId: fetchToken.id,
      ownerUserId: ownerUserId,
      token: tokenValue,
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
