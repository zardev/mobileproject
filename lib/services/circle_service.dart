import 'package:mon_agenda_partage/api/circle_api.dart';
import 'package:mon_agenda_partage/api/circle_requests_api.dart';
import 'package:mon_agenda_partage/api/circle_users_api.dart';
import 'package:mon_agenda_partage/api/user_api.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleRequest.dart';
import 'package:mon_agenda_partage/models/CircleUser.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/services/crud_service.dart';
import 'package:collection/collection.dart';

class CircleService implements CrudService<Circle> {
  final UserApi _userApi = new UserApi();
  final CircleApi _circleApi = new CircleApi();
  final CircleRequestApi _circleRequestApi = new CircleRequestApi();
  final CircleUserApi _circleUserApi = new CircleUserApi();

  @override
  Future<List<Circle>> getAll() async {
    return await _circleApi.getAllCircles();
  }

  Future<List<CircleUser>> getAllCircleUsers() async {
    return await _circleUserApi.getAllCircleUsers();
  }

  @override
  Future<Circle?> getOneById(String circleId) async {
    if (circleId.isEmpty) return null;
    // return await _circleApi.getCircleById(circleId);
  }

  @override
  Future<Circle> create(Circle _circle) async {
    Circle circle = await _circleApi.createCircle(_circle);
    CircleUser circleUser =
    CircleUser(userId: _circle.ownerId, circleId: circle.id);
    await _circleUserApi.createCircleUser(circleUser);
    return circle;
  }

  Future<void> createCircleUser(CircleUser circleUser) async {
    return await _circleUserApi.createCircleUser(circleUser);
  }

  @override
  Future<bool> delete(String circleId) async {
    bool success = false;
    success = await _circleApi.deleteCircle(circleId);
    await _circleUserApi.removeAllMembersFromCircle(circleId);
    _circleRequestApi.removeAllRequestsFromCircle(circleId);
    return success;
  }

  Future<void> removeCircleMember(CircleUser circleUser) async {
    return await _circleUserApi.removeCircleMember(circleUser);
  }

  @override
  Future<void> update(Circle circle) async {
    await _circleApi.updateCircle(circle);
  }

  Future<CircleRequest?> getCircleRequestById(String id) async {
    return await _circleRequestApi.getCircleRequest(id);
  }

  Future<List<CircleRequest>> getCirclesRequestsByUserId(String userId) async {
    return await _circleRequestApi.getAllCircleRequestsByUser(userId);
  }

  Future<List<CircleRequest>> getCircleRequestsInvitations(String userId) async {
    return await _circleRequestApi.getCircleRequestsInvitations(userId);
  }

  Future<CircleRequest> sendCircleRequest(CircleRequest circle) async {
    circle = await _circleRequestApi.createCircleRequest(circle);
    return circle;
  }

  Future<void> deleteCircleRequest(String id) async {
    return await _circleRequestApi.deleteCircleRequest(id);
  }
}
