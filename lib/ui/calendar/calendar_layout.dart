import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/providers/calendar_provider.dart';
import 'package:mon_agenda_partage/ui/home/home_view.dart';
import 'package:mon_agenda_partage/ui/login/login_view.dart';
import 'package:mon_agenda_partage/ui/shared/base_appbar.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:provider/provider.dart';

import 'day/day_view.dart';
import 'month/month_view.dart';

class CalendarLayout extends StatefulWidget {
  final Widget? calendar;
  final Function()? switchToDay;
  final Function()? switchToWeek;
  final Function()? switchToMonth;
  final Function()? selectDay;
  final Function()? addEvent;
  final Function()? showCalendarOptions;
  final Function()? navigateToSettings;

  CalendarLayout({Key? key, this.calendar, this.switchToDay, this.switchToWeek, this.switchToMonth, this.selectDay, this.addEvent, this.showCalendarOptions, this.navigateToSettings}) : super(key: key);

  @override
  _CalendarLayoutState createState() => _CalendarLayoutState();
}

class _CalendarLayoutState extends State<CalendarLayout> {
  final DateTime dateNow = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarProvider>(
      create: (context) => CalendarProvider(),
      child: Scaffold(
        appBar: BaseAppBar().getCalendarAppBar(
          Consumer<CalendarProvider>(
            builder: (context, provider, child) {
              return Text(
                provider.appBarText,
                style: TextStyle(
                    color: Colors.black
                ),
              );
            },
          ),
        ),
        body: widget.calendar,
        drawer: Drawer(
          child: Consumer<CalendarProvider>(builder: (context, provider, child) {
            return Column(
              children: [
                Flexible(
                  child: ListView(
                    children: [
                      ListTile(
                        title: h2("Mon agenda partagé"),
                        onTap: () {

                        },
                      ),
                      ListTile(
                        title: const Text('Home'),
                        leading: Icon(Icons.home, color: Colors.black),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeView()),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Day'),
                        leading: Icon(Icons.calendar_view_day, color: Colors.black),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DayView(DateTime.now()))
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Month'),
                        leading: Icon(Icons.view_comfortable_outlined, color: Colors.black),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MonthView())
                          );
                        },
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.black54,
                      ),
                      CheckboxListTile(
                        title: const Text('Family'),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: provider.familyChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            provider.familyChecked = value!;
                            provider.toggleFamilyEvents(provider.familyChecked);
                          });
                        },
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.black54,
                      ),
                      if(provider.circleListByUser.length > 0) ListTile(
                        title: const Text('Circles'),
                      ),
                      if(provider.circleListByUser.length > 0) ListView.builder(
                        itemCount: provider.circleListByUser.length,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return CheckboxListTile(
                            title: Text(provider.circleListByUser[index].name!),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: provider.circlesChecked[index],
                            onChanged: (bool? value) {
                              setState(() {
                                provider.circlesChecked[index] = value!;
                                provider.toggleCircleEvents(provider.circleListByUser[index].id!, provider.circlesChecked[index]);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          ),

        ),
        floatingActionButton: createEventButton(),
      ),
    );
  }

  FloatingActionButton createEventButton() => FloatingActionButton(
    onPressed: widget.addEvent,
    child: const Icon(Icons.add),
    backgroundColor: kcPrimaryColor,
  );

  onSelectedCalendar(BuildContext context, int calendarItem) async {
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

  onSelectedSetting(BuildContext context, int item) async {
    switch (item) {
      case 0:
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
