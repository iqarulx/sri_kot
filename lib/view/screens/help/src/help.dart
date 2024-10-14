import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Help"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Introduction",
                        style: TextStyle(
                          color: Color(0xff003049),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "In today’s fast-paced business environment, efficiency and accuracy in financial transactions are paramount. A well-designed invoice and estimate billing mobile application offers businesses a streamlined solution for managing their financial processes, ensuring they stay organized and on top of their billing needs. This description explores the functionality, benefits, and various aspects of such an application, aiming to provide a thorough understanding of its role in modern business operations.",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Key Features",
                        style: TextStyle(
                          color: Color(0xff003049),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "1. User-Friendly Interface",
                            style: TextStyle(
                              color: Color(0xff003049),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Intuitive Dashboard: A clean, intuitive dashboard allows users to easily navigate through various sections, including invoices, estimates, payments, and client management.",
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Customizable Layouts: Users can customize the layout and appearance of their invoices and estimates, ensuring they reflect their brand identity.",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "2. Invoice Management",
                            style: TextStyle(
                              color: Color(0xff003049),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Create and Send Invoices: Generate professional invoices quickly using pre-defined templates or custom designs. Users can include essential details like item descriptions, quantities, rates, and total amounts.",
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Recurring Invoices: Set up recurring invoices for ongoing services or subscriptions, automating billing processes and reducing manual effort.",
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Invoice Tracking: Track the status of invoices in real-time, including pending, paid, and overdue invoices. Automated reminders and notifications help in managing follow-ups.",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
