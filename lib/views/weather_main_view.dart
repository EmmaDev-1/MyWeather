import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:my_weather/Utils/chage_background_colors.dart';
import 'package:my_weather/Utils/chage_weather_animation.dart';
import 'package:my_weather/Utils/navegation_animations/slide_animation.dart';
import 'package:my_weather/Utils/utils.dart';
import 'package:my_weather/models/weather_model.dart';
import 'package:my_weather/view_model/weather_view_model.dart';
import 'package:my_weather/views/add_weather_view.dart';
import 'package:shimmer/shimmer.dart';

class WeatherMainView extends StatefulWidget {
  final List<String> cities;
  final int initialPage;
  final String? currentCity;

  const WeatherMainView({
    super.key,
    required this.cities,
    this.initialPage = 0,
    this.currentCity,
  });

  @override
  State<WeatherMainView> createState() => _WeatherMainViewState();
}

class _WeatherMainViewState extends State<WeatherMainView> {
  final _weatherService = WeatherService();
  Weather? _weather;
  late PageController _pageController;
  late List<String> _displayCities;
  ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _currentPageNotifier.value = widget.initialPage;
    _displayCities = List.from(widget.cities);

    if (widget.currentCity != null &&
        !_displayCities.contains(widget.currentCity)) {
      _displayCities.insert(0, widget.currentCity!);
    }

    _fetchWeather(_displayCities[widget.initialPage]);
  }

  Future<void> _fetchWeather(String cityName) async {
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: getContainerColors(_weather),
          ),
        ),
        child: LiquidPullToRefresh(
          onRefresh: () async =>
              _fetchWeather(_displayCities[_pageController.page?.toInt() ?? 0]),
          color: getRefreshColor(_weather),
          height: 300,
          animSpeedFactor: 2,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _currentPageNotifier.value = index;
              _fetchWeather(_displayCities[index]);
            },
            itemCount: _displayCities.length,
            itemBuilder: (context, index) {
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        mainContent(),
                        featuresContent(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget mainContent() {
    if (_weather == null) {
      return Shimmer.fromColors(
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
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    _weather?.cityName ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.03,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    crearRuta(context, const AddWeatherView()),
                  );
                },
                child: Image.asset(
                  'assets/Icons/addWeather.png',
                  scale: 20,
                ),
              )
            ],
          ),
          pageIndicators(),
          Lottie.asset(getWeatherAnimation(_weather!), width: 200),
          Text(
            '${_weather!.temperature.round()}°C',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.06,
                color: Colors.white),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _weather?.mainCondition ?? "",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    color: Colors.white,
                  ),
                ),
                const TextSpan(
                  text: "   ",
                ),
                TextSpan(
                  text: formatUnixTime(_weather!.time),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget pageIndicators() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _displayCities.map((city) {
            int index = _displayCities.indexOf(city);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget featuresContent() {
    if (_weather == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shimmerBox(),
                  shimmerBox(),
                  shimmerBox(),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shimmerBox(),
                  shimmerBox(),
                  shimmerBox(),
                ],
              ),
            ],
          ),
        ),
      );
    }

    var visibility = _weather!.visibility / 1000;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              infoBox(
                icon: Icons.thermostat_rounded,
                label: 'Feels like',
                value: '${_weather!.feelsLikeTemperature.round()}°C',
              ),
              infoBox(
                icon: Icons.play_for_work_rounded,
                label: 'Air pressure',
                value: "${_weather?.airPressure} hPa",
              ),
              infoBox(
                icon: Icons.air_rounded,
                label: 'Wind speed',
                value: "${_weather?.wind} km/h",
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              infoBox(
                icon: Icons.water_drop_rounded,
                label: 'Humidity',
                value: "${_weather?.humidity}%",
              ),
              infoBox(
                icon: Icons.visibility_rounded,
                label: 'Visibility',
                value: "$visibility mi",
              ),
              infoBox(
                icon: Icons.waves_rounded,
                label: 'Sea level',
                value: "${_weather?.seaLevel}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget shimmerBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }

  Widget infoBox(
      {required IconData icon, required String label, required String value}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        color: Color.fromARGB(96, 30, 91, 161),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.016,
              color: Color.fromARGB(120, 255, 255, 255),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
