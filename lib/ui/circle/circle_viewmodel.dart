import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mon_agenda_partage/api/fire_auth.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleRequest.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:mon_agenda_partage/services/circle_service.dart';
import 'package:logger/logger.dart';
import 'package:mon_agenda_partage/services/friend_service.dart';
import 'package:mon_agenda_partage/services/user_service.dart';
import 'package:collection/collection.dart';

class CircleViewModel extends ChangeNotifier {
  final FriendService friendService = FriendService();
  final CircleService circleService = CircleService();
  final UserService userService = UserService();
  FirebaseAuth auth = FirebaseAuth.instance;
  final logger = Logger(
    filter: null,
    printer: PrettyPrinter(
        methodCount: 0
    ),
    output: null,
  );

  // Database collections
  List<AppUser.User> _users = [];
  List<AppUser.User> _friends = [];
  List<Circle> _circles = [];
  List<CircleUser> _circleUsers = [];

  // Circle members
  List<AppUser.User> selectedCircleMembers = [];
  List<AppUser.User> circleMembers = [];
  List<CircleUser> circleUsersByAgendas = [];

  // Circle Requests
  List<CircleRequest> pendingInvitationsSent = [];
  List<CircleRequest> pendingInvitationsReceived = [];
  List<AppUser.User> usersByCircleRequest = [];

  List<Circle> circleListByUser = [];
  List<AppUser.User> friendsNotInCircle = [];
  Circle? selectedCircle;
  AppUser.User? currentUser;
  AppUser.User? circleOwnerUser;
  bool isBusy = true;
  bool friendRowSelected = true;

  Future<void> initialize() async {
    isBusy = true;
    this.notifyListeners();
    currentUser = await userService.getOneById(auth.currentUser!.uid);

    if (currentUser != null) {
      logger.v({"Current User" : currentUser!.toJson()});
      _users = await userService.getAll();
      _circles = await circleService.getAll();
      _circleUsers = await circleService.getAllCircleUsers();
      _friends = await friendService.getFriendsByUserId(currentUser!.id);
      pendingInvitationsSent = await circleService.getCirclesRequestsByUserId(currentUser!.id);
      pendingInvitationsReceived = await circleService.getCircleRequestsInvitations(currentUser!.id);
      _getUsersByCircleRequest();
      _getCircleList();
      _getFriendsNotInCircle();
      this.notifyListeners();
    } else {
      logger.e("User not found !");
    }

    isBusy = false;
  }

  void _getCircleList() {
    circleListByUser = [];

    if(_circleUsers.isNotEmpty && _circles.isNotEmpty) {
      _circleUsers.forEach((circleUser) {
        Circle? circle = null;
        circle = _circles.firstWhereOrNull(
                (agenda) => agenda.id == circleUser.circleId
                && currentUser!.id == circleUser.userId);
        if (circle != null) circleListByUser.add(circle);
      });
    } else {
      logger.i("No circles are available in the app");
      return;
    }

    if (circleListByUser.isNotEmpty) {
      logger.v(circleListByUser);
      _getSelectedCircle();
    } else {
      selectedCircle = null;
      logger.i("No circle found !");
    }
  }

  void _getSelectedCircle() {
    selectedCircle = circleListByUser.firstWhereOrNull(
            (agenda) => agenda.id == currentUser!.selectedCircle);

    if(selectedCircle == null) {
      selectedCircle = circleListByUser[0];
      currentUser!.selectedCircle = selectedCircle!.id;
      userService.update(currentUser!);
    }

    if(selectedCircle != null) {
      _getCircleOwner();
      _getCircleMembers();
      logger.v({"Selected circle" : selectedCircle!.toJson()});
    } else {
      logger.i("Error : Selected circle not found !");
    }
  }

  Future<void> _getFriendsNotInCircle() async {
    friendsNotInCircle = _friends;

    selectedCircleMembers.forEach((member) {
      friendsNotInCircle.removeWhere((friend) => member.email == friend.email);
    });
  }

  void _getCircleOwner() {

    circleOwnerUser = _users.firstWhereOrNull(
            (user) => user.id == selectedCircle!.ownerId);

    if(circleOwnerUser != null) {
      logger.v({"Circle owner" : circleOwnerUser!.toJson()});
    } else {
      logger.e("Error finding circle owner");
    }
  }

  void _getCircleMembers() {
    _getCircleUsersByAgendas();

    if(circleUsersByAgendas.isNotEmpty) {
      _getCircleMemberList();
      selectedCircleMembers = _getSelectedCircleMembers(selectedCircle!);
    } else {
      logger.e("No users found for given circles");
    }
  }

  void _getCircleUsersByAgendas() {
    circleUsersByAgendas = [];

    circleListByUser.forEach((circle) {
      _circleUsers.forEach((circleUser) {
        if(circleUser.circleId == circle.id) {
          circleUsersByAgendas.add(circleUser);
        }
      });
    });
  }

  void _getCircleMemberList() {
    circleMembers = [];

    _users.forEach((user) {
      CircleUser? circleUser = null;
      circleUser = circleUsersByAgendas.firstWhereOrNull(
              (circleUser) =>
          circleUser.userId == user.id);
      if (circleUser != null) circleMembers.add(user);
    });

    if(circleMembers.length > 0) {
      logger.v("User list count : " + circleMembers.length.toString());
    } else {
      logger.e("Error getting circle members");
    }
  }

  List<AppUser.User> _getSelectedCircleMembers(Circle circle) {
    List<AppUser.User> members = [];

    _users.forEach((user) {
      CircleUser? circleUser = null;
      circleUser = circleUsersByAgendas.firstWhereOrNull(
              (circleUser) => circleUser.userId == user.id
              && circleUser.circleId == circle.id);
      if (circleUser != null) members.add(user);
    });

    if(members.length > 0) {
      logger.v("User list count : " + members.length.toString());
    } else {
      logger.e("Error getting selected circle members");
    }

    return members;
  }

  void selectCircle(Circle circle) {
    currentUser!.selectedCircle = circle.id;
    userService.update(currentUser!);
    initialize();
    this.notifyListeners();
  }

  List<AppUser.User> getCircleMembersByIndex(int index) {
    List<AppUser.User> circleMembersByIndex = [];

    circleMembersByIndex = _getSelectedCircleMembers(circleListByUser[index]);

    return circleMembersByIndex;
  }

  Future<void> createCircle(Circle _circle) async {
    selectedCircle = await circleService.create(_circle);
    selectCircle(selectedCircle!);
    this.notifyListeners();
  }

  Future<void> editCircle(Circle _circle) async {
    _circle.setId(selectedCircle!.id!);
    await circleService.update(_circle);
    selectedCircle!.name = _circle.name;
    this.notifyListeners();
  }

  Future<void> deleteCircle() async {
    if (selectedCircle!.id!.isNotEmpty) {
      circleService.delete(selectedCircle!.id!);
      circleListByUser.remove(selectedCircle);
      if(circleListByUser.isNotEmpty) {
        selectCircle(circleListByUser[0]);
      } else {
        selectedCircle = null;
      }
      initialize();
      this.notifyListeners();
    } else {
      logger.e("No circle has been found for current user");
    }
  }

  Future<void> removeCircleMember(String userId) async {
    CircleUser circleUser = CircleUser(userId: userId, circleId: selectedCircle!.id);
    await circleService.removeCircleMember(circleUser);

    circleMembers.removeWhere((user) => user.id == userId);
    selectedCircleMembers.removeWhere((user) => user.id == userId);

    this.notifyListeners();
  }

  void _getUsersByCircleRequest() {
    usersByCircleRequest = [];

    pendingInvitationsReceived.forEach((request) {
      AppUser.User? user = null;
      user = _users.firstWhereOrNull((user) => user.id == request.senderId);
      if(user != null) usersByCircleRequest.add(user);
    });

    if(usersByCircleRequest.length > 0) {
      logger.v("User list count : " + usersByCircleRequest.length.toString());
    } else {
      logger.i("No invitations received !");
    }
  }

  Future<void> toggleFriendRequest(String friendId) async {

    if(!isExistingInvitationPending(friendId)) {
      await _sendCircleRequest(friendId);
    } else {
      await _cancelCircleRequest(friendId);
    }

    this.notifyListeners();
  }

  Future<void> _sendCircleRequest(String friendId) async {
    CircleRequest circleRequest = CircleRequest(
        senderId: currentUser!.id, receiverId: friendId, circleId: selectedCircle!.id);
    circleRequest = await circleService.sendCircleRequest(circleRequest);
    pendingInvitationsSent.add(circleRequest);
  }

  Future<void> _cancelCircleRequest(String friendId) async {
    CircleRequest circleRequest = _findCircleRequestByIds(currentUser!.id, friendId);
    await circleService.deleteCircleRequest(circleRequest.id!);
    pendingInvitationsSent.removeWhere((invitation) => invitation.receiverId == circleRequest.receiverId);
  }

  CircleRequest _findCircleRequestByIds(String userId, String friendId) {
    CircleRequest circleRequest = CircleRequest();

    pendingInvitationsSent.forEach((invitation) {
      if(invitation.senderId == userId && invitation.receiverId == friendId)
        circleRequest = invitation;
    });

    return circleRequest;
  }

  bool isExistingInvitationPending(String userId) {
    bool invitationSent = false;

    pendingInvitationsSent.forEach((invitation) {
      if (invitation.receiverId == userId &&
          selectedCircle!.id == invitation.circleId) invitationSent = true;
    });

    return invitationSent;
  }

  Future<void> acceptCircleRequest(CircleRequest circleRequest) async {
    Circle circle = _circles.firstWhere((c) => c.id == circleRequest.circleId);
    CircleUser circleUser = CircleUser(userId: currentUser!.id, circleId: circleRequest.circleId);

    await circleService.createCircleUser(circleUser);
    await deleteCircleRequest(circleRequest);
    selectCircle(circle);
    this.notifyListeners();
  }

  Future<void> deleteCircleRequest(CircleRequest _circleRequest) async {
    CircleRequest? circleRequest = getCircleRequestId(_circleRequest.senderId!);
    await circleService.deleteCircleRequest(circleRequest!.id!);
    usersByCircleRequest.removeWhere((
        userByCircleRequest) => userByCircleRequest.email == currentUser!.email);
    pendingInvitationsReceived.removeWhere((
        circleRequest) => circleRequest.circleId == _circleRequest.circleId);
  }

  CircleRequest? getCircleRequestId(String id) {
    return pendingInvitationsReceived.firstWhereOrNull((invitation) => invitation.senderId == id);
  }

  String getUsernameById(String userId) {
    return _users.firstWhereOrNull((user) => user.id == userId)!.name!;
  }

  String getCircleNameById(String circleId) {
    return _circles.firstWhereOrNull((circle) => circle.id == circleId)!.name!;
  }

}
