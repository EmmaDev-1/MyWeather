import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_weather/Utils/chage_background_colors.dart';
import 'package:my_weather/models/weather_model.dart';
import 'package:my_weather/view_model/weather_view_model.dart';
import 'package:my_weather/views/weather_main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddWeatherView extends StatefulWidget {
  const AddWeatherView({super.key});

  @override
  State<AddWeatherView> createState() => _AddWeatherViewState();
}

class _AddWeatherViewState extends State<AddWeatherView> {
  final TextEditingController _controller = TextEditingController();
  final _weatherService = WeatherService();
  List<String> _savedCities = [];
  Map<String, Weather> _weatherData = {};
  String city = "";
  List<String> _citySuggestions = [];

  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadData();
  }

  Future<void> _loadData() async {
    await _loadCurrentCity();
    await _loadSavedCities();
  }

  Future<void> _loadCurrentCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    city = prefs.getString('currentCity') ?? '';
    if (city.isNotEmpty) {
      Weather currentWeather = await _weatherService.getWeather(city);
      setState(() {
        _weatherData[city] = currentWeather;
      });
    }
  }

  Future<void> _loadSavedCities() async {
    _savedCities = await _weatherService.getSavedCities();
    for (String city in _savedCities) {
      Weather weather = await _weatherService.getWeather(city);
      _weatherData[city] = weather;
    }
    setState(() {});
  }

  Future<void> _getCitySuggestions(String query) async {
    if (query.isNotEmpty) {
      List<String> citySuggestions = await _weatherService.searchCities(query);
      setState(() {
        _citySuggestions = citySuggestions;
      });
    } else {
      setState(() {
        _citySuggestions = [];
      });
    }
  }

  Future<void> _saveCity(String cityName) async {
    try {
      await _weatherService.saveCity(cityName);
      _controller.clear();
      _loadSavedCities();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('City not recognized. Please try another city.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeCity(String cityName) async {
    await _weatherService.removeCity(cityName);
    _loadSavedCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage cities'),
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 51, 123, 216),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  currentLocationWidget(),
                  yourCitiesList(),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 51, 123, 216),
          shape: CircleBorder(),
          onPressed: () => addCitieName(context),
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget currentLocationWidget() {
    if (city.isEmpty || !_weatherData.containsKey(city)) {
      return Container();
    }

    Weather currentWeather = _weatherData[city]!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        transitionDuration: Duration(milliseconds: 500),
        openBuilder: (context, _) {
          return WeatherMainView(
              cities: _savedCities..insert(0, city), initialPage: 0);
        },
        closedBuilder: (context, openContainer) {
          return GestureDetector(
            onTap: openContainer,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.13,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: getContainerColors(currentWeather),
                ),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                title: Row(
                  children: [
                    Text(
                      city,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color.fromARGB(143, 236, 236, 236),
                    )
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${currentWeather.temperature.round()}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentWeather.mainCondition,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget yourCitiesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _savedCities.length + 1, // Incrementamos en 1 el itemCount
      itemBuilder: (context, index) {
        if (index == _savedCities.length) {
          // Añadimos un espacio al final de la lista
          return SizedBox(height: 80); // Ajusta la altura según necesites
        }

        String cityName = _savedCities[index];
        Weather? weather = _weatherData[cityName];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: OpenContainer(
            closedElevation: 0,
            openElevation: 0,
            transitionDuration: Duration(milliseconds: 500),
            openBuilder: (context, _) {
              List<String> citiesToShow = [
                if (city.isNotEmpty) city,
                ..._savedCities
              ];
              int initialPage = citiesToShow.indexOf(cityName);
              return WeatherMainView(
                  cities: citiesToShow, initialPage: initialPage);
            },
            closedBuilder: (context, openContainer) {
              return GestureDetector(
                onTap: openContainer,
                onLongPress: () {
                  _showDeleteDialog(context, cityName);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.13,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: getContainerColors(weather),
                    ),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    title: Text(
                      cityName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: weather != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${weather.temperature.round()}°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                weather.mainCondition,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void addCitieName(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 15,
                                color: const Color.fromARGB(255, 1, 49, 131)),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Add city',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: Color.fromARGB(255, 83, 83, 83)),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 228, 228, 228),
                            width: 1.0),
                      ),
                    ),
                    onChanged: (value) {
                      _getCitySuggestions(value);
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _citySuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_citySuggestions[index]),
                          onTap: () async {
                            await _saveCity(_citySuggestions[index]);
                            _controller.clear();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String cityName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsetsDirectional.only(
              bottom: MediaQuery.of(context).size.width * 0.1,
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Want to Delete $cityName?"),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancelar"),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: 1,
                        color: const Color.fromARGB(255, 177, 177, 177),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _removeCity(cityName);
                          Navigator.of(context).pop();
                        },
                        child: Text("Confirmar"),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
