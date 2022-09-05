import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mon_agenda_partage/api/fire_auth.dart';
import 'package:mon_agenda_partage/models/Family.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:mon_agenda_partage/services/family_service.dart';
import 'package:logger/logger.dart';
import 'package:mon_agenda_partage/services/user_service.dart';

class FamilyViewModel extends ChangeNotifier {
  final FamilyService familyService = FamilyService();
  final UserService userService = UserService();
  FirebaseAuth auth = FirebaseAuth.instance;
  final logger = Logger(
    filter: null,
    printer: PrettyPrinter(
        methodCount: 0
    ),
    output: null,
  );

  Family? family;
  AppUser.User? currentUser;
  AppUser.User? familyOwnerUser;
  List<AppUser.User> familyMembers = [];
  bool isBusy = true;


  Future<void> initialize() async {
    currentUser = await userService.getOneById(auth.currentUser!.uid);

    if (currentUser != null) {
      logger.v({"Current User" : currentUser!.toJson()});
      await getFamily();
      this.notifyListeners();
    } else {
      logger.e("User not found !");
    }
    isBusy = false;
  }

  Future<void> getFamily() async {
    family = await familyService.getOneById(currentUser!.familyId!);

    if (family != null) {
      logger.v({"Family" : family!.toJson()});
      await getFamilyOwner();
      await getFamilyMembers();
    } else {
      logger.i("Family not found !");

    }
  }

  Future<void> getFamilyOwner() async {
    familyOwnerUser = await userService.getOneById(family!.ownerId);

    if(familyOwnerUser != null) {
      logger.v({"Family owner" : familyOwnerUser!.toJson()});
    } else {
      logger.e("Error finding family owner");
    }
  }

  Future<void> getFamilyMembers() async {
    familyMembers = await familyService.getFamilyMembers(family!.id!);

    if(familyMembers.length > 0) {
      logger.v("User list count : " + familyMembers.length.toString());
    } else {
      logger.e("Error getting family members, family members count : " + familyMembers.length.toString());
    }
  }

  Future<void> removeFamilyMember(String userId) async {
    await familyService.removeFamilyMember(userId);
    AppUser.User deletedUser;

    try {
      deletedUser = familyMembers.firstWhere((user) => user.id == userId);
    } on StateError {
      logger.w("No user match");
      return;
    }

    familyMembers.remove(deletedUser);
    this.notifyListeners();
  }

  Future<void> createFamily(Family _family) async {
    await familyService.create(_family);
  }

  Future<void> editFamily(Family _family) async {
    _family.setId(family!.id!);
    await familyService.update(_family);
    family!.name = _family.name;
    this.notifyListeners();
  }

  Future<void> deleteFamily() async {
    if (family!.id!.isNotEmpty) {
      familyService.delete(family!.id!);
      family = null;
      this.notifyListeners();
    } else {
      logger.e("No family has been found for current user");
    }
  }
}
