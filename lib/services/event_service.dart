import 'dart:convert';

import 'package:mon_agenda_partage/api/event_api.dart';
import 'package:mon_agenda_partage/api/event_participation_api.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/models/EventParticipation.dart';
import 'package:mon_agenda_partage/services/crud_service.dart';

class EventService {
  final EventApi _eventApi = new EventApi();
  final EventParticipationApi _eventParticipationApi =
      new EventParticipationApi();

  Future<List<Event>> getAll() async {
    return await _eventApi.getAllEvents();
  }

  Future<List<Event>> getAllBySelectedDayAndUserId(
      DateTime selectedDay, String userId) async {
    var firstHourForSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0);
    var lastHourForSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day + 1, 0);
    List<Event> events = await _eventApi.getEventsByUser(userId);
    List<Event> eventsBySelectedDay = [];

    await Future.forEach<Event>(events, (event) async {
      // First line check if an event is occuring on selectedDay at start
      // Second line is if the event last for multiple days
      if (event.start_at.isAfter(firstHourForSelectedDay) &&
              event.start_at.isBefore(lastHourForSelectedDay) &&
              event.start_at.day == selectedDay.day ||
          event.start_at.day < selectedDay.day &&
              event.end_at.day > selectedDay.day ||
          event.end_at.isAfter(firstHourForSelectedDay) &&
              event.end_at.isBefore(lastHourForSelectedDay) &&
              event.end_at.day == selectedDay.day) {
        List<EventParticipation> eventParticipationList =
            await _eventParticipationApi
                .getEventsParticipationByEventId(event.id!);
        event.setEventParticipationList(eventParticipationList);
        eventsBySelectedDay.add(event);
      }
    });

    return eventsBySelectedDay;
  }

  Future<Event> getOneById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  Future<Event> create(Event event) async {
    await _eventApi.createEvent(event);
    return event;
  }

  Future<void> delete(String id) async {
    return await _eventApi.deleteEvent(id);
  }

  Future<void> update(Event event) async {
    await _eventApi.updateEvent(event);
  }
}
