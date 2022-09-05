import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:mon_agenda_partage/models/User.dart' as AppUser;
import 'package:permission_handler/permission_handler.dart';

class FireAuth {

  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      final String mobileNumber = await getMobileNumber();
      await createUserDocument(new AppUser.User(
        id: user!.uid,
        name: name,
        email: user.email!,
        phoneNumber: mobileNumber,
      ));
      await user.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return user;
  }

  static Future<String> getMobileNumber() async {
    PermissionStatus permission = await Permission.phone.status;
    if (permission != Permission.phone.isGranted) {
      await Permission.phone.request();
    }

    final List<SimCard> simCards = (await MobileNumber.getSimCards)!;

    return simCards[0].number!;

  }

  static Future<void> createUserDocument(AppUser.User user) async {
    CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");

    return usersCollection
        .doc(user.id)
        .set({
      "id": user.id,
      "name": user.name,
      "email": user.email,
      "phoneNumber": user.phoneNumber,
      "familyId": "",
      "selectedCircle": "",
      "privateCalendar": false,
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Error while creating User $error"));
  }

  // For signing in an user (have already registered)
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
