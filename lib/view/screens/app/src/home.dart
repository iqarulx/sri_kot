import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Listener')),
      body: Center(
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return Text(
              connectionProvider.isConnected ? 'Connected' : 'Disconnected',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger a rebuild to reflect the current connection status
          // No action needed here since the UI updates automatically
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
