import 'package:mon_agenda_partage/api/friend_api.dart';
import 'package:mon_agenda_partage/api/friend_request_api.dart';
import 'package:mon_agenda_partage/models/Friend.dart';
import 'package:mon_agenda_partage/models/FriendRequest.dart';
import 'package:mon_agenda_partage/services/crud_service.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:contacts_service/contacts_service.dart';



class FriendService {
  final FriendApi _friendApi = FriendApi();
  final FriendRequestApi _friendRequestApi = FriendRequestApi();

  Future<List<Friend>> getAll() async {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  Future<Friend?> getOneById(String id) async {
    // TODO: implement getById
    throw UnimplementedError();
  }

  Future<FriendRequest?> getFriendRequestById(String id) async {
    return await _friendRequestApi.getFriendRequest(id);
  }
  
  Future<User?> getUserByFriendId(String friendId) async {
    return await _friendApi.getUserByFriendId(friendId);
  }

  Future<List<User>> getFriendsByUserId(String userId) async {
    return await _friendApi.getFriendsInfoListByUser(userId);
  }

  Future<List<User>> getUsersInApp(List<Contact> contacts) async {
    return await _friendApi.getUsersInApp(contacts);
  }

  Future<List<FriendRequest>> getFriendRequestsByUserId(String userId) async {
    return await _friendRequestApi.getAllFriendRequestsByUser(userId);
  }

  Future<List<FriendRequest>> getFriendRequestsInvitations(String userId) async {
    return await _friendRequestApi.getFriendRequestsInvitations(userId);
  }

  Future<Friend> create(Friend friend) async {
    await _friendApi.createFriend(friend);
    return friend;
  }

  Future<FriendRequest> sendFriendRequest(FriendRequest friendRequest) async {
    friendRequest = await _friendRequestApi.createFriendRequest(friendRequest);
    return friendRequest;
  }

  Future<void> delete(Friend friend) async {
    return await _friendApi.deleteFriend(friend);
  }

  Future<void> deleteFriendRequest(String id) async {
    return await _friendRequestApi.deleteFriendRequest(id);
  }

  Future<void> update(Friend entity) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
