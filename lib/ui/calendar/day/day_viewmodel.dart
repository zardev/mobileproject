import 'package:firebase_auth/firebase_auth.dart';
import 'package:mon_agenda_partage/app/app.locator.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/services/event_service.dart';
import 'package:mon_agenda_partage/ui/calendar/calendar_viewmodel.dart';

class DayViewModel extends CalendarViewModel {

  final eventService = locator<EventService>();
  DateTime selectedDay = DateTime.now();
  List<Event> eventList = [];
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void fillCalendarList(int pageIndex) {

  }

  void initialize(DateTime selectedDay) {
    setSelectedDay(selectedDay);
    getEventList();
  }

  void setSelectedDay(DateTime selectedDay) {
    this.selectedDay = selectedDay;
  }

  Future<void> getEventList() async {
    final User user = auth.currentUser!;
    final userId = user.uid;
    this.eventList = await eventService.getAllBySelectedDayAndUserId(this.selectedDay, userId);
    notifyListeners();
  }

  // For every hours of a day, display events that are in it
  List<Event> getEventListByHour(int hour) {
    List<Event> _eventListByHour = [];
    DateTime selectedDayWithHour = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, hour);

    this.eventList.forEach((event) {
      if(isEventOnFirstDay(selectedDayWithHour, event) // Occurs on a single/multiple day event at first day
          // Occurs on a multiple day event between first day and last day
          || isEventBetweenFirstAndLastDay(selectedDayWithHour, event)
          // Occurs on a multiple day event at last day
          || isEventOnLastDay(selectedDayWithHour, event)) {
        _eventListByHour.add(event);
      }
    });

    return _eventListByHour;
  }

  bool isEventOnFirstDay(DateTime selectedDayWithHour, Event event) {
    if((
        selectedDayWithHour.hour >= event.start_at.hour
            && selectedDayWithHour.hour < event.end_at.hour
            && event.start_at.day == selectedDay.day
            && event.end_at.day == selectedDay.day)
        || selectedDayWithHour.hour >= event.start_at.hour
            && event.start_at.day == selectedDay.day
            && event.end_at.day > selectedDay.day)
      return true;
    return false;

  }

  bool isEventBetweenFirstAndLastDay(DateTime selectedDayWithHour, Event event) {
    if (event.end_at.day > selectedDay.day
        && event.start_at.day < selectedDay.day)
      return true;
    return false;
  }

  bool isEventOnLastDay(DateTime selectedDayWithHour, Event event) {
    if(selectedDayWithHour.isBefore(event.end_at)
        && event.start_at.day < selectedDay.day
        && event.end_at.day == selectedDay.day)
      return true;
    return false;
  }

  String getSelectedDayFirstThreeLetters() {
    return calendarService.getSelectedDayFirstThreeLetters(selectedDay);
  }

  Future<void> deleteEvent(String id) async {
    await eventService.delete(id);
    this.notifyListeners();
  }
}