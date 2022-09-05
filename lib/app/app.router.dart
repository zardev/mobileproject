// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:mon_agenda_partage/models/Event.dart';
import '../ui/calendar/day/day_view.dart';
import '../ui/calendar/month/month_view.dart';
import '../ui/create_account/create_account_view.dart';
import '../ui/event/event_view.dart';
import '../ui/login/login_view.dart';

class Routes {
  static const String loginView = '/';
  static const String createAccountView = '/create-account-view';
  static const String dayView = '/day-view';
  static const String monthView = '/month-view';
  static const String eventView = '/event-view';
  static const all = <String>{
    loginView,
    createAccountView,
    dayView,
    monthView,
    eventView,
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.loginView, page: LoginView),
    RouteDef(Routes.createAccountView, page: CreateAccountView),
    RouteDef(Routes.dayView, page: DayView),
    RouteDef(Routes.monthView, page: MonthView),
    RouteDef(Routes.eventView, page: EventView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    LoginView: (data) {
      return CupertinoPageRoute<dynamic>(
        builder: (context) => LoginView(),
        settings: data,
      );
    },
    CreateAccountView: (data) {
      return CupertinoPageRoute<dynamic>(
        builder: (context) => CreateAccountView(),
        settings: data,
      );
    },
    DayView: (data) {
      var args = data.getArgs<DayViewArguments>(nullOk: false);
      return CupertinoPageRoute<dynamic>(
        builder: (context) => DayView(args.selectedDay),
        settings: data,
      );
    },
    MonthView: (data) {
      var args = data.getArgs<MonthViewArguments>(
        orElse: () => MonthViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => MonthView(key: args.key),
        settings: data,
      );
    },
    EventView: (data) {
      var args = data.getArgs<EventViewArguments>(
        orElse: () => EventViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => EventView(
          selectedDay: args.selectedDay,
          event: args.event,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// DayView arguments holder class
class DayViewArguments {
  final DateTime selectedDay;
  DayViewArguments({required this.selectedDay});
}

/// MonthView arguments holder class
class MonthViewArguments {
  final Key? key;
  MonthViewArguments({this.key});
}

/// EventView arguments holder class
class EventViewArguments {
  final DateTime? selectedDay;
  final Event? event;
  EventViewArguments({this.selectedDay, this.event});
}
