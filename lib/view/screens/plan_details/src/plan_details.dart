import 'package:flutter/material.dart';
import '/view/screens/screens.dart';

class PlanDetails extends StatefulWidget {
  const PlanDetails({super.key});

  @override
  State<PlanDetails> createState() => _PlanDetailsState();
}

class _PlanDetailsState extends State<PlanDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Plan Details"),
      ),
      backgroundColor: const Color(0xffEEEEEE),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("No Data Found")],
        ),
      ),
    );
  }
}
