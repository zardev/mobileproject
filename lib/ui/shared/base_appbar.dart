import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/ui/calendar/day/day_view.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/home/home_view.dart';
import 'package:mon_agenda_partage/ui/login/login_view.dart';
import 'package:badges/badges.dart';


class BaseAppBar {

  AppBar getBaseAppBar(Widget appTitle, {IconButton? optionalButton, Badge? optionalBadge}) {
    return AppBar(
      leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: Icon(
                    Icons.home,
                    color: Colors.black
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeView()),
                  );
                }
            );
          }),
      title: appTitle,
      actions: [
        if (optionalButton != null) Builder(builder: (BuildContext context) {
          return optionalButton;
        }),
        if (optionalBadge != null) Builder(builder: (BuildContext context) {
          return optionalBadge;
        }),
        Builder(
            builder: (BuildContext context) {
              return PopupMenuButton<int>(
                onSelected: (item) async => _onSelectedCalendar(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Day"),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Month"),
                  )
                ],
                icon: Icon(
                    Icons.calendar_today,
                    color: Colors.black
                ),
              );
            }),
        Builder(
            builder: (BuildContext context)
            {
              return PopupMenuButton<int>(
                onSelected: (item) async => _onSelectedSetting(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(
                        FirebaseAuth.instance.currentUser!.displayName != null ?
                        FirebaseAuth.instance.currentUser!.displayName! :
                        FirebaseAuth.instance.currentUser!.email!
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Sign Out"),
                  )
                ],
                icon: Icon(
                    Icons.settings,
                    color: Colors.black
                ),
              );
            }),
      ],
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
    );
  }

  AppBar getCalendarAppBar(Widget appTitle) {
    return AppBar(
      title: appTitle,
      iconTheme: IconThemeData(color: Colors.black),
        actions: [
        Builder(
            builder: (BuildContext context) {
              return PopupMenuButton<int>(
                onSelected: (item) async => _onSelectedCalendar(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Day"),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Month"),
                  )
                ],
                icon: Icon(
                    Icons.calendar_today,
                    color: Colors.black
                ),
              );
            }),
        Builder(
            builder: (BuildContext context)
            {
              return PopupMenuButton<int>(
                onSelected: (item) async => _onSelectedSetting(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(
                        FirebaseAuth.instance.currentUser!.displayName != null ?
                        FirebaseAuth.instance.currentUser!.displayName! :
                        FirebaseAuth.instance.currentUser!.email!
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Sign Out"),
                  )
                ],
                icon: Icon(
                    Icons.settings,
                    color: Colors.black
                ),
              );
            }),
      ],
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
    );
  }

  _onSelectedCalendar(BuildContext context, int calendarItem) async {
    switch (calendarItem) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DayView(DateTime.now()))
        );
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MonthView())
        );
        break;
    }
  }

  _onSelectedSetting(BuildContext context, int item) async {
    switch (item) {
      case 0:
        break;
      case 1:
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginView(),
          ),
        );
        break;

    }
  }

}
