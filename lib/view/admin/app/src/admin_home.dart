import 'package:flutter/material.dart';
import '/view/admin/admin.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

var adminHomeKey = GlobalKey<ScaffoldState>();

class _AdminHomeState extends State<AdminHome> {
  final List<Widget> pages = const [
    Dashboard(),
    Register(
      route: AdminHome(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    sidebar.addListener(changeEvent);
  }

  @override
  void dispose() {
    sidebar.removeListener(changeEvent);
    super.dispose();
  }

  void changeEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _onWillPop() async {
    if (sidebar.crttab != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: adminHomeKey,
        drawer: const SideBar(),
        body: pages[sidebar.crttab],
      ),
    );
  }
}
