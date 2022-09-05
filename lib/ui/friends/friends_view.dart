import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/ui/friends/friends_viewmodel.dart';
import 'package:mon_agenda_partage/ui/shared/base_appbar.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:badges/badges.dart';


class FriendsView extends StatefulWidget {
  const FriendsView({Key? key}) : super(key: key);

  @override
  _FriendsViewState createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {

  bool contactPermission = false;
  bool showList = true; // Remove after tests

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FriendsViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: BaseAppBar().getBaseAppBar(
          Text(
            "Friends",
            style: TextStyle(color: Colors.black),
          ),
          optionalBadge: model.isBusy == false
              && model.usersByFriendRequest.length > 0
              ? addFriendBadge(model, context) : null,
          optionalButton: model.isBusy == false
              && model.usersByFriendRequest.length == 0
              ? addFriendIcon(model, context) : null,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: model.isBusy
                ? Align(child: CircularProgressIndicator())
                : Column(
              children: [
                h2("Friend List"),
                verticalSpaceMedium,
                FriendList(model),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: model.inviteContacts,
          child: const Icon(Icons.add),
          backgroundColor: kcPrimaryColor,
        ),
      ),
      viewModelBuilder: () => FriendsViewModel(),
    );

  }

  Badge addFriendBadge(FriendsViewModel model, BuildContext context) {
    return Badge(
        badgeContent: Text(
          model.usersByFriendRequest.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
        position: BadgePosition.topEnd(top: 0, end: 0),
        child: addFriendIcon(model, context)
    );
  }

  IconButton addFriendIcon(FriendsViewModel model, BuildContext context) {
    return IconButton(
        icon: Icon(
            Icons.person_add_alt_1,
            color: Colors.black
        ),
        onPressed: () async {
          if(contactPermission) {
            showDialog(
              context: context,
              builder: (context) {
                return AddFriendsDialog(model, context);
              },
            );
          }
        }
    );
  }

  StatefulBuilder AddFriendsDialog(FriendsViewModel model, BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: Container(
                width: 200,
                height: screenHeightPercentage(context, percentage: 0.8),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                alignment: Alignment.center,
                child:
                Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: h2("Add friend"),
                    ),
                    Divider(),
                    verticalSpaceRegular,
                    AddFriendOptions(setState, model),
                    verticalSpaceRegular,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: h3(
                          model.contactSelected ?
                          "Your contacts" :
                          "Invitations"
                      ),
                    ),
                    titleDivider(),
                    verticalSpaceRegular,
                    model.contactSelected ?
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.usersInApp.length,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return ContactRow(model.usersInApp[index], model, setState);
                        },
                      ),
                    ) :
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.usersByFriendRequest.length,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return InvitationsRow(model.usersByFriendRequest[index], model, setState);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Row AddFriendOptions(StateSetter setState, FriendsViewModel model) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
              onPressed: () {
                setState(() {
                  model.contactSelected = true;
                });
              },
              style: OutlinedButton.styleFrom(
                  primary: model.contactSelected
                      ? Colors.white
                      : kcPrimaryColor,
                  backgroundColor: model.contactSelected
                      ? kcPrimaryColor
                      : Colors.white
              ),
              child: Text("Your contacts")
          ),
        ),
        Expanded(
          child: OutlinedButton(
              onPressed: () {
                setState(() {
                  model.contactSelected = false;
                });
              },
              style: OutlinedButton.styleFrom(
                primary: model.contactSelected
                    ? kcPrimaryColor
                    : Colors.white,
                backgroundColor: model.contactSelected ? Colors
                    .white : kcPrimaryColor,
              ),
              child: Text("Invitations")
          ),
        ),
      ],
    );
  }

  Container ContactRow(User user, FriendsViewModel model, StateSetter setState) {
    bool isExistingInvitationPending = model.isExistingInvitationPending(user.id);

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26)
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle),
          horizontalSpaceSmall,
          Text(user.name!),
          Spacer(),
          !isExistingInvitationPending ?
          IconButton(
              icon: Icon(Icons.add),
              constraints: BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () async {
                await model.toggleFriendRequest(user.id);

                setState(() {
                  isExistingInvitationPending = true;
                });
              }
          ) :
          IconButton(
            icon: Icon(Icons.remove),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            color: Colors.red,
            onPressed: () async {
              await model.toggleFriendRequest(user.id);

              setState(() {
                isExistingInvitationPending = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Container InvitationsRow(User user, FriendsViewModel model, StateSetter setState) {

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26)
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle),
          horizontalSpaceSmall,
          Expanded(
            child: Text(user.name!, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
              icon: Icon(Icons.add),
              constraints: BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () async {
                await model.acceptFriendRequest(user);

                setState(() {

                });
              }
          ),
          horizontalSpaceSmall,
          IconButton(
            icon: Icon(Icons.remove),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            color: Colors.red,
            onPressed: () async {
              await model.deleteFriendRequest(user);

              setState(() {

              });
            },
          ),
        ],
      ),
    );
  }

  FriendList(FriendsViewModel model) {
    return ListView.builder(
      itemCount: model.friends.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return UserRow(model.friends[index], model);
      },
    );
  }

  Container UserRow(User user, FriendsViewModel model) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26)
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle),
          horizontalSpaceSmall,
          Text(user.name!),
          Spacer(),
          FriendPopupSelection(user, model),
        ],
      ),
    );
  }

  PopupMenuButton<int> FriendPopupSelection(User user, FriendsViewModel model) {
    return PopupMenuButton<int>(
      offset: Offset(1, 0),
      icon: Icon(Icons.settings),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Text("Show calendar"),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text("Delete Friend"),
        )
      ],
      onSelected: (item) async {
        switch(item) {
          case 0:
            break;
          case 1:
            showDialog(
              context: context,
              builder: (context) {
                return DeleteFriendConfirmationDialog(model, user.id, context);
              },
            );
            break;
        }
      },
    );
  }

  Dialog DeleteFriendConfirmationDialog(FriendsViewModel model, String userId, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 110,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
        child: Column(
          children: [
            Text("Are you sure you want to delete your friend ?"),
            Spacer(),
            Row(
              children: [
                Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    model.removeFriend(userId);
                    ActionSnackbar(context, "Friend Deleted");
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      ActionSnackbar(context, "Contact Permission granted");
      contactPermission = true;
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
