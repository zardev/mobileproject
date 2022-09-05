import 'package:mon_agenda_partage/api/user_api.dart';
import 'package:mon_agenda_partage/models/FriendRequest.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/services/crud_service.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:collection/collection.dart';

class UserService implements CrudService<User> {
  final UserApi _userApi = UserApi();

  @override
  Future<List<User>> getAll() async {
    return await _userApi.getUsers();
  }

  @override
  Future<User?> getOneById(String id) async {
    return _userApi.getUserById(id);
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    return _userApi.getUserByPhoneNumber(phoneNumber);
  }

  Future<List<User>> getUsersByFriendRequest(List<FriendRequest> friendRequests) async {
    List<User> users = await getAll();
    List<User> usersByFriendRequest = [];
    friendRequests.forEach((request) {
      User? user = null;
      user = users.firstWhereOrNull((user) => user.id == request.senderId);
      if(user != null) usersByFriendRequest.add(user);
    });

    return usersByFriendRequest;
  }

  @override
  Future<User> create(User user) async {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> update(User user) async {
    return await _userApi.updateUser(user);
  }
}
