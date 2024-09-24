import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/model/model.dart';

class PurchaseDetailsView extends StatefulWidget {
  final PurchaseHistoryModel model;
  const PurchaseDetailsView({super.key, required this.model});

  @override
  State<PurchaseDetailsView> createState() => _PurchaseDetailsViewState();
}

class _PurchaseDetailsViewState extends State<PurchaseDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text("Purchase Information",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(
                  height: 15,
                ),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  children: [
                    _buildTableRow(
                      context,
                      "Company Name",
                      widget.model.companyName ?? '',
                    ),
                    _buildTableRow(
                      context,
                      "Product Name",
                      widget.model.productName ?? '',
                    ),
                    _buildTableRow(
                      context,
                      "Amount",
                      widget.model.amount ?? '',
                    ),
                    _buildTableRow(
                      context,
                      "Currency",
                      widget.model.currency ?? '',
                    ),
                    _buildTableRow(
                      context,
                      "Created at",
                      DateFormat('dd-MM-yyyy hh:mm a')
                          .format(widget.model.createdAt ?? DateTime.now()),
                    ),
                    _buildTableRow(
                      context,
                      "Status",
                      widget.model.status ?? '',
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$title : ",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
