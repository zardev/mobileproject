import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/providers/calendar_provider.dart';
import 'package:mon_agenda_partage/ui/calendar/calendar_layout.dart';
import 'package:mon_agenda_partage/ui/event/event_view.dart';
import 'package:mon_agenda_partage/ui/shared/constants.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

import 'day_viewmodel.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDay;

  const DayView (this.selectedDay);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {

  @override
  Widget build(BuildContext context) {

    return ViewModelBuilder<DayViewModel>.reactive(
      onModelReady: (model) => model.initialize(widget.selectedDay),
      builder: (context, model, child) => Scaffold(
        body: CalendarLayout(
          addEvent: () => model.navigateToCreateEvent(widget.selectedDay),
          calendar: Container(
            child: Consumer<CalendarProvider>(
                builder: (context, provider, child)
                {
                  if(!provider.isAppBarSet)
                    Future.delayed(Duration(seconds: 0), () => {
                      provider.setAppBarDateFromSelectedDay(widget.selectedDay)
                    });

                  return Column(
                      children: [
                        DayListHeader(model),
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.only(left: 10),
                              itemCount: 48,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return index.isOdd
                                    ? DayCell(model, index~/2)
                                    : DayDivider();
                              }
                          ),
                        ),
                      ]
                  );
                }
            ),
          ),
        ),
      ),
      viewModelBuilder: () => DayViewModel(),
    );
  }

  Container DayCell(DayViewModel model, int index) {
    return Container(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 50,
              width: 50,
              child: Text("${index}:00")
          ),
          Expanded(
              child: displayEventsByHour(model, index)
          )
        ],
      ),
    );
  }

  Container DayDivider() {
    return Container(
        child: Divider(
          height: 1,
          thickness: 1,
          indent: 50,
        )
    );
  }

  displayEventsByHour(DayViewModel model, int hour) {
    List<Event> eventList = model.getEventListByHour(hour);
    if(eventList.isNotEmpty) {
      return Row(
        children: [
          ...List.generate(eventList.length, (eventIndex) {
            if (eventIndex < MAX_EVENT_DISPLAYED) {
              return Container(
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                  color: colorListByImportance[eventIndex],
                ),
                child: GestureDetector(
                  child: Text(
                      eventList[eventIndex].title
                  ),
                  onTap: () => displayEventInBottomSheet(model, eventList[eventIndex]),
                ),
              );
            } else if (eventIndex == MAX_EVENT_DISPLAYED) {
              return Container(
                width: 75,
                height: 50,
                decoration: BoxDecoration(
                  color: kcMediumGreyColor,
                ),
                child: GestureDetector(
                  child: Text(
                      " +" + (eventList.length - MAX_EVENT_DISPLAYED).toString() + " more..."
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
        ],
      );
    } else {
      return Container();
    }

  }

  Future displayEventInBottomSheet(DayViewModel model, Event event) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(event.title),
              ),
              ListTile(
                leading: Icon(Icons.access_alarm),
                title: Text(event.start_at.toString()),
              ),
              ListTile(
                leading: Icon(Icons.access_alarm),
                title: Text(event.end_at.toString()),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text("Edit Event"),
                        style: ElevatedButton.styleFrom(
                          primary: kcPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    EventView(event: event)
                            ),
                          );
                        },
                      ),
                    ),
                    horizontalSpaceRegular,
                    ElevatedButton(
                      child: Icon(Icons.restore_from_trash),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: () async {
                        await model.deleteEvent(event.id!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  DayView(widget.selectedDay)
                          ),
                        );
                      },

                    ),

                  ],
                ),
              ),
            ],
          );
        });
  }

  Row DayListHeader(DayViewModel model) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 70,
          child: Column(
            children:[
              Text(
                model.getSelectedDayFirstThreeLetters(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: circleBoxDecoration(kcPrimaryColor),
                child: Text(
                  "28",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}