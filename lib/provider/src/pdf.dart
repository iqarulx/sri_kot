import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void run() async {
  // Create a PDF document
  final pdf = pw.Document();

  // Define a page size of 3 inches wide and 4 inches tall
  const pageWidth = 3 * PdfPageFormat.inch; // 3 inches
  const pageHeight = 4 * PdfPageFormat.inch; // Example height

  // Add a page to the document
  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(pageWidth, pageHeight),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(
            'Hello, this is a 3-inch PDF! Hello, this is a 3-inch PDF Hello, this is a 3-inch PDF! Hello, this is a 3-inch PDF',
            style: const pw.TextStyle(fontSize: 24),
          ),
        );
      },
    ),
  );

  // Trigger the print dialog
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
