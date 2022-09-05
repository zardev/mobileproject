import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';

class CircleUserApi {
  CollectionReference circleUsersCollection =
  FirebaseFirestore.instance.collection('circleUsers');

  Future<List<CircleUser>> getAllCircleUsers() async {
    List<CircleUser> circleUsers = [];

    await circleUsersCollection.withConverter<CircleUser>(
        fromFirestore: (snapshot, _) =>
            CircleUser.fromJson(snapshot.data()!),
        toFirestore: (circleUser, _) => circleUser.toJson())
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        CircleUser circleUser = document.data();
        circleUser.setId(document.id);
        circleUsers.add(circleUser);
      });
    });

    return circleUsers;
  }

  Future<List<CircleUser>> getMembersByCircleId(
      String circleId) async {
    List<CircleUser> circleUserListByAgendaId = [];

    await circleUsersCollection
        .withConverter<CircleUser>(
        fromFirestore: (snapshot, _) =>
            CircleUser.fromJson(snapshot.data()!),
        toFirestore: (circleUser, _) => circleUser.toJson())
        .where('circleId', isEqualTo: circleId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        CircleUser circleUser = document.data();
        circleUser.setId(document.id);
        circleUserListByAgendaId.add(circleUser);
      });
    });

    return circleUserListByAgendaId;
  }

  Future<void> createCircleUser(CircleUser circleUser) async {
    await circleUsersCollection.add({
      'userId': circleUser.userId,
      'circleId': circleUser.circleId
    }).then((value) {
      print("User added in Circle");
    }).catchError((error) {
      print("Failed to add user in Circle: $error");
    });
  }

  Future<void> removeCircleMember(CircleUser circleUser) async {
    circleUsersCollection
        .where("userId", isEqualTo: circleUser.userId!)
        .where("circleId", isEqualTo: circleUser.circleId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        document.reference.delete();
      });
      print("User deleted in Circle");
    })
        .catchError((error) {
      print("Failed to delete user in circle: $error");
    });
  }

  Future<void> removeAllMembersFromCircle(String circleId) async {
    circleUsersCollection
        .where("circleId", isEqualTo: circleId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        document.reference.delete();
      });
      print("Users removed from Circle");
    })
        .catchError((error) {
      print("Failed to delete users from circle: $error");
    });
  }

}
