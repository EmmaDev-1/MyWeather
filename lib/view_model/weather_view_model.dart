import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:my_weather/Utils/end_points.dart';
import 'package:my_weather/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$WeatherApi?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    if (city != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentCity', city);
    }

    return city ?? "";
  }

  Future<bool> validateCity(String cityName) async {
    final response = await http
        .get(Uri.parse('$WeatherApi?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> saveCity(String cityName) async {
    if (await validateCity(cityName)) {
      final prefs = await SharedPreferences.getInstance();
      List<String> cities = prefs.getStringList('saved_cities') ?? [];
      if (!cities.contains(cityName)) {
        cities.add(cityName);
        await prefs.setStringList('saved_cities', cities);
      }
    } else {
      throw Exception('City not recognized by the weather API');
    }
  }

  Future<List<String>> getSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_cities') ?? [];
  }

  Future<void> removeCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cities = prefs.getStringList('saved_cities') ?? [];
    cities.remove(cityName);
    await prefs.setStringList('saved_cities', cities);
  }

  Future<List<String>> searchCities(String query) async {
    final response = await http.get(
      Uri.parse('$CityApi$query'),
      headers: {'x-rapidapi-key': cityKey, 'x-rapidapi-host': hostApi},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> cities = data['data'];
      return cities.map((city) => city['city'] as String).toList();
    } else {
      throw Exception('Failed to load city data');
    }
  }
}
