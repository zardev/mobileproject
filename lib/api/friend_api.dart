import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mon_agenda_partage/models/Friend.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:collection/collection.dart';


class FriendApi {
  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');
  CollectionReference friendsCollection =
  FirebaseFirestore.instance.collection('friends');

  Future<List<User>> getFriendsInfoListByUser(String userId) async {
    List<String> friendIdListByUser = await _getFriendsIdByUser(userId);
    List<User> userListByFriendId = await getUsersByFriendId(friendIdListByUser);

    return userListByFriendId;
  }

  Future<List<String>> _getFriendsIdByUser(String userId) async {
    List<String> friendIdListByUser = [];

    await friendsCollection
        .withConverter<Friend>(
        fromFirestore: (snapshot, _) => Friend.fromJson(snapshot.data()!),
        toFirestore: (friend, _) => friend.toJson())
        .where("userId", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) {
        friendIdListByUser.add(documentSnapshot.data().friendId!);
      });
    }).catchError((error) {
      print("An error has occurred while gathering friends ids $error");
    });

    return friendIdListByUser;
  }

  Future<List<User>> getUsersByFriendId(List<String> friendIdListByUser) async {
    List<User> users = [];
    List<User> usersByFriendId = [];

    await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs..forEach((user) {
        users.add(user.data());
      });
    }).catchError((error) {
      print("An error has occurred while gathering user info $error");
    });

    friendIdListByUser.forEach((friendId) {
      User? user = null;

      user = users.firstWhereOrNull((u) => u.id == friendId);
      if(user != null) usersByFriendId.add(user);
    });

    return usersByFriendId;
  }

  Future<User?> getUserByFriendId(String friendId) async {
    User? userByFriendId = null;

    await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .doc(friendId)
        .get()
        .then((user) {
      print("User by friend id has been found");
      userByFriendId = user.data();
    }).catchError((error) {
      print("An error has occurred while gathering user info $error");
    });

    return userByFriendId;
  }


  Future<List<User>> getUsersInApp(List<Contact?> contacts) async {
    List<User> users = [];
    List<User> usersInApp = [];

    // Get users
    await usersCollection
        .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson())
        .get()
        .then((usersSnapshot) {
      usersSnapshot.docs.forEach((userDocument) {
        users.add(userDocument.data());
      });
    }).catchError((error) {
      print("An error has occurred while gathering user info $error");
    });

    // Loop through all contacts and check if users are in contacts info
    contacts.forEach((contact) async {
      User? user = null;

      if (contact!.phones!.isNotEmpty)
        user = getUserByContactInfo(contact, users);

      if(user != null) {
        usersInApp.add(user);
      }
    });

    usersInApp = usersInApp.toSet().toList();

    return usersInApp;
  }

  User? getUserByContactInfo(Contact contact, List<User?> users) {
    User? userByContactInfo = null;

    userByContactInfo = users.firstWhereOrNull((user) => user!.phoneNumber == contact.phones!.first.value);

    return userByContactInfo;
  }

  Future<void> createFriend(Friend friend) async {
    await friendsCollection.add(
        {'userId': friend.userId, 'friendId': friend.friendId}).then((value) {
      print("Friend A Added");
    }).catchError((error) {
      print("Failed to add friend: $error");
    });

    await friendsCollection.add(
        {'userId': friend.friendId, 'friendId': friend.userId}).then((value) {
      print("Friend B Added");
    }).catchError((error) {
      print("Failed to add friend: $error");
    });
  }

  Future<void> deleteFriend(Friend friend) async {
    await _removeFriendFirstDocument(friend);
    await _removeFriendSecondDocument(friend);
  }

  Future<void> _removeFriendFirstDocument(Friend friend) async {
    Query<Object?> query = friendsCollection
        .where('userId', isEqualTo: friend.userId)
        .where('friendId', isEqualTo: friend.friendId);
    await _removeDocumentFromCollection(query);
  }

  Future<void> _removeFriendSecondDocument(Friend friend) async {
    Query<Object?> query = friendsCollection
        .where('userId', isEqualTo: friend.friendId)
        .where('friendId', isEqualTo: friend.userId);
    await _removeDocumentFromCollection(query);
  }

  Future<void> _removeDocumentFromCollection(Query<Object?> query) async {
    query.get().then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((document) {
          document.reference.delete();
        });
        print("Friend removed");
      }
    });
  }
}
