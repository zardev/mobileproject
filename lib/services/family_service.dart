import 'package:mon_agenda_partage/api/family_api.dart';
import 'package:mon_agenda_partage/api/family_requests_api.dart';
import 'package:mon_agenda_partage/models/Family.dart';
import 'package:mon_agenda_partage/models/FamilyRequest.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/services/crud_service.dart';

class FamilyService implements CrudService<Family> {
  final FamilyApi _familyApi = new FamilyApi();
  final FamilyRequestApi _familyRequestApi = new FamilyRequestApi();

  @override
  Future<List<Family>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Family?> getOneById(String familyId) async {
    if (familyId.isEmpty) return null;
    return await _familyApi.getFamilyById(familyId);
  }

  Future<List<User>> getFamilyMembers(String familyId) async {
    if (familyId.isEmpty) return [];
    return await _familyApi.getFamilyMembersByFamilyId(familyId);
  }

  @override
  Future<Family> create(Family family) async {
    await _familyApi.createFamily(family);
    return family;
  }

  @override
  Future<bool> delete(String familyId) async {
    return await _familyApi.deleteFamily(familyId);
  }

  Future<void> removeFamilyMember(String userId) async {
    return await _familyApi.removeFamilyMemberByUserId(userId);
  }

  @override
  Future<void> update(Family family) async {
    await _familyApi.updateFamily(family);
  }

  Future<FamilyRequest?> getFamilyRequestById(String id) async {
    return await _familyRequestApi.getFamilyRequest(id);
  }

  Future<List<FamilyRequest>> getFamiliesRequestsByUserId(String userId) async {
    return await _familyRequestApi.getAllFamilyRequestsByUser(userId);
  }

  Future<List<FamilyRequest>> getFamiliesInvitations(String userId) async {
    return await _familyRequestApi.getFamilyRequestsInvitations(userId);
  }

  Future<FamilyRequest> sendFamilyRequest(FamilyRequest family) async {
    family = await _familyRequestApi.createFamilyRequest(family);
    return family;
  }

  Future<void> deleteFamilyRequest(String id) async {
    return await _familyRequestApi.deleteFamilyRequest(id);
  }
}
