import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfReaderScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfReaderScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  bool isLoading = true;
  int totalPages = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Stack(
        children: [

          PDFView(
            filePath: widget.pdfPath,

            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageSnap: true,

            onRender: (pages) {
              setState(() {
                totalPages = pages ?? 0;
                isLoading = false;
              });
            },

            onPageChanged: (page, total) {
              setState(() {
                currentPage = page ?? 0;
              });
            },

            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
            },

            onPageError: (page, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
            },
          ),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

        ],
      ),

      bottomNavigationBar: Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          "Página ${currentPage + 1} de $totalPages",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}