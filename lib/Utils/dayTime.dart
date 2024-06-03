bool isDayTimeNow(DateTime dateTime) {
  int hour = dateTime.hour;
  return (hour >= 6 && hour < 19);
}
