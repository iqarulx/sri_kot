import 'package:flutter/material.dart';

class DeletedItems extends StatefulWidget {
  const DeletedItems({super.key});

  @override
  State<DeletedItems> createState() => _DeletedItemsState();
}

class _DeletedItemsState extends State<DeletedItems> {
  Future? itemsHanlder;

  @override
  void initState() {
    itemsHanlder = getDeteledItems();
    super.initState();
  }

  Future getDeteledItems() async {}

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffEEEEEE),
        appBar: appbar(context),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
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
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        "Deleted Items",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
