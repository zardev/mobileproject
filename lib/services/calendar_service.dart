import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mon_agenda_partage/ui/shared/constants.dart';

class CalendarService {
  final logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(
      methodCount: 0
    ), // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  DateTime dateNow = DateTime.now();

  List<DateTime> fillMonthsList(int pageIndex) {
    List<DateTime> monthsList = [];
    DateTime dateByIndex = getMonthByPageIndex(pageIndex);
    int month = dateByIndex.month;
    int year = dateByIndex.year;
    int indexOfFirstDayOfMonth = getIndexOfFirstDayOfMonth(dateByIndex, month, year);
    DateTime firstDayOfCalendar = getFirstDayOfCalendar(dateByIndex, indexOfFirstDayOfMonth, month, year);

    monthsList = getMonthsList(firstDayOfCalendar);

    return monthsList;
  }

  DateTime getMonthByPageIndex(int pageIndex) {
    DateTime _dateNow = DateTime.now();
    DateTime currentDayByPageIndex = DateTime(_dateNow.year, _dateNow.month + pageIndex, 15);
    logger.v('Current Month By Page Index : $currentDayByPageIndex');
    return currentDayByPageIndex;
  }

  int getIndexOfFirstDayOfMonth(DateTime dateByIndex, int month, int year) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int indexOfFirstDayOfMonth = firstDayOfMonth.weekday;
    logger.v('Index Of First Day Of Month : $firstDayOfMonth');
    return indexOfFirstDayOfMonth;
  }

  DateTime getFirstDayOfCalendar(DateTime dateByIndex, int indexOfFirstDayOfMonth, int month, int year) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime firstDayOfCalendar = firstDayOfMonth.subtract(Duration(days: indexOfFirstDayOfMonth - 1));
    logger.v('First Day Of Calendar $firstDayOfCalendar');
    return firstDayOfCalendar;
  }

  List<DateTime> getMonthsList(DateTime firstDayOfCalendar) {
    List<DateTime> monthsList = [];
    DateTime dateByIndex;
    for(int i = 0 ; i < DAYS_IN_MONTH_CALENDAR ; i++) {
      dateByIndex = new DateTime(firstDayOfCalendar.year, firstDayOfCalendar.month, firstDayOfCalendar.day + i);
      monthsList.add(dateByIndex);
    }

    return monthsList;
  }

  String getSelectedDayFirstThreeLetters(DateTime selectedDay) {
    return DateFormat.E().format(selectedDay);
  }

  String getMonthName(DateTime selectedDay) {
    return DateFormat.LLLL().format(selectedDay);
  }
}