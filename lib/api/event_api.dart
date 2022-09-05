import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/Event.dart';
import 'package:mon_agenda_partage/models/EventParticipation.dart';

class EventApi {
  Future<List<Event>> getAllEvents() async {
    List<Event> eventList = [];
    final eventsCollection = FirebaseFirestore.instance
        .collection('events')
        .withConverter<Event>(
            fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
            toFirestore: (event, _) => event.toJson());

    List<QueryDocumentSnapshot<Event>> eventsSnapshot = await eventsCollection
        .get()
        .then((snapshot) => snapshot.docs);

    eventList = setIdForEvents(eventsSnapshot);

    return eventList;
  }

  Future<List<Event>> getEventsByUser(String userId) async {
    List<Event> eventList = [];
    final eventsCollection = FirebaseFirestore.instance
        .collection('events')
        .withConverter<Event>(
        fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
        toFirestore: (event, _) => event.toJson());

    List<QueryDocumentSnapshot<Event>> eventsSnapshot = await eventsCollection
        .where('userId', isEqualTo: userId)
        .get()
        .then((snapshot) => snapshot.docs);

    eventList = setIdForEvents(eventsSnapshot);

    return eventList;
  }

  List<Event> setIdForEvents(
      List<QueryDocumentSnapshot<Event>> eventsSnapshot) {
    List<Event> eventList = [];

    if (eventsSnapshot.isNotEmpty) {
      eventsSnapshot.forEach((event) {
        Event newEvent = event.data();
        newEvent.setId(event.id);
        eventList.add(newEvent);
      });
    }
    return eventList;
  }

  Future<void> createEvent(Event event) async {
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    return eventsCollection
        .add({
          'title': event.title,
          'group': event.group,
          'groupId': event.groupId,
          'start_at': event.start_at,
          'end_at': event.end_at,
          'userId': event.userId,
          'creation_date': DateTime.now(),
          'updated_date': DateTime.now()
        })
        .then((value) => print("Event Added"))
        .catchError((error) => print("Failed to add event: $error"));
  }

  Future<void> updateEvent(Event event) {
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    return eventsCollection
        .doc(event.id)
        .update({
          'title': event.title,
          'start_at': event.start_at,
          'end_at': event.end_at,
        })
        .then((value) => print("Event updated"))
        .catchError((error) => print("Failed to update event: $error"));
  }

  Future<void> deleteEvent(String docId) {
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection('events');

    return eventsCollection
        .doc(docId)
        .delete()
        .then((value) => print("Event Deleted"))
        .catchError((error) => print("Failed to delete event: $error"));
  }
}
