import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import '/provider/src/file_open.dart' as helper;

class PrintOptions extends StatefulWidget {
  final Uint8List pdfData;
  const PrintOptions({super.key, required this.pdfData});

  @override
  State<PrintOptions> createState() => _PrintOptionsState();
}

class _PrintOptionsState extends State<PrintOptions> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    await Printing.sharePdf(
                      bytes: widget.pdfData,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.link),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Share Pdf",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var data = Uint8List.fromList(widget.pdfData);
                    await helper.saveAndLaunchFile(data, 'Enquiry.pdf');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.arrow_down_circle),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Download",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => widget.pdfData,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.printer),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Print Pdf",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                const SocialPlatform platform = SocialPlatform.whatsapp;
                final directory = await getTemporaryDirectory();
                final filePath = '${directory.path}/document.pdf';
                final file = File(filePath);
                await file.writeAsBytes(widget.pdfData);
                await SocialSharingPlus.shareToSocialMedia(
                  platform,
                  "Sharing enquiry pdf",
                  media: filePath,
                  isOpenBrowser: true,
                );
              },
              child: Container(
                width: 325,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/whatsapp.png',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text("Whatsapp Share")
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashRadius: 20,
              constraints: const BoxConstraints(
                maxWidth: 40,
                maxHeight: 40,
                minWidth: 40,
                minHeight: 40,
              ),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pop(context, false);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        "Share Options",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
