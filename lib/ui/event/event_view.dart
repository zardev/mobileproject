import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'event_viewmodel.dart';

class EventView extends StatefulWidget {
  final DateTime? selectedDay;
  final Event? event;

  const EventView({this.selectedDay, this.event});

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late DateTime startAt = (widget.selectedDay != null
      ? widget.selectedDay
      : widget.event!.start_at)!;
  late DateTime endAt = widget.selectedDay != null
      ? startAt.add(Duration(hours: 1))
      : widget.event!.end_at;
  late bool edit = widget.selectedDay == null;
  final _formKey = GlobalKey<FormState>();
  late final titleController =
  TextEditingController(text: edit ? widget.event!.title : "");

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EventViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: model.navigateBack,
            );
          }),
          title: Text((edit ? "Edit " : "Create ") + "an event"),
          backgroundColor: kcPrimaryColor,
          shadowColor: Colors.white,
        ),
        body: model.isBusy
            ? Align(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ListView(children: [
                verticalSpaceSmall,
                EventTitle(),
                verticalSpaceMedium,
                StartAtRow(model, context),
                verticalSpaceMedium,
                EndAtRow(model, context),
                verticalSpaceSmall,
                // Display error if event start date is superior to end date
                startAt.isAfter(endAt)
                    ? WrongDatesFormat()
                    : verticalSpaceSmall,
                verticalSpaceSmall,
                selectEventGroupType(model),
                verticalSpaceSmall,
                if(model.selectedGroup == "Circle") selectEventGroup(model),
                verticalSpaceSmall,
                EventSubmit(context, model),
              ])),
        ),
      ),
      viewModelBuilder: () => EventViewModel(),
    );
  }

  TextFormField EventTitle() {
    return TextFormField(
      decoration: InputDecoration(border: null, labelText: "Title"),
      controller: titleController,
      validator: (title) {
        if (title == null || title.isEmpty) {
          return 'Title should not be empty';
        }
        return null;
      },
    );
  }

  Row StartAtRow(EventViewModel model, BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_alarm),
        SizedBox(width: 10),
        Container(
          child: GestureDetector(
            child: Text(
                model.getSelectedDayFirstThreeLetters(startAt) +
                    ". " +
                    startAt.day.toString() +
                    " " +
                    model.getMonthName(startAt) +
                    " " +
                    startAt.year.toString(),
                style: TextStyle(fontSize: 16)),
            onTap: () => showDatePicker(
                context: context,
                initialDate: startAt,
                firstDate: DateTime(2001),
                lastDate: DateTime(2038))
                .then((date) {
              setState(() {
                startAt = date!.add(Duration(hours: startAt.hour));
              });
            }),
          ),
        ),
        Spacer(),
        Container(
          child: GestureDetector(
            child: Text(startAt.hour.toString() + ":00",
                style: TextStyle(fontSize: 16)),
            onTap: () => showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: startAt.hour, minute: endAt.minute),
            ).then((date) {
              setState(() {
                startAt = DateTime(startAt.year, startAt.month, startAt.day,
                    date!.hour, date.minute);
              });
            }),
          ),
        ),
      ],
    );
  }

  Row EndAtRow(EventViewModel model, BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 35),
        Container(
          child: GestureDetector(
            child: Text(
                model.getSelectedDayFirstThreeLetters(endAt) +
                    ". " +
                    endAt.day.toString() +
                    " " +
                    model.getMonthName(endAt) +
                    " " +
                    endAt.year.toString(),
                style: TextStyle(fontSize: 16)),
            onTap: () => showDatePicker(
                context: context,
                initialDate: endAt,
                firstDate: DateTime(2001),
                lastDate: DateTime(2038))
                .then((date) {
              setState(() {
                endAt = date!.add(Duration(hours: endAt.hour));
              });
            }),
          ),
        ),
        Spacer(),
        Container(
          child: GestureDetector(
            child: Text((endAt.hour).toString() + ":00",
                style: TextStyle(fontSize: 16)),
            onTap: () => showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: endAt.hour, minute: endAt.minute),
            ).then((date) {
              setState(() {
                endAt = DateTime(endAt.year, endAt.month, endAt.day, date!.hour,
                    date.minute);
              });
            }),
          ),
        ),
      ],
    );
  }

  Container selectEventGroupType(EventViewModel model) {
    return Container(
      child: DropdownButton<String>(
        value: model.selectedGroup,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        isExpanded: true,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 1,
          color: Colors.black54,
        ),
        onChanged: (String? group) {
          setState(() {
            model.selectedGroup = group!;
            switch (model.selectedGroup) {
              case "Select a group...":
                model.selectNothing();
                break;
              case "Family":
                model.selectFamily();
                break;
              case "Circle":
                model.selectCircle();
                break;
            }
          });
        },
        items: model.eventTypes
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Container selectEventGroup(EventViewModel model) {
    return Container(
      child: DropdownButton<Circle>(
        value: model.selectedCircle,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        isExpanded: true,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 1,
          color: Colors.black54,
        ),
        onChanged: (Circle? circle) {
          setState(() {
            model.selectedCircle = circle;
            model.selectedGroupId = circle!.id!;
          });
        },
        items: model.circleListByUser
            .map<DropdownMenuItem<Circle>>((Circle circle) {
          return DropdownMenuItem<Circle>(
            value: circle,
            child: Text(circle.name!),
          );
        }).toList(),
      ),
    );
  }

  ElevatedButton EventSubmit(BuildContext context, EventViewModel model) {
    return ElevatedButton(
        onPressed: startAt.isAfter(endAt)
            ? null
            : () async {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(children: [
                  Text(edit ? "Editing event" : "Creating event"),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                      new AlwaysStoppedAnimation<Color>(kcPrimaryColor),
                      strokeWidth: 3.0,
                    ),
                  ),
                ])));
            edit
                ? await model.updateEvent(
                Event.add(
                    id: widget.event!.id,
                    title: this.titleController.text,
                    start_at: this.startAt,
                    end_at: this.endAt))
                .then((value) {
            })
                : await model.addEvent(Event.add(
                title: this.titleController.text,
                group: model.selectedGroup != "Select a group..." ? model.selectedGroup : "",
                groupId: model.selectedGroupId,
                start_at: this.startAt,
                end_at: this.endAt))
                .then((value) {
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      MonthView()
              ),
            );
          }
        },
        child: Text(edit ? "Edit event" : "Create event"),
        style: ElevatedButton.styleFrom(primary: kcPrimaryColor));
  }

  Row WrongDatesFormat() {
    return Row(
      children: [
        Icon(
          Icons.not_interested,
          color: Colors.amber,
        ),
        SizedBox(width: 10),
        Text(
          "Start date must be before the end",
          style: TextStyle(color: Colors.amber),
        )
      ],
    );
  }
}
