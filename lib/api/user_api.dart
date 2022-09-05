import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/FriendRequest.dart';
import 'package:mon_agenda_partage/models/User.dart';

class UserApi {
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<List<User>> getUsers() async {
    List<User> users = [];

    await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((user) {
        users.add(user.data());
      });
    });

    return users;
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    User? user = null;

    await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get()
        .then((snapshot) {
      user = snapshot.docs.first.data();
    });

    return user;
  }

  Future<User?> getUserById(String userId) async {

    final usersCollection = FirebaseFirestore.instance.collection('users').withConverter<User>(
      fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
      toFirestore: (user, _) => user.toJson(),
    );

    return await usersCollection
        .doc(userId)
        .get()
        .then((snapshot) => snapshot.data());
  }

  Future<void> updateUser(User user) {

    return usersCollection
        .doc(user.id)
        .update({
      'email': user.email,
      'familyId': user.familyId,
      'phoneNumber': user.phoneNumber,
      'selectedCircle': user.selectedCircle,
    })
        .then((value) => print("User updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
