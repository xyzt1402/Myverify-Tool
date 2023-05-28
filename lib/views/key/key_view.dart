import 'package:flutter/material.dart';
import 'package:learningdart/services/cloud/cloud_public_key.dart';
import 'package:learningdart/utilities/dialogs/delete_dialog.dart';

typedef PublicKeyCallback = void Function(CloudPublicKey pubkey);

class PublicKeyView extends StatelessWidget {
  final Iterable<CloudPublicKey> publicKeys;
  final PublicKeyCallback onDeletenote;

  const PublicKeyView({
    Key? key,
    required this.publicKeys,
    required this.onDeletenote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: publicKeys.length,
      itemBuilder: (context, index) {
        final pubkey = publicKeys.elementAt(index);
        return ListTile(
          title: Text(
            pubkey.publicKey,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeletenote(pubkey);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
