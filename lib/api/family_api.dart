import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/Family.dart';
import 'package:mon_agenda_partage/models/User.dart';

class FamilyApi {
  CollectionReference familiesCollection =
      FirebaseFirestore.instance.collection('families');
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<Family?> getFamilyById(String familyId) async {
    Family? family;
    family = await familiesCollection
        .withConverter<Family>(
            fromFirestore: (snapshot, _) => Family.fromJson(snapshot.data()!),
            toFirestore: (family, _) => family.toJson())
        .doc(familyId)
        .get()
        .then((snapshot) => snapshot.data());

    if (family != null) family.setId(familyId);

    return family;
  }

  Future<List<User>> getFamilyMembersByFamilyId(String familyId) async {
    List<User> familyMembers = [];

    List<QueryDocumentSnapshot<User>> usersSnapshot = await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .where("familyId", isEqualTo: familyId)
        .get()
        .then((snapshot) => snapshot.docs);

    familyMembers = setIdForUsers(usersSnapshot);

    return familyMembers;
  }

  Future<void> createFamily(Family family) async {
    return familiesCollection
        .add({'name': family.name, 'ownerId': family.ownerId}).then((value) {
      print("Family Added, adding familyId to owner...");
      addFamilyIdToOwner(value.id, family.ownerId);
    }).catchError((error) {
      print("Failed to add family: $error");
    });
  }

  Future<void> addFamilyIdToOwner(String familyId, String ownerId) async {
    return usersCollection
        .doc(ownerId)
        .update({'familyId': familyId})
        .then((value) => print("User family id updated"))
        .catchError(
            (error) => print("Failed to update family id for user: $error"));
  }

  Future<void> updateFamily(Family family) {
    return familiesCollection
        .doc(family.id)
        .update({
          'name': family.name,
        })
        .then((value) => print("Family updated"))
        .catchError((error) => print("Failed to update family: $error"));
  }

  Future<bool> deleteFamily(String familyId) {
    return familiesCollection.doc(familyId).delete().then((value) async {
      print("Family Deleted");

      await removeFamilyMembersFromFamily(familyId);
      return true;
    }).catchError((error) {
      print("Failed to delete family: $error");
      return false;
    });
  }

  Future<void> removeFamilyMembersFromFamily(String familyId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    return usersCollection
        .where("familyId", isEqualTo: familyId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.update(document.reference, {"familyId": ""});
      });
      return batch.commit();
    });
  }

  Future<void> removeFamilyMemberByUserId(String userId) async {
    return usersCollection
        .doc(userId)
        .update({"familyId": ""})
        .then((value) => print("Removed user from family"))
        .catchError((error) => print("Failed to update user family id: $error"));
  }

  List<User> setIdForUsers(
      List<QueryDocumentSnapshot<User>> usersSnapshot) {
    List<User> userList = [];

    if (usersSnapshot.isNotEmpty) {
      usersSnapshot.forEach((user) {
        User newUser = user.data();
        newUser.id = user.id;
        userList.add(newUser);
      });
    }
    return userList;
  }

  List<Family> setIdForFamilies(
      List<QueryDocumentSnapshot<Family>> familiesSnapshot) {
    List<Family> familyList = [];

    if (familiesSnapshot.isNotEmpty) {
      familiesSnapshot.forEach((family) {
        Family newFamily = family.data();
        newFamily.setId(family.id);
        familyList.add(newFamily);
      });
    }
    return familyList;
  }
}
