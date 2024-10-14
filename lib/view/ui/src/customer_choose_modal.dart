import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view/ui/src/toast.dart';
import '/provider/provider.dart';

class CustomerChoose extends StatefulWidget {
  const CustomerChoose({super.key});

  @override
  State<CustomerChoose> createState() => _CustomerChooseState();
}

class _CustomerChooseState extends State<CustomerChoose> {
  String? option;

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
      title: const Text("Create/Choose customer"),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Add Customer'),
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
              title: const Text('Choose Customer'),
              value: '2',
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
                      if (option == "1") {
                        final connectionProvider =
                            Provider.of<ConnectionProvider>(context,
                                listen: false);
                        if (connectionProvider.isConnected) {
                          Navigator.pop(context, option);
                        } else {
                          showToast(
                            context,
                            content: "You need internet to add customer",
                            isSuccess: false,
                            top: false,
                          );
                        }
                      } else {
                        Navigator.pop(context, option);
                      }
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
