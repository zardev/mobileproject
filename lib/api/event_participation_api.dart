import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/EventParticipation.dart';

class EventParticipationApi {
  Future<List<EventParticipation>> getEventsParticipationByEventId(
      String eventId) async {
    List<EventParticipation> eventParticipationList = [];

    final eventsParticipationRef = FirebaseFirestore.instance
        .collection('eventsParticipation')
        .withConverter<EventParticipation>(
            fromFirestore: (snapshot, _) =>
                EventParticipation.fromJson(snapshot.data()!),
            toFirestore: (eventParticipation, _) =>
                eventParticipation.toJson());

    List<QueryDocumentSnapshot<EventParticipation>>
        eventsParticipationSnapshot = await eventsParticipationRef
            .where('eventId', isEqualTo: eventId)
            .get()
            .then((snapshot) => snapshot.docs);

    eventParticipationList =
        setIdForEventsParticipation(eventsParticipationSnapshot);

    return eventParticipationList;
  }

  Future<void> createEventParticipation(
      EventParticipation eventParticipation) async {
    CollectionReference eventsParticipationCollection =
        FirebaseFirestore.instance.collection('eventsParticipation');

    return eventsParticipationCollection
        .add({
          'userId': eventParticipation.userId,
          'eventId': eventParticipation.eventId,
        })
        .then((value) => print("Event Participation Added"))
        .catchError(
            (error) => print("Failed to add event participation: $error"));
  }

  Future<void> deleteEventParticipation(String eventDocId) {
    CollectionReference eventsParticipationCollection =
        FirebaseFirestore.instance.collection('eventsParticipation');

    return eventsParticipationCollection
        .doc(eventDocId)
        .delete()
        .then((value) => print("Event Participation Deleted"))
        .catchError(
            (error) => print("Failed to delete event participation: $error"));
  }

  List<EventParticipation> setIdForEventsParticipation(
      List<QueryDocumentSnapshot<EventParticipation>>
          eventsParticipationSnapshot) {
    List<EventParticipation> eventParticipationList = [];

    if (eventsParticipationSnapshot.isNotEmpty) {
      eventsParticipationSnapshot.forEach((eventParticipation) {
        EventParticipation newEventParticipation = eventParticipation.data();
        newEventParticipation.setId(eventParticipation.id);
        eventParticipationList.add(newEventParticipation);
      });
    }
    return eventParticipationList;
  }
}
