import 'package:flutter/material.dart';
import '/services/services.dart';
import 'commonwidget.dart';

class StateSearch extends StatefulWidget {
  const StateSearch({super.key});

  @override
  State<StateSearch> createState() => _StateSearchState();
}

class _StateSearchState extends State<StateSearch> {
  TextEditingController searchForm = TextEditingController();
  List<String> states = [];
  List<String> allStates = [];
  Future? statesHandler;

  void resetSearch() {
    setState(() {
      states = List.from(allStates);
    });
  }

  Future getState() async {
    try {
      await FireStore().getState().then((value) {
        for (var element in value) {
          setState(() {
            states.add(element);
            allStates.add(element);
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  searchState() {
    List<String> filteredList = allStates.where((state) {
      return state.toLowerCase().contains(searchForm.text.toLowerCase());
    }).toList();
    setState(() {
      states = filteredList;
    });
  }

  @override
  void initState() {
    super.initState();
    stateHandler = getState();
  }

  Future? stateHandler;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: Column(
          children: [
            InputForm(
              labelName: "Search state",
              controller: searchForm,
              formName: "State",
              onChanged: (value) {
                searchState();
              },
              suffixIcon: searchForm.text.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        searchForm.clear();
                        resetSearch();
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    )
                  : null,
            ),
            FutureBuilder(
              future: stateHandler,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return futureLoading(context);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Flexible(
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: states.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context, states[index]);
                          },
                          title: Text(
                            states[index],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
