import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:stallion_one/features/documents/domain/document_model.dart';

class DashboardDocumentCard extends StatefulWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onPreview;

  const DashboardDocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDownload,
    this.onPreview,
  });

  @override
  State<DashboardDocumentCard> createState() =>
      _DashboardDocumentCardState();
}

class _DashboardDocumentCardState
    extends State<DashboardDocumentCard> {

  bool hovered = false;

  IconData _getIcon(String fileName) {

    final file =
    fileName.toLowerCase();

    if (file.endsWith(".pdf")) {
      return Icons.picture_as_pdf;
    }

    if (file.endsWith(".doc") ||
        file.endsWith(".docx")) {
      return Icons.description;
    }

    if (file.endsWith(".xls") ||
        file.endsWith(".xlsx")) {
      return Icons.table_chart;
    }

    if (file.endsWith(".ppt") ||
        file.endsWith(".pptx")) {
      return Icons.slideshow;
    }

    if (file.endsWith(".png") ||
        file.endsWith(".jpg") ||
        file.endsWith(".jpeg")) {
      return Icons.image;
    }

    return Icons.insert_drive_file;
  }

  Color _getColor(String fileName) {

    final file =
    fileName.toLowerCase();

    if (file.endsWith(".pdf")) {
      return Colors.red;
    }

    if (file.endsWith(".doc") ||
        file.endsWith(".docx")) {
      return Colors.blue;
    }

    if (file.endsWith(".xls") ||
        file.endsWith(".xlsx")) {
      return Colors.green;
    }

    if (file.endsWith(".ppt") ||
        file.endsWith(".pptx")) {
      return Colors.orange;
    }

    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final isPhone =
        width < 600;

    final icon =
    _getIcon(widget.document.fileName);

    final color =
    _getColor(widget.document.fileName);

    return AnimatedScale(

      duration:
      const Duration(milliseconds: 180),

      scale:
      hovered ? 1.01 : 1,

      child: InkWell(

        onTap: widget.onTap,

        borderRadius:
        BorderRadius.circular(20),

        onHover: (value) {

          setState(() {

            hovered = value;

          });

        },

        child: AnimatedContainer(

          duration:
          const Duration(milliseconds: 250),

          margin:
          const EdgeInsets.only(bottom: 16),

          padding:
          EdgeInsets.all(
            isPhone ? 16 : 20,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(

              color: hovered
                  ? color
                  : Colors.grey.shade200,

            ),

            boxShadow: [

              BoxShadow(

                color:
                color.withOpacity(.10),

                blurRadius:
                hovered ? 18 : 10,

                offset:
                const Offset(0, 6),

              ),

            ],

          ),

          child: Row(

            children: [

              Container(

                padding:
                const EdgeInsets.all(16),

                decoration:
                BoxDecoration(

                  color:
                  color.withOpacity(.10),

                  borderRadius:
                  BorderRadius.circular(16),

                ),

                child: Icon(

                  icon,

                  size:
                  isPhone ? 32 : 40,

                  color: color,

                ),

              ),

              const SizedBox(width: 18),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      widget.document.title,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      TextStyle(

                        fontSize:
                        isPhone
                            ? 17
                            : 20,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 5),

                    Text(

                      widget.document.fileName,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),

                    ),

                    const SizedBox(height: 8),

                    Row(

                      children: [

                        Chip(

                          backgroundColor:
                          color.withOpacity(.12),

                          label: Text(
                            widget.document.category,
                          ),

                        ),

                        const SizedBox(width: 8),

                        Expanded(

                          child: Text(

                            DateFormat(
                              "dd MMM yyyy",
                            ).format(
                              widget.document.uploadedAt,
                            ),

                            overflow:
                            TextOverflow.ellipsis,

                            style:
                            TextStyle(

                              color: Colors.grey.shade600,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

              Column(

                children: [

                  IconButton(

                    tooltip: "Preview",

                    onPressed:
                    widget.onPreview,

                    icon: const Icon(
                      Icons.visibility,
                    ),

                  ),

                  IconButton(

                    tooltip: "Download",

                    onPressed:
                    widget.onDownload,

                    icon: const Icon(
                      Icons.download,
                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

}