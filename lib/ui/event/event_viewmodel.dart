import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:mon_agenda_partage/services/calendar_service.dart';
import 'package:mon_agenda_partage/services/circle_service.dart';
import 'package:mon_agenda_partage/services/event_service.dart';
import 'package:mon_agenda_partage/services/family_service.dart';
import 'package:mon_agenda_partage/services/user_service.dart';

import 'package:logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';



class EventViewModel extends FormViewModel {
  final _navigationService = NavigationService();
  final _calendarService = CalendarService();
  final _eventService = EventService();
  final _circleService = CircleService();
  final _familyService = FamilyService();
  final _userService = UserService();

  FirebaseAuth auth = FirebaseAuth.instance;

  AppUser.User? currentUser;
  String selectedGroup = "Select a group...";
  String selectedGroupId = "";
  Circle? selectedCircle = null;
  List<Circle> _circles = [];
  List<Circle> circleListByUser = [];
  List<CircleUser> _circleUsers = [];
  List<String> eventTypes = ["Select a group..."];
  bool isBusy = true;

  final logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(
        methodCount: 0
    ), // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  EventViewModel() : super();

  Future<void> initialize() async {
    currentUser = await _userService.getOneById(auth.currentUser!.uid);
    if(currentUser!.familyId != "") eventTypes.add("Family");
    _circles = await _circleService.getAll();
    _circleUsers = await _circleService.getAllCircleUsers();
    getCirclesForUser();
    isBusy = false;
    this.notifyListeners();
  }

  void navigateBack() => _navigationService.back();

  List<String> groupIdList = [];

  @override
  void setFormStatus() {}

  String getSelectedDayFirstThreeLetters(DateTime selectedDay) {
    return _calendarService.getSelectedDayFirstThreeLetters(selectedDay);
  }

  String getMonthName(DateTime selectedDay) {
    return _calendarService.getMonthName(selectedDay);
  }

  Future<void> addEvent(Event event) async {
    event.userId = currentUser!.id;
    logger.v("Created event : " + event.toJson().toString());
    _eventService.create(event);

    return Future.delayed(Duration(milliseconds: 2000));
  }

  Future<void> updateEvent(Event event) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    event.userId = auth.currentUser!.uid;
    _eventService.update(event);

    return Future.delayed(Duration(milliseconds: 2000));
  }

  void getCirclesForUser() {
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
      eventTypes.add("Circle");
      selectedCircle = circleListByUser[0];
    } else {
      logger.i("No circle found !");
    }

  }

  void selectNothing() {
    selectedGroupId = "";
  }

  void selectFamily() {
    selectedGroupId = currentUser!.id;
  }

  void selectCircle() {
    selectedGroupId = selectedCircle!.id!;
  }

}