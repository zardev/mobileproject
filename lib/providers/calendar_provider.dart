import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon_agenda_partage/app/app.locator.dart';
import 'package:mon_agenda_partage/app/app.router.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:mon_agenda_partage/services/calendar_service.dart';
import 'package:mon_agenda_partage/services/circle_service.dart';
import 'package:mon_agenda_partage/services/event_service.dart';
import 'package:mon_agenda_partage/services/user_service.dart';
import 'package:mon_agenda_partage/ui/shared/constants.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';

class CalendarProvider extends ChangeNotifier {

  final logger = Logger(
    filter: null,
    printer: PrettyPrinter(
        methodCount: 0
    ),
    output: null,
  );

  AppUser.User? currentUser;
  bool _isAppBarSet = false;
  bool familyChecked = true;
  bool isBusy = true;
  List<bool> circlesChecked = [];
  String _appBarText = DateFormat.yMMMMd().format(DateTime.now());
  CalendarService _calendarService = new CalendarService();
  CircleService _circleService = new CircleService();
  final _userService = UserService();
  final calendarService = locator<CalendarService>();
  final navigationService = locator<NavigationService>();
  final eventService = locator<EventService>();

  List<Circle> _circles = [];
  List<Circle> circleListByUser = [];
  List<CircleUser> _circleUsers = [];
  List<DateTime> monthsList = [];
  List<Event> events = [];
  List<Event> eventsByUser = [];
  List<List<Event>> eventListByDays = List.filled(DAYS_IN_MONTH_CALENDAR, []);
  List<List<Event>> eventListByDaysWithFilters = List.filled(DAYS_IN_MONTH_CALENDAR, []);
  final FirebaseAuth auth = FirebaseAuth.instance;

  void navigateToCreateEvent(DateTime selectedDay) =>
      navigationService.navigateTo(
          Routes.eventView,
          arguments: EventViewArguments(selectedDay: selectedDay)
      );

  void fillCalendarList(int pageIndex) async {
    currentUser = await _userService.getOneById(auth.currentUser!.uid);
    monthsList = calendarService.fillMonthsList(pageIndex);
    _circles = await _circleService.getAll();
    _circleUsers = await _circleService.getAllCircleUsers();
    _getCircleList();
    await getEventList();
    isBusy = false;
    notifyListeners();
  }


  void _getCircleList() {
    circleListByUser = [];

    if(_circleUsers.isNotEmpty && _circles.isNotEmpty) {
      _circleUsers.forEach((circleUser) {
        Circle? circle = null;
        circle = _circles.firstWhereOrNull(
                (agenda) => agenda.id == circleUser.circleId
                && currentUser!.id == circleUser.userId);
        if (circle != null) circleListByUser.add(circle);
      });
    } else {
      logger.i("No circles are available in the app");
      return;
    }

    if (circleListByUser.isNotEmpty) {
      logger.v(circleListByUser);
      circlesChecked = List.filled(circleListByUser.length, true);
    } else {
      logger.i("No circle found !");
    }
  }

  bool isToday(int index) {
    if(monthsList[index].day == DateTime.now().day
        && monthsList[index].month == DateTime.now().month
        && monthsList[index].year == DateTime.now().year)
      return true;
    return false;
  }

  bool dayInPreviousOrNextMonth(int index) {
    if(monthsList[index].day > 22 && index < 6 || monthsList[index].day < 15 && index > 27)
      return true;
    return false;
  }

  void navigateToDay(int index) =>
      navigationService.navigateTo(Routes.dayView, arguments: DayViewArguments(selectedDay: monthsList[index]));

  // Get all events then get events by user and finally it puts those events in the calendar
  // The eventListByDaysWithFilters allow event filtering when checkbox is toggled
  Future<void> getEventList() async {
    final User user = auth.currentUser!;
    final userId = user.uid;

    events = await eventService.getAll();
    getEventsByUser();

    for(int i = 0 ; i < DAYS_IN_MONTH_CALENDAR ; i++) {
      eventListByDays[i] = getAllBySelectedDay(monthsList[i]);
      eventListByDaysWithFilters[i] = getAllBySelectedDay(monthsList[i]);
    }

    notifyListeners();
  }

  void getEventsByUser() {
    events.forEach((event) {
      bool addEvent = false;
      circleListByUser.forEach((circle) {
        if(event.groupId == circle.id &&
            event.groupId != "" ||
            event.groupId == currentUser!.familyId &&
                event.groupId != "") addEvent = true;
      });
      if( event.userId == currentUser!.id) addEvent = true;
      if(addEvent) eventsByUser.add(event);
    });
  }

  List<Event> getAllBySelectedDay(DateTime selectedDay) {
    List<Event> eventsBySelectedDay = [];

    eventsByUser.forEach((event) {
      // This loop check all events by User and check the range of date of the event
      // if one condition is true, it will add the event for the day of the calendar
      if (isSingleDayEvent(event, selectedDay) ||
          isBetweenStartAndEnd(event, selectedDay) ||
          isEventOnLastDay(event, selectedDay)) {
        eventsBySelectedDay.add(event);
      }
    });

    return eventsBySelectedDay;
  }

  bool isSingleDayEvent(Event event, DateTime selectedDay) {
    final firstHourForSelectedDay =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0);
    final lastHourForSelectedDay =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day + 1, 0);

    return event.start_at.isAfter(firstHourForSelectedDay) &&
        event.start_at.isBefore(lastHourForSelectedDay) &&
        event.start_at.day == selectedDay.day;
  }

  bool isBetweenStartAndEnd(Event event, DateTime selectedDay) {

    return event.start_at.day < selectedDay.day &&
        event.end_at.day > selectedDay.day &&
        event.start_at.month <= selectedDay.month &&
        event.end_at.month >= selectedDay.month &&
        event.start_at.year <= selectedDay.year &&
        event.end_at.year >= selectedDay.year;
  }

  bool isEventOnLastDay(Event event, DateTime selectedDay) {

    final firstHourForSelectedDay =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0);
    final lastHourForSelectedDay =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day + 1, 0);

    return event.end_at.isAfter(firstHourForSelectedDay) &&
        event.end_at.isBefore(lastHourForSelectedDay) &&
        event.end_at.day == selectedDay.day;
  }

  void toggleFamilyEvents(bool isShown) {
    isShown ? addFamilyEvents() : removeFamilyEvents();
    notifyListeners();
  }

  void addFamilyEvents() {
    eventListByDays.forEachIndexed((index, eventByDay) {
      eventByDay.forEach((event) {
        if(event.group == "Family") eventListByDaysWithFilters[index].add(event);
      });
    });
  }

  void removeFamilyEvents() {
    for(int i = 0 ; i < eventListByDaysWithFilters.length ; i++) {
      eventListByDaysWithFilters[i].removeWhere((event) => event.group == "Family");
    }
  }

  void toggleCircleEvents(String circleId, bool isShown) {
    isShown ? addCircleEvents(circleId) : removeCircleEvents(circleId);
    notifyListeners();
  }

  void addCircleEvents(String circleId) {
    eventListByDays.forEachIndexed((index, eventByDay) {
      eventByDay.forEach((event) {
        logger.i(event.toJson());
        if(event.group == "Circle" && event.groupId == circleId) eventListByDaysWithFilters[index].add(event);
      });
    });
  }

  void removeCircleEvents(String circleId) {
    for(int i = 0 ; i < eventListByDaysWithFilters.length ; i++) {
      eventListByDaysWithFilters[i].removeWhere((event) => event.group == "Circle" && event.groupId == circleId);
    }
  }

  void setAppBarDateFromSelectedDay(DateTime selectedDay){
    _appBarText = DateFormat.yMMMMd().format(selectedDay);
    _isAppBarSet = true;
    notifyListeners();
  }

  void setAppBarDateFromSelectedMonth(int pageIndex){
    DateTime currentDayByPageIndex = _calendarService.getMonthByPageIndex(pageIndex);
    _appBarText = DateFormat.yMMMM().format(currentDayByPageIndex);
    notifyListeners();
  }

  String get appBarText => _appBarText;
  bool get isAppBarSet => _isAppBarSet;
}