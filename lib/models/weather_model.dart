class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double feelsLikeTemperature;
  final String humidity;
  final String wind;
  final String airPressure;
  final int visibility;
  final String seaLevel;
  final DateTime time;
  final String timezone;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.feelsLikeTemperature,
    required this.humidity,
    required this.wind,
    required this.airPressure,
    required this.visibility,
    required this.seaLevel,
    required this.time,
    required this.timezone,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    int unixTime = json['dt'];
    int timezoneOffset = json['timezone'];
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp']),
      mainCondition: json['weather'][0]['main'],
      feelsLikeTemperature: (json['main']['feels_like']),
      humidity: json['main']['humidity'].toString(),
      wind: json['wind']['speed'].toString(),
      airPressure: json['main']['pressure'].toString(),
      visibility: json['visibility'],
      seaLevel: json['main']['sea_level'] != null
          ? '${json['main']['sea_level'].toString()} m'
          : 'Unknown',
      time: DateTime.fromMillisecondsSinceEpoch(unixTime * 1000, isUtc: true)
          .add(Duration(seconds: timezoneOffset)),
      timezone: json['timezone'].toString(),
    );
  }
}
