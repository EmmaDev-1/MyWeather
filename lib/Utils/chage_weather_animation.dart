import 'package:my_weather/Utils/dayTime.dart';
import 'package:my_weather/models/weather_model.dart';

String getWeatherAnimation(Weather weather) {
  String baseAnimation = 'assets/animations/';

  bool isDayTime = isDayTimeNow(weather.time);

  switch (weather.mainCondition) {
    case 'Thunderstorm':
      return '${baseAnimation}cloud&thunder.json';
    case 'Drizzle':
      return isDayTime
          ? '${baseAnimation}cloud&sun&rain.json'
          : '${baseAnimation}cloud&moon&rain.json';
    case 'Rain':
      return '${baseAnimation}cloud&thunder&rain.json';
    case 'Snow':
      return '${baseAnimation}cloud&snow.json';
    case 'Clear':
      return isDayTime
          ? '${baseAnimation}sun.json'
          : '${baseAnimation}moon.json';
    case 'Clouds':
    case 'Mist':
    case 'Smoke':
    case 'Dust':
    case 'Fog':
      return isDayTime
          ? '${baseAnimation}cloud&sun.json'
          : '${baseAnimation}cloud&moon.json';
    default:
      return isDayTime
          ? '${baseAnimation}sun.json'
          : '${baseAnimation}moon.json';
  }
}
