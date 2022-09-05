import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:collection/collection.dart';

class CircleApi {
  CollectionReference circleCollection =
  FirebaseFirestore.instance.collection('circles');
  CollectionReference circleUsersCollection =
  FirebaseFirestore.instance.collection('circleUsers');

  Future<List<Circle>> getAllCircles() async {
    List<Circle> circleList = [];

    await circleCollection
        .withConverter<Circle>(
        fromFirestore: (snapshot, _) =>
            Circle.fromJson(snapshot.data()!),
        toFirestore: (circle, _) => circle.toJson())
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((_circle) {
        Circle circle = _circle.data();
        circle.setId(_circle.id);
        circleList.add(circle);
      });
    });

    return circleList;
  }

  Future<List<CircleUser>> getCircleIdsByUser(String userId) async {
    List<CircleUser> circleListId = [];

    await circleUsersCollection
        .withConverter<CircleUser>(
        fromFirestore: (snapshot, _) =>
            CircleUser.fromJson(snapshot.data()!),
        toFirestore: (circleUsers, _) => circleUsers.toJson())
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        CircleUser circleUser = document.data();
        circleUser.setId(document.id);
        circleListId.add(circleUser);
      });
    }).catchError((error) {
      print("An error has occurred while gathering circle ids ids $error");
    });

    return circleListId;
  }

  Future<Circle> createCircle(Circle circle) async {

    await circleCollection
        .add({'name': circle.name, 'ownerId': circle.ownerId})
        .then((value) => circle.id = value.id)
        .catchError((error) {
      print("Failed to create Circle: $error");
    });

    return circle;
  }

  Future<void> updateCircle(Circle circle) {
    return circleCollection
        .doc(circle.id)
        .update({'name': circle.name, 'ownerId': circle.ownerId})
        .then((value) => print("Circle updated"))
        .catchError((error) => print("Failed to update Circle: $error"));
  }

  Future<bool> deleteCircle(String circleId) {
    return circleCollection
        .doc(circleId)
        .delete()
        .then((value) async {
      print("Circle Deleted");
      return true;
    }).catchError((error) {
      print("Failed to delete Circle: $error");
      return false;
    });
  }
}
