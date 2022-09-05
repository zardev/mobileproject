import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/providers/calendar_provider.dart';
import 'package:mon_agenda_partage/ui/calendar/calendar_layout.dart';
import 'package:mon_agenda_partage/ui/event/event_view.dart';
import 'package:mon_agenda_partage/ui/shared/constants.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:provider/provider.dart';

import 'month_viewmodel.dart';

class MonthView extends StatefulWidget {

  MonthView({Key? key}) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  final PageController controller = PageController(initialPage: 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CalendarLayout(
          addEvent: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventView(selectedDay: DateTime.now()))),
          calendar: Container(
            child: Consumer<CalendarProvider>(builder: (context, provider, child) {
              return PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  onPageChanged: (pageIndex) {
                    provider.setAppBarDateFromSelectedMonth(pageIndex - 1000);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final pageIndex = index - 1000;
                    return Column(children: [
                      MonthCalendarTableHeader(),
                      MonthCalendarTableBody(pageIndex, provider)
                    ]);
                  });
            }),
          ),
        ));
  }
}

class MonthCalendarTableHeader extends StatelessWidget {
  final String weekLetters;

  const MonthCalendarTableHeader({
    Key? key,
    this.weekLetters = "LMMJVSD",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: GridView.count(
        crossAxisCount: DAYS_IN_WEEK,
        children: List.generate(DAYS_IN_WEEK, (index) {
          return Container(
            child: Center(
              child: Text(
                weekLetters[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MonthCalendarTableBody extends StatefulWidget {
  final int pageIndex;
  final CalendarProvider provider;

  const MonthCalendarTableBody(this.pageIndex, this.provider);

  @override
  _MonthCalendarTableBodyState createState() => _MonthCalendarTableBodyState();
}

class _MonthCalendarTableBodyState extends State<MonthCalendarTableBody> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MonthViewModel>.reactive(
      onModelReady: (model) => widget.provider.fillCalendarList(widget.pageIndex),
      builder: (context, model, child) => widget.provider.isBusy
          ? Align(child: CircularProgressIndicator())
          : Expanded(
        child: GridView.count(
          crossAxisCount: DAYS_IN_WEEK,
          childAspectRatio: MediaQuery.of(context).size.height / 1399,
          children: List.generate(DAYS_IN_MONTH_CALENDAR, (dayIndex) {
            return GestureDetector(
              child: Container(
                decoration: DayBoxDecoration(widget.provider, dayIndex),
                child: Column(children: [
                  DayNumber(widget.provider, dayIndex),
                  ...displayEventListByDay(widget.provider, dayIndex),
                ]),
              ),
              onTap: () => widget.provider.navigateToDay(dayIndex),
            );
          }),
        ),
      ),
      viewModelBuilder: () => MonthViewModel(),
    );
  }

  List<Widget> displayEventListByDay(CalendarProvider provider, int dayIndex) {
    List<Event> eventListByDay = provider.eventListByDaysWithFilters[dayIndex];
    return List.generate(eventListByDay.length, (eventIndex) {
      if (eventIndex < 3) {
        return Container(
          width: double.infinity,
          decoration:
          new BoxDecoration(color: colorListByImportance[eventIndex]),
          child: Text(
            eventListByDay[eventIndex].title,
            style: TextStyle(
              fontSize: 8,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      } else if (eventIndex == MAX_EVENT_DISPLAYED) {
        return Container(
          width: double.infinity,
          decoration: new BoxDecoration(color: kcMediumGreyColor),
          child: Text(
            "+ " +
                (eventListByDay.length - MAX_EVENT_DISPLAYED).toString() +
                " more...",
            style: TextStyle(
              fontSize: 8,
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }

  BoxDecoration DayBoxDecoration(CalendarProvider provider, int index) {
    if (provider.isToday(index) && !provider.dayInPreviousOrNextMonth(index)) {
      return BoxDecoration(
        color: kcPrimaryColor.withOpacity(0.2),
        border: Border.all(
          color: Colors.grey,
          width: 0.3,
        ),
      );
    } else {
      return BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 0.3,
        ),
      );
    }
  }

  Container DayNumber(CalendarProvider provider, int index) {
    if (provider.isToday(index) && !provider.dayInPreviousOrNextMonth(index)) {
      return Container(
        padding: EdgeInsets.all(2),
        decoration: circleBoxDecoration(kcPrimaryColor.withOpacity(0.8)),
        child: Text(
          provider.monthsList[index].day.toString(),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(2),
        child: Text(provider.monthsList[index].day.toString(),
            style: TextStyle(
              color: provider.dayInPreviousOrNextMonth(index)
                  ? Colors.grey
                  : Colors.black,
            )),
      );
    }
  }
}
