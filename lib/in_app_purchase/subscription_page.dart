import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/in_app_purchase/revenuecat.dart';
import '/view/screens/plans/plans.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plans"),
      ),
      body: Consumer<RevenuecatProvider>(
        builder: (context, revenuecatProvider, child) {
          final entitlement = revenuecatProvider.entitlement;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                buildEntitlement(entitlement),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Plans(),
                      ),
                    );
                  },
                  child: const Text("See Plans"),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildEntitlement(Entitlement entitlement) {
    switch (entitlement) {
      case Entitlement.users:
        return buildEntitlementIcon(
          text: "You are in paid plan",
          icon: Icons.paid,
        );
      case Entitlement.free:
      default:
        return buildEntitlementIcon(
          text: "You are in free plan",
          icon: Icons.lock,
        );
    }
  }

  Widget buildEntitlementIcon({required String text, required IconData icon}) {
    return Row(
      children: [Icon(icon), Text(text)],
    );
  }
}
