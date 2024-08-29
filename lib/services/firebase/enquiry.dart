import 'dart:convert';
import 'package:flutter/material.dart';
import '/services/services.dart';

class Enquiry extends StatefulWidget {
  const Enquiry({super.key});

  @override
  State<Enquiry> createState() => _EnquiryState();
}

class _EnquiryState extends State<Enquiry> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseHelper().getEnquiry();
  }

  void _showProductDetails(Map<String, dynamic> order) {
    // Parse the JSON string into a List
    final productsJson = order['products'] as String;
    final List<dynamic> productsList = jsonDecode(productsJson);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                final product = productsList[index]
                    as Map<String, dynamic>; // Ensure type safety
                return ListTile(
                  title: Text(product['product_name'] ?? 'No Name'),
                  subtitle: Text('Quantity: ${product['qty'] ?? 0}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquiries'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final customerData =
                    jsonDecode(order['customer']) as Map<String, dynamic>;
                return ListTile(
                  title: Text('Customer: ${customerData['customer_name']}'),
                  subtitle: Text('Created Date: ${order['created_date']}'),
                  onTap: () => _showProductDetails(order),
                );
              },
            );
          }
        },
      ),
    );
  }
}
