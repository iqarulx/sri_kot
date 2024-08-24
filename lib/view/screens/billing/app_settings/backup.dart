import 'package:flutter/material.dart';
import 'package:sri_kot/services/local/local_service.dart';

class Backup extends StatefulWidget {
  const Backup({super.key});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  Map<String, List<Map<String, String>>>? filesData;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appbar(context),
        bottomNavigationBar: bottomAppbar(context),
        body: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: LocalService.getFiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No files found.'));
            } else {
              filesData = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: filesData!.entries.map((entry) {
                  final folderName = entry.key;
                  final fileDetails = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$folderName (${fileDetails.length})",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: fileDetails.length,
                        itemBuilder: (context, index) {
                          final fileDetail = fileDetails[index];
                          final fileName = fileDetail['filename'] ?? '';

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4),
                            title: Text('${index + 1}. $fileName'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.all(5),
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          if (filesData != null) {
            Navigator.pop(context, filesData); // Pass filesData on pop
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff2F4550),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Backup Now",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
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
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        "Your Data",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
