import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/EventParticipation.dart';

class Event {
  String? id;
  String? userId;
  String title;
  String? group;
  String? groupId;
  DateTime start_at;
  DateTime end_at;
  DateTime? creation_date;
  DateTime? updated_date;
  List<EventParticipation>? eventParticipationList;

  Event.add({
    this.id,
    required this.title,
    this.group,
    this.groupId,
    required this.start_at,
    required this.end_at
  });

  Event({
    this.id,
    this.userId,
    required this.title,
    this.group,
    this.groupId,
    required this.start_at,
    required this.end_at,
    required this.creation_date,
    required this.updated_date
  });

  factory Event.fromJson(Map<String, Object?> json) {
    Timestamp _start_at = json["start_at"] as Timestamp;
    Timestamp _end_at = json["end_at"] as Timestamp;
    Timestamp _creation_date = json["creation_date"] as Timestamp;
    Timestamp _updated_date = json["updated_date"] as Timestamp;
    return Event(
        userId: json["userId"] as String,
        title: json["title"] as String,
        group: json["group"] as String,
        groupId: json["groupId"] as String,
        start_at: _start_at.toDate(),
        end_at: _end_at.toDate(),
        creation_date: _creation_date.toDate(),
        updated_date: _updated_date.toDate()
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "group": group,
      "groupId": groupId,
      "start_at": start_at.toIso8601String(),
      "end_at": end_at.toIso8601String(),
      "creation_date": creation_date?.toIso8601String(),
      "updated_date": updated_date?.toIso8601String(),
      "eventParticipationList" : jsonEncode(eventParticipationList)
    };
  }

  void setId(String id) {
    this.id = id;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setStartAt(DateTime start_at) {
    this.start_at = start_at;
  }

  void setEndAt(DateTime end_at) {
    this.end_at = end_at;
  }

  void setEventParticipationList(List<EventParticipation> eventsParticipationList) {
    this.eventParticipationList = eventParticipationList;
  }
}