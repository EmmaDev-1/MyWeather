import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_weather/view_model/weather_view_model.dart';
import 'package:my_weather/views/weather_main_view.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<String>>(
        future: fetchSavedCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Container(
                      width: 200,
                      height: 200,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 40,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 20,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading cities'));
          } else {
            final cities = snapshot.data ?? [];
            return WeatherMainView(cities: cities, initialPage: 0);
          }
        },
      ),
    );
  }
}

Future<List<String>> fetchSavedCities() async {
  final weatherService = WeatherService();
  final savedCities = await weatherService.getSavedCities();
  final currentCity = await weatherService.getCurrentCity();

  if (currentCity.isNotEmpty && !savedCities.contains(currentCity)) {
    savedCities.insert(0, currentCity);
  }

  return savedCities;
}
