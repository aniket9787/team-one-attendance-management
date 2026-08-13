import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/document_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _collection =>
      _firestore.collection(
        'documents',
      );

  // ==========================
  // ADD DOCUMENT
  // ==========================

  Future<void> addDocument({
    required String title,
    required String description,
    required String category,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    required String uploadedBy,
  }) async {
    await _collection.add({
      'title': title,
      'description': description,
      'category': category,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadedBy': uploadedBy,
      'uploadedAt':
      FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // ==========================
  // UPDATE DOCUMENT
  // ==========================

  Future<void> updateDocument({
    required String id,
    required String title,
    required String description,
    required String category,
  }) async {
    await _collection.doc(id).update({
      'title': title,
      'description': description,
      'category': category,
    });
  }

  // ==========================
  // DELETE DOCUMENT
  // ==========================

  Future<void> deleteDocument(
      String id,
      ) async {
    await _collection.doc(id).delete();
  }

  // ==========================
  // SINGLE DOCUMENT
  // ==========================

  Future<DocumentModel?> getDocument(
      String id,
      ) async {
    final doc =
    await _collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return DocumentModel.fromFirestore(
      doc,
    );
  }

  // ==========================
  // DOCUMENT STREAM
  // ==========================

  Stream<List<DocumentModel>>
  documentStream() {
    return _collection
        .orderBy(
      'uploadedAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
            DocumentModel
                .fromFirestore(
              doc,
            ),
      )
          .toList(),
    );
  }

  // ==========================
  // GET ALL DOCUMENTS
  // ==========================

  Future<List<DocumentModel>>
  getDocuments() async {
    final snapshot =
    await _collection
        .orderBy(
      'uploadedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          DocumentModel
              .fromFirestore(
            doc,
          ),
    )
        .toList();
  }

  // ==========================
  // DOCUMENT COUNT
  // ==========================

  Future<int> totalDocuments() async {
    final snapshot =
    await _collection.get();

    return snapshot.docs.length;
  }

  // ==========================
  // CATEGORY COUNT
  // ==========================

  Future<int> categoryCount(
      String category,
      ) async {
    final snapshot =
    await _collection
        .where(
      'category',
      isEqualTo: category,
    )
        .get();

    return snapshot.docs.length;
  }

  // ==========================
  // SEARCH DOCUMENTS
  // ==========================

  Future<List<DocumentModel>>
  searchDocuments(
      String keyword,
      ) async {
    final documents =
    await getDocuments();

    if (keyword.trim().isEmpty) {
      return documents;
    }

    final lower =
    keyword.toLowerCase();

    return documents.where((doc) {
      return doc.title
          .toLowerCase()
          .contains(lower) ||
          doc.description
              .toLowerCase()
              .contains(lower) ||
          doc.category
              .toLowerCase()
              .contains(lower) ||
          doc.fileName
              .toLowerCase()
              .contains(lower);
    }).toList();
  }

  // ==========================
  // FILTER BY CATEGORY
  // ==========================

  Future<List<DocumentModel>>
  filterByCategory(
      String category,
      ) async {
    if (category == "All") {
      return getDocuments();
    }

    final snapshot =
    await _collection
        .where(
      'category',
      isEqualTo: category,
    )
        .orderBy(
      'uploadedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          DocumentModel
              .fromFirestore(
            doc,
          ),
    )
        .toList();
  }

  // ==========================
  // ACTIVE DOCUMENTS
  // ==========================

  Future<List<DocumentModel>>
  activeDocuments() async {
    final snapshot =
    await _collection
        .where(
      'isActive',
      isEqualTo: true,
    )
        .orderBy(
      'uploadedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          DocumentModel
              .fromFirestore(
            doc,
          ),
    )
        .toList();
  }
}