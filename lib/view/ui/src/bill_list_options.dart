import 'package:flutter/material.dart';

class BillListOptions extends StatefulWidget {
  final String title;
  const BillListOptions({super.key, required this.title});

  @override
  State<BillListOptions> createState() => _BillListOptionsState();
}

class _BillListOptionsState extends State<BillListOptions> {
  String? billListOption;
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
      title: Text(widget.title),
      actions: [
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          RadioListTile<String>(
            title: const Text('Share'),
            value: '1',
            groupValue: billListOption,
            onChanged: (value) {
              setState(() {
                Navigator.pop(context, value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('Print'),
            value: '2',
            groupValue: billListOption,
            onChanged: (value) {
              setState(() {
                Navigator.pop(context, value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('Edit'),
            value: '3',
            groupValue: billListOption,
            onChanged: (value) {
              setState(() {
                Navigator.pop(context, value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('Delete'),
            value: '4',
            groupValue: billListOption,
            onChanged: (value) {
              setState(() {
                Navigator.pop(context, value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ]),
      ],
    );
  }
}
