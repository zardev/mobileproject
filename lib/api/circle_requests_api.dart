import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/CircleRequest.dart';

class CircleRequestApi {
  CollectionReference circleRequestsCollection =
  FirebaseFirestore.instance.collection('circleRequests');

  Future<CircleRequest?> getCircleRequest(String id) async {
    CircleRequest? circleRequest = null;

    await circleRequestsCollection
        .withConverter<CircleRequest>(
        fromFirestore: (snapshot, _) =>
            CircleRequest.fromJson(snapshot.data()!),
        toFirestore: (circleRequest, _) => circleRequest.toJson())
        .doc(id)
        .get()
        .then((snapshot) => circleRequest = snapshot.data());

    return circleRequest;
  }

  Future<List<CircleRequest>> getAllCircleRequestsByUser(String userId) async {
    List<CircleRequest> circleRequestListByUser = [];

    await circleRequestsCollection
        .withConverter<CircleRequest>(
        fromFirestore: (snapshot, _) =>
            CircleRequest.fromJson(snapshot.data()!),
        toFirestore: (circleRequest, _) => circleRequest.toJson())
        .where('senderId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        CircleRequest circleRequest = document.data();
        circleRequest.setId(document.id);
        circleRequestListByUser.add(circleRequest);
      });
    });

    return circleRequestListByUser;
  }

  Future<List<CircleRequest>> getCircleRequestsInvitations(String userId) async {
    List<CircleRequest> circleRequestListByUser = [];

    await circleRequestsCollection
        .withConverter<CircleRequest>(
        fromFirestore: (snapshot, _) =>
            CircleRequest.fromJson(snapshot.data()!),
        toFirestore: (circleRequest, _) => circleRequest.toJson())
        .where('receiverId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        CircleRequest circleRequest = document.data();
        circleRequest.setId(document.id);
        circleRequestListByUser.add(circleRequest);
      });
    });

    return circleRequestListByUser;
  }

  Future<CircleRequest> createCircleRequest(CircleRequest circleRequest) async {
    await circleRequestsCollection.add({
      'senderId': circleRequest.senderId,
      'receiverId': circleRequest.receiverId,
      'circleId': circleRequest.circleId
    }).then((value) {
      print("Circle Request sended");
      circleRequest.setId(value.id);
    }).catchError((error) {
      print("Failed to send Circle Request: $error");
    });

    return circleRequest;
  }

  Future<void> deleteCircleRequest(String id) async {
    circleRequestsCollection
        .doc(id)
        .delete()
        .then((value) => print("Circle Request deleted"))
        .catchError((error) => print("Failed to delete circle request: $error"));
  }

  void removeAllRequestsFromCircle(String circleId) {
    circleRequestsCollection
    .where("circleId", isEqualTo: circleId)
        .get()
        .then((documentSnapshot) => {
          documentSnapshot.docs.forEach((document) {
            document.reference.delete();
          })
    });
  }
}
