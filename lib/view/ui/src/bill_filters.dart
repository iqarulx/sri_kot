import 'package:flutter/material.dart';

class BillFilters extends StatefulWidget {
  const BillFilters({super.key});

  @override
  State<BillFilters> createState() => _BillFiltersState();
}

class _BillFiltersState extends State<BillFilters> {
  var addProductKey = GlobalKey<FormState>();
  TextEditingController searchForm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }
}
