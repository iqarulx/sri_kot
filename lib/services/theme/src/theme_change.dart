import 'package:flutter/material.dart';
import '/services/services.dart';
import '/app/app.dart';

class ChangeThemeApp with ChangeNotifier {
  String _theme = "theme1";
  get theme => _theme;

  toggletab(String theme) {
    _theme = theme;
    notifyListeners();
  }
}

class ThemeChange extends StatefulWidget {
  const ThemeChange({super.key});

  @override
  State<ThemeChange> createState() => _ThemeChangeState();
}

class _ThemeChangeState extends State<ThemeChange> {
  String? theme;

  @override
  void initState() {
    getTheme();
    super.initState();
  }

  getTheme() async {
    var dbTheme = await LocalDB.getTheme();
    setState(() {
      theme = dbTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("App Themes"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.pop(context, true);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    changeThemeApp.toggletab('theme1');
                                    theme = "theme1";
                                    LocalDB.setTheme(theme: "theme1");
                                  });
                                },
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: theme == "theme1"
                                        ? Colors.grey.shade100
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.asset(
                                                'assets/theme1.jpg',
                                                height: 240,
                                                fit: BoxFit.contain,
                                              )),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: theme == "theme1"
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: theme == "theme1"
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Primary",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    changeThemeApp.toggletab('theme2');
                                    theme = "theme2";
                                    LocalDB.setTheme(theme: "theme2");
                                  });
                                },
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: theme == "theme2"
                                        ? Colors.grey.shade100
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.asset(
                                              'assets/theme2.jpg',
                                              height: 240,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: theme == "theme2"
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: theme == "theme2"
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Red",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    changeThemeApp.toggletab('theme3');
                                    theme = "theme3";
                                    LocalDB.setTheme(theme: "theme3");
                                  });
                                },
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: theme == "theme3"
                                        ? Colors.grey.shade100
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.asset(
                                                'assets/theme3.jpg',
                                                height: 240,
                                                fit: BoxFit.contain,
                                              )),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: theme == "theme3"
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: theme == "theme3"
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Sea",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    changeThemeApp.toggletab('theme4');
                                    theme = "theme4";
                                    LocalDB.setTheme(theme: "theme4");
                                  });
                                },
                                child: Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: theme == "theme4"
                                        ? Colors.grey.shade100
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.asset(
                                              'assets/theme4.jpg',
                                              height: 240,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            color: theme == "theme4"
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: theme == "theme4"
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Brown",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
