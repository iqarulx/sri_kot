import 'package:flutter/material.dart';

class PolicyDialog extends StatefulWidget {
  const PolicyDialog({super.key});

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 1);
            },
            child: const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 2);
            },
            child: const Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 3);
            },
            child: const Text(
              'Refund Policy',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
