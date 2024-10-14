import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PdfOption extends StatefulWidget {
  const PdfOption({super.key});

  @override
  State<PdfOption> createState() => _PdfOptionState();
}

class _PdfOptionState extends State<PdfOption> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Icon(Iconsax.info_circle),
            SizedBox(width: 8),
            Text(
              "Choose pdf",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("What do you want to print?"),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: const Text('Format 1'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 2);
              },
              child: const Text('Format 2'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 3);
              },
              child: const Text('Format 3'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
