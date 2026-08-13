import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;

  final String title;

  final String description;

  final String category;

  final String fileName;

  final String fileUrl;

  final int fileSize;

  final String uploadedBy;

  final DateTime uploadedAt;

  final bool isActive;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.isActive,
  });

  factory DocumentModel.fromFirestore(
      DocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    return DocumentModel(
      id: doc.id,

      title: data['title'] ?? '',

      description:
      data['description'] ?? '',

      category:
      data['category'] ?? 'General',

      fileName:
      data['fileName'] ?? '',

      fileUrl:
      data['fileUrl'] ?? '',

      fileSize:
      (data['fileSize'] ?? 0) as int,

      uploadedBy:
      data['uploadedBy'] ?? '',

      uploadedAt:
      (data['uploadedAt']
      as Timestamp?)
          ?.toDate() ??
          DateTime.now(),

      isActive:
      data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,

      'description': description,

      'category': category,

      'fileName': fileName,

      'fileUrl': fileUrl,

      'fileSize': fileSize,

      'uploadedBy': uploadedBy,

      'uploadedAt':
      Timestamp.fromDate(
        uploadedAt,
      ),

      'isActive': isActive,
    };
  }

  String get formattedDate {
    return "${uploadedAt.day.toString().padLeft(2, '0')}/"
        "${uploadedAt.month.toString().padLeft(2, '0')}/"
        "${uploadedAt.year}";
  }

  String get formattedSize {
    if (fileSize < 1024) {
      return "$fileSize B";
    }

    if (fileSize < 1024 * 1024) {
      return "${(fileSize / 1024).toStringAsFixed(1)} KB";
    }

    if (fileSize < 1024 * 1024 * 1024) {
      return "${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB";
    }

    return "${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }

  String get iconName {
    final lower =
    fileName.toLowerCase();

    if (lower.endsWith('.pdf')) {
      return 'pdf';
    }

    if (lower.endsWith('.doc') ||
        lower.endsWith('.docx')) {
      return 'word';
    }

    if (lower.endsWith('.xls') ||
        lower.endsWith('.xlsx')) {
      return 'excel';
    }

    if (lower.endsWith('.ppt') ||
        lower.endsWith('.pptx')) {
      return 'powerpoint';
    }

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png')) {
      return 'image';
    }

    return 'file';
  }

  bool get isPdf =>
      fileName.toLowerCase().endsWith('.pdf');

  bool get isImage =>
      fileName.toLowerCase().endsWith('.png') ||
          fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg');

  bool get isWord =>
      fileName.toLowerCase().endsWith('.doc') ||
          fileName.toLowerCase().endsWith('.docx');

  bool get isExcel =>
      fileName.toLowerCase().endsWith('.xls') ||
          fileName.toLowerCase().endsWith('.xlsx');

  bool get isPowerPoint =>
      fileName.toLowerCase().endsWith('.ppt') ||
          fileName.toLowerCase().endsWith('.pptx');
}