import 'package:flutter/material.dart';
import 'package:sri_kot/log/log.dart';

class ShowLog extends StatefulWidget {
  const ShowLog({super.key});

  @override
  State<ShowLog> createState() => _ShowLogState();
}

class _ShowLogState extends State<ShowLog> {
  List<String> logs = [];

  @override
  void initState() {
    initLog();
    super.initState();
  }

  initLog() async {
    var storedLogs = await Log.getLog();

    setState(() {
      storedLogs = storedLogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          logs.isNotEmpty
              ? ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Text(logs[index]);
                  })
              : const Text("No data found")
        ],
      ),
    );
  }
}
