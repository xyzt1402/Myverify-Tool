class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}

class CouldNotGetPublicKeyException extends CloudStorageException {}

class CouldNotUploadPublicKeyException extends CloudStorageException {}

class CouldNotDeletePublicKeyException extends CloudStorageException {}

class CouldNotGetTokenException extends CloudStorageException {}

class CouldNotUploadTokenException extends CloudStorageException {}

class CouldNotDeleteTokenException extends CloudStorageException {}