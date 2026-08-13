import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  // ==========================
  // PICK FILE
  // ==========================

  Future<File?> pickFile() async {
    final result = await fp.FilePicker.pickFiles(
      allowMultiple: false,
    );

    if (result == null) {
      return null;
    }

    final path =
        result.files.single.path;

    if (path == null) {
      return null;
    }

    return File(path);
  }

  // ==========================
  // PICK FILE NAME
  // ==========================

  Future<String?> pickFileName() async {
    final result = await fp.FilePicker.pickFiles(
      allowMultiple: false,
    );

    if (result == null) {
      return null;
    }

    return result.files.single.name;
  }

  // ==========================
  // PICK FILE SIZE
  // ==========================

  Future<int?> pickFileSize() async {

    final result = await fp.FilePicker.pickFiles(
      allowMultiple: false,
    );
    if (result == null) {
      return null;
    }

    return result.files.single.size;
  }

  // ==========================
  // UPLOAD FILE
  // ==========================

  Future<String> uploadDocument({
    required File file,
    required String fileName,
  }) async {
    final fileRef = _storage.ref().child(
      "documents/${DateTime.now().millisecondsSinceEpoch}_$fileName",
    );

    await fileRef.putFile(file);

    return await fileRef.getDownloadURL();
  }

  // ==========================
  // DELETE FILE
  // ==========================

  Future<void> deleteDocument(
      String fileUrl,
      ) async {
    final ref =
    _storage.refFromURL(fileUrl);

    await ref.delete();
  }

  // ==========================
  // GET DOWNLOAD URL
  // ==========================

  Future<String> getDownloadUrl(
      String path,
      ) async {
    return await _storage
        .ref(path)
        .getDownloadURL();
  }
}