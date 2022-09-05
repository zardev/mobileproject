import 'package:mon_agenda_partage/app/app.locator.dart';
import 'package:mon_agenda_partage/app/app.router.dart';
import 'package:mon_agenda_partage/services/calendar_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

abstract class CalendarViewModel extends BaseViewModel {

  final calendarService = locator<CalendarService>();
  final navigationService = locator<NavigationService>();

  int test = 0;

  void fillCalendarList(int pageIndex);

  void navigateToCreateEvent(DateTime selectedDay) =>
      navigationService.navigateTo(
          Routes.eventView,
          arguments: EventViewArguments(selectedDay: selectedDay)
      );

}