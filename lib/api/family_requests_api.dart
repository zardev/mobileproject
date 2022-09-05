import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/FamilyRequest.dart';

class FamilyRequestApi {
  CollectionReference familyRequestsCollection =
  FirebaseFirestore.instance.collection('familyRequests');

  Future<FamilyRequest?> getFamilyRequest(String id) async {
    FamilyRequest? familyRequest = null;

    await familyRequestsCollection
        .withConverter<FamilyRequest>(
        fromFirestore: (snapshot, _) =>
            FamilyRequest.fromJson(snapshot.data()!),
        toFirestore: (familyRequest, _) => familyRequest.toJson())
        .doc(id)
        .get()
        .then((snapshot) => familyRequest = snapshot.data());

    return familyRequest;
  }

  Future<List<FamilyRequest>> getAllFamilyRequestsByUser(String userId) async {
    List<FamilyRequest> familyRequestListByUser = [];

    await familyRequestsCollection
        .withConverter<FamilyRequest>(
        fromFirestore: (snapshot, _) =>
            FamilyRequest.fromJson(snapshot.data()!),
        toFirestore: (familyRequest, _) => familyRequest.toJson())
        .where('senderId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        FamilyRequest familyRequest = document.data();
        familyRequest.setId(document.id);
        familyRequestListByUser.add(familyRequest);
      });
    });

    return familyRequestListByUser;
  }

  Future<List<FamilyRequest>> getFamilyRequestsInvitations(String userId) async {
    List<FamilyRequest> familyRequestListByUser = [];

    await familyRequestsCollection
        .withConverter<FamilyRequest>(
        fromFirestore: (snapshot, _) =>
            FamilyRequest.fromJson(snapshot.data()!),
        toFirestore: (familyRequest, _) => familyRequest.toJson())
        .where('receiverId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        FamilyRequest familyRequest = document.data();
        familyRequest.setId(document.id);
        familyRequestListByUser.add(familyRequest);
      });
    });

    return familyRequestListByUser;
  }

  Future<FamilyRequest> createFamilyRequest(FamilyRequest familyRequest) async {
    await familyRequestsCollection.add({
      'senderId': familyRequest.senderId,
      'receiverId': familyRequest.receiverId
    }).then((value) {
      print("Family Request sended");
      familyRequest.setId(value.id);
    }).catchError((error) {
      print("Failed to send Family Request: $error");
    });

    return familyRequest;
  }

  Future<void> deleteFamilyRequest(String id) async {
    familyRequestsCollection
        .doc(id)
        .delete()
        .then((value) => print("Family Request deleted"))
        .catchError((error) => print("Failed to delete family request: $error"));
  }
}
