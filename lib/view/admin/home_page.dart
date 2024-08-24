import 'package:flutter/material.dart';
import 'package:sri_kot/view/admin/screens/dashboard/dashboard.dart';
import 'screens/register/register.dart';
import 'utils/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

var homeKey = GlobalKey<ScaffoldState>();

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = const [
    Dashboard(),
    Register(),
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
        key: homeKey,
        drawer: const SideBar(),
        body: pages[sidebar.crttab],
      ),
    );
  }
}
