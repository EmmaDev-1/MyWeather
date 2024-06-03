import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_weather/Utils/dayTime.dart';
import 'package:my_weather/models/weather_model.dart';

List<Color> getContainerColors(Weather? weather) {
  if (weather == null) {
    return [
      Colors.white,
      Colors.white,
    ];
  }

  bool isDayTime = isDayTimeNow(weather.time);

  switch (weather.mainCondition) {
    case 'Clear':
      return isDayTime
          ? [
              Color.fromARGB(255, 0, 119, 255),
              Color.fromARGB(255, 98, 166, 255)
            ]
          : [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 36, 36, 36),
            ];
    case 'Rain':
    case 'Drizzle':
    case 'Thunderstorm':
      return [
        Color.fromARGB(255, 55, 52, 66),
        Color.fromARGB(255, 113, 110, 134),
      ];
    default:
      return isDayTime
          ? [
              Color.fromARGB(255, 0, 119, 255),
              Color.fromARGB(255, 98, 166, 255)
            ]
          : [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 36, 36, 36),
            ];
  }
}

Color getRefreshColor(Weather? weather) {
  if (weather == null) {
    return Colors.white;
  }

  bool isDayTime = isDayTimeNow(weather.time);

  switch (weather.mainCondition) {
    case 'Clear':
      return isDayTime
          ? Color.fromARGB(255, 0, 119, 255)
          : Color.fromARGB(255, 0, 0, 0);
    case 'Rain':
    case 'Drizzle':
    case 'Thunderstorm':
      return Color.fromARGB(255, 55, 52, 66);
    default:
      return isDayTime
          ? Color.fromARGB(255, 0, 119, 255)
          : Color.fromARGB(255, 0, 0, 0);
  }
}
