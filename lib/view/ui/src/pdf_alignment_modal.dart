import 'package:flutter/material.dart';

class PdfAlignmentModal extends StatefulWidget {
  final int pdfAlignment;
  const PdfAlignmentModal({super.key, required this.pdfAlignment});

  @override
  State<PdfAlignmentModal> createState() => _PdfAlignmentModalState();
}

class _PdfAlignmentModalState extends State<PdfAlignmentModal> {
  String? option;

  @override
  void initState() {
    super.initState();
    if (widget.pdfAlignment == 1) {
      setState(() {
        option = "1";
      });
    } else if (widget.pdfAlignment == 2) {
      setState(() {
        option = "2";
      });
    } else {
      setState(() {
        option = "3";
      });
    }
  }

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
      title: const Text("Choose Alignment"),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose the product name alignment\n in A4, A5 pdf",
              textAlign: TextAlign.center,
            ),
            RadioListTile<String>(
              title: const Text('Left'),
              value: '1',
              groupValue: option,
              onChanged: (value) {
                setState(() {
                  option = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: const Text('Right'),
              value: '2',
              groupValue: option,
              onChanged: (value) {
                setState(() {
                  option = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: const Text('Center'),
              value: '3',
              groupValue: option,
              onChanged: (value) {
                setState(() {
                  option = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffF2F2F2),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xff575757),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context, option);
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Color(0xffF4F4F9),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
