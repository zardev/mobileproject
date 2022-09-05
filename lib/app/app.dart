import 'package:mon_agenda_partage/services/calendar_service.dart';
import 'package:mon_agenda_partage/services/event_service.dart';
import 'package:mon_agenda_partage/ui/calendar/day/day_view.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/create_account/create_account_view.dart';
import 'package:mon_agenda_partage/ui/event/event_view.dart';
import 'package:mon_agenda_partage/ui/login/login_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(
  routes: [
    CupertinoRoute(page: LoginView, initial: true),
    CupertinoRoute(page: CreateAccountView),
    CupertinoRoute(page: DayView),
    CupertinoRoute(page: MonthView),
    CupertinoRoute(page: EventView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: CalendarService),
    LazySingleton(classType: EventService),
    Singleton(classType: FirebaseAuthenticationService),
  ],
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it **/
}