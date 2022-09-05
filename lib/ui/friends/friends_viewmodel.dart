import 'dart:convert';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mon_agenda_partage/api/fire_auth.dart';
import 'package:mon_agenda_partage/models/Friend.dart';
import 'package:mon_agenda_partage/models/FriendRequest.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:mon_agenda_partage/services/friend_service.dart';
import 'package:mon_agenda_partage/services/user_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_share/flutter_share.dart';


class FriendsViewModel extends ChangeNotifier {

  List<AppUser.User> friends = [];
  List<AppUser.User> usersInApp = [];
  List<AppUser.User> usersByFriendRequest = [];

  List<Contact> contacts = [];
  Iterable<Contact> contactsIterable = [];

  List<FriendRequest> pendingInvitationsSent = [];
  List<FriendRequest> pendingInvitationsReceived = [];

  final FriendService friendService = FriendService();
  final UserService userService = UserService();

  String currentUserId = "";
  bool isBusy = true;
  bool contactSelected = true;

  Future<void> initialize() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    currentUserId = auth.currentUser!.uid;
    // List Getters
    friends = await friendService.getFriendsByUserId(currentUserId);
    pendingInvitationsSent = await friendService.getFriendRequestsByUserId(currentUserId);
    pendingInvitationsReceived = await friendService.getFriendRequestsInvitations(currentUserId);
    contactsIterable = await ContactsService.getContacts();
    contacts = contactsIterable.toList();
    await _getUsersInApp();
    await _getUsersByFriendRequest();

    // Update UI
    this.isBusy = false;
    this.notifyListeners();
  }

  Future<void> _getUsersInApp() async {
    usersInApp = await friendService.getUsersInApp(contacts);

    usersInApp.removeWhere((user) => user.id == currentUserId);
    friends.forEach((friend) {
      usersInApp.removeWhere((user) => friend.phoneNumber == user.phoneNumber);
    });
  }

  Future<void> _getUsersByFriendRequest() async {
    usersByFriendRequest = await userService.getUsersByFriendRequest(pendingInvitationsReceived);
  }

  Future<void> toggleFriendRequest(String friendId) async {

    if(!isExistingInvitationPending(friendId)) {
      await _sendFriendRequest(friendId);
    } else {
      await _cancelFriendRequest(friendId);
    }

    this.notifyListeners();
  }

  Future<void> _sendFriendRequest(String friendId) async {
    FriendRequest friendRequest = FriendRequest(senderId: currentUserId, receiverId: friendId);
    friendRequest = await friendService.sendFriendRequest(friendRequest);
    pendingInvitationsSent.add(friendRequest);
  }

  Future<void> _cancelFriendRequest(String friendId) async {
    FriendRequest friendRequest = _findFriendRequestByIds(currentUserId, friendId);
    await friendService.deleteFriendRequest(friendRequest.id!);
    pendingInvitationsSent.removeWhere((invitation) => invitation.receiverId == friendRequest.receiverId);
  }

  FriendRequest _findFriendRequestByIds(String userId, String friendId) {
    FriendRequest friendRequest = FriendRequest();

    pendingInvitationsSent.forEach((invitation) {
      if(invitation.senderId == userId && invitation.receiverId == friendId)
        friendRequest = invitation;
    });

    return friendRequest;
  }

  bool isExistingInvitationPending(String userId) {
    bool invitationSent = false;

    pendingInvitationsSent.forEach((invitation) {
      if (invitation.receiverId == userId) invitationSent = true;
    });

    return invitationSent;
  }

  Future<void> acceptFriendRequest(AppUser.User user) async {
    Friend friend = Friend(userId: currentUserId, friendId: user.id);

    await friendService.create(friend);
    await deleteFriendRequest(user);
    friends.add(user);
    this.notifyListeners();
  }

  Future<void> deleteFriendRequest(AppUser.User user) async {
    FriendRequest? friendRequest = getFriendRequestId(user.id);
    await friendService.deleteFriendRequest(friendRequest!.id!);
    usersByFriendRequest.removeWhere((
        userByFriendRequest) => userByFriendRequest.email == user.email);
  }

  FriendRequest? getFriendRequestId(String id) {
    return pendingInvitationsReceived.firstWhereOrNull((invitation) => invitation.senderId == id);
  }

  Future<void> removeFriend(String friendId) async {
    AppUser.User? user = await userService.getOneById(friendId);
    Friend friend = Friend(userId: currentUserId, friendId: friendId);
    if (user != null) {
      await friendService.delete(friend);
      usersInApp.add(user);
      friends.removeWhere((f) => f.email == user.email);
      this.notifyListeners();
    } else {
      print("Error, user not found");
    }
  }

  Future<void> inviteContacts() async {
    await FlutterShare.share(
        title: 'Example share',
        text: 'Example share text',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'Example Chooser Title'
    );
  }

}
