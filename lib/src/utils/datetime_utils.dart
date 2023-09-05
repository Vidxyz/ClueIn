class DateTimeUtils {

  static int secondsBetweenNowAndEpochTime(int epochTime) {
    return (epochTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  }

  static DateTime calcMinDate(List<DateTime> dates){
    DateTime minDate = dates.first;
    dates.forEach((date){
      if(date.isBefore(minDate)){
        minDate = date;
      }
    });
    return minDate;
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}