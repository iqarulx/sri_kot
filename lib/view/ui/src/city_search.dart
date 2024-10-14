import 'package:flutter/material.dart';
import '/services/services.dart';
import 'commonwidget.dart';
import 'custom_city_alert.dart';

class CitySearch extends StatefulWidget {
  final String state;
  const CitySearch({super.key, required this.state});

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  TextEditingController searchForm = TextEditingController();
  List<String> city = [];
  List<String> allCity = [];
  Future? statesHandler;

  void resetSearch() {
    setState(() {
      city = List.from(allCity);
    });
  }

  Future getCity() async {
    try {
      await FireStore().getCity(state: widget.state).then((value) {
        for (var element in value) {
          setState(() {
            city.add(element);
            allCity.add(element);
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  searchCity() {
    List<String> filteredList = allCity.where((city) {
      return city.toLowerCase().contains(searchForm.text.toLowerCase());
    }).toList();
    setState(() {
      city = filteredList;
    });
  }

  @override
  void initState() {
    super.initState();
    cityHandler = getCity();
  }

  Future? cityHandler;

  customCity() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: CustomCityAlert(
            state: widget.state,
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          if (value) {
            cityHandler = getCity();
            setState(() {});
          }
        }
      },
    );
  }

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
              labelName: "Search city in ${widget.state}",
              controller: searchForm,
              formName: "City",
              onChanged: (value) {
                searchCity();
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
                  : TextButton(
                      onPressed: () {
                        searchForm.clear();
                        customCity();
                      },
                      child: const Text(
                        "Add City",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    ),
            ),
            FutureBuilder(
              future: cityHandler,
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
                      itemCount: city.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context, city[index]);
                          },
                          title: Text(
                            city[index],
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
