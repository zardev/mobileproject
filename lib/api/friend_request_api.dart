import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/FriendRequest.dart';

class FriendRequestApi {
  CollectionReference friendRequestsCollection =
  FirebaseFirestore.instance.collection('friendRequests');

  Future<FriendRequest?> getFriendRequest(String id) async {
    FriendRequest? friendRequest = null;

    await friendRequestsCollection
        .withConverter<FriendRequest>(
        fromFirestore: (snapshot, _) =>
            FriendRequest.fromJson(snapshot.data()!),
        toFirestore: (friendRequest, _) => friendRequest.toJson())
        .doc(id)
        .get()
    .then((snapshot) => friendRequest = snapshot.data());

    return friendRequest;
  }

  Future<List<FriendRequest>> getAllFriendRequestsByUser(String userId) async {
    List<FriendRequest> friendRequestListByUser = [];

    await friendRequestsCollection
        .withConverter<FriendRequest>(
        fromFirestore: (snapshot, _) =>
            FriendRequest.fromJson(snapshot.data()!),
        toFirestore: (friendRequest, _) => friendRequest.toJson())
        .where('senderId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        FriendRequest friendRequest = document.data();
        friendRequest.setId(document.id);
        friendRequestListByUser.add(friendRequest);
      });
    });

    return friendRequestListByUser;
  }

  Future<List<FriendRequest>> getFriendRequestsInvitations(String userId) async {
    List<FriendRequest> friendRequestListByUser = [];

    await friendRequestsCollection
        .withConverter<FriendRequest>(
        fromFirestore: (snapshot, _) =>
            FriendRequest.fromJson(snapshot.data()!),
        toFirestore: (friendRequest, _) => friendRequest.toJson())
        .where('receiverId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        FriendRequest friendRequest = document.data();
        friendRequest.setId(document.id);
        friendRequestListByUser.add(friendRequest);
      });
    });

    return friendRequestListByUser;
  }

  Future<FriendRequest> createFriendRequest(FriendRequest friendRequest) async {
    await friendRequestsCollection.add({
      'senderId': friendRequest.senderId,
      'receiverId': friendRequest.receiverId
    }).then((value) {
      print("Friend Request sended");
      friendRequest.setId(value.id);
    }).catchError((error) {
      print("Failed to send Friend Request: $error");
    });

    return friendRequest;
  }

  Future<void> deleteFriendRequest(String id) async {
    friendRequestsCollection
        .doc(id)
        .delete()
        .then((value) => print("Friend Request deleted"))
        .catchError((error) => print("Failed to delete friend request: $error"));
  }
}
