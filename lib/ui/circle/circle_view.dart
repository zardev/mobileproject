import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mon_agenda_partage/models/Circle.dart';
import 'package:mon_agenda_partage/models/CircleRequest.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/ui/circle/circle_viewmodel.dart';
import 'package:mon_agenda_partage/ui/shared/base_appbar.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class CircleView extends StatefulWidget {
  const CircleView({Key? key}) : super(key: key);

  @override
  _CircleViewState createState() => _CircleViewState();
}

class _CircleViewState extends State<CircleView> {

  bool deleteConfirmationAlert = false;
  late final circleNameController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CircleViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) =>  Scaffold(
        appBar: BaseAppBar().getBaseAppBar(Text(
          "Circle",
          style: TextStyle(color: Colors.black),
        ),
          optionalBadge: model.isBusy == false
              && model.pendingInvitationsReceived.length > 0
              && model.selectedCircle != null
              ? addCircleBadge(model, context) : null,
          optionalButton: model.isBusy == false
              && model.pendingInvitationsReceived.length == 0
              && model.selectedCircle != null
              ? addCircleIcon(model, context) : null,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: model.isBusy
                ? Align(child: CircularProgressIndicator())
                : Column(
              children: [
                model.selectedCircle != null
                    ? TitlePopupSelection(model)
                    : h2("Create or join a circle"),
                verticalSpaceMedium,
                model.selectedCircle != null
                    ? CircleUI(model)
                    : NoCircleUI(model),
              ],
            ),
          ),
        ),
      ),
      viewModelBuilder: () => CircleViewModel(),
    );
  }

  Badge addCircleBadge(CircleViewModel model, BuildContext context) {
    return Badge(
        badgeContent: Text(
          model.pendingInvitationsReceived.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
        position: BadgePosition.topEnd(top: 0, end: 0),
        child: addCircleIcon(model, context)
    );
  }

  IconButton addCircleIcon(CircleViewModel model, BuildContext context) {
    return IconButton(
        icon: Icon(
            Icons.group_add,
            color: Colors.black
        ),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AddFriendsDialog(model, context);
            },
          );
        }
    );
  }

  StatefulBuilder AddFriendsDialog(CircleViewModel model, BuildContext context) {
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
                      child: h2("Add friend in circle"),
                    ),
                    Divider(),
                    AddFriendInCircleOptions(setState, model),
                    verticalSpaceRegular,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: h3(
                          model.friendRowSelected ?
                          "Your friends" :
                          "Invitations"
                      ),
                    ),
                    titleDivider(),
                    verticalSpaceRegular,
                    model.friendRowSelected ?
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.friendsNotInCircle.length,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return FriendsRow(model.friendsNotInCircle[index], model, setState);
                        },
                      ),
                    ) :
                    Expanded(
                      child: ListView.builder(
                        itemCount: model.pendingInvitationsReceived.length,
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          return InvitationsRow(model.pendingInvitationsReceived[index], model, setState);
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

  PopupMenuButton<int> TitlePopupSelection(CircleViewModel model) {
    return PopupMenuButton<int>(
      offset: Offset(1, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          h2(model.selectedCircle!.name!),
          Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Text("Select Circle"),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text("Create Circle"),
        ),
        if (model.currentUser!.id == model.circleOwnerUser!.id)
          PopupMenuItem<int>(
            value: 2,
            child: Text("Edit Circle"),
          ),
        if (model.currentUser!.id == model.circleOwnerUser!.id)
          PopupMenuItem<int>(
            value: 3,
            child: Text("Delete Circle"),
          ),
        if (model.currentUser!.id != model.circleOwnerUser!.id)
          PopupMenuItem<int>(
            value: 4,
            child: Text("Leave Circle"),
          ),
      ],
      onSelected: (item) async {
        switch(item) {
          case 0:
            selectCircleModal(model);
            break;
          case 1:
            showDialog(
              context: context,
              builder: (context) {
                circleNameController.text = model.selectedCircle!.name!;
                return CreateCircleDialog(model, context);
              },
            );
            break;
          case 2:
            showDialog(
              context: context,
              builder: (context) {
                circleNameController.text = model.selectedCircle!.name!;
                return EditCircleNameDialog(model, context);
              },
            );
            break;
          case 3:
            showDialog(
              context: context,
              builder: (context) {
                return DeleteCircleConfirmationDialog(model, context);
              },
            );
            break;
          case 4:
            showDialog(
              context: context,
              builder: (context) {
                return DeleteUserFromAgendaConfirmationDialog(model, model.currentUser!.id, context);
              },
            );
            break;
        }
      },
    );
  }

  selectCircleModal(CircleViewModel model) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                  padding: EdgeInsets.only(left: 10),
                  itemCount: model.circleListByUser.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: ListTile(
                        title: h3(model.circleListByUser[index].name!),
                        subtitle: Text(model.getCircleMembersByIndex(index).length.toString() + " Members"),
                      ),
                      onTap: () {
                        model.selectCircle(model.circleListByUser[index]);
                        Navigator.pop(context);
                      },
                    );
                  }),
            ],
          );
        });
  }

  Dialog CreateCircleDialog(CircleViewModel model, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 150,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        alignment: Alignment.center,
        child:
        Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(border: null, labelText: "Circle name..."),
                controller: circleNameController,
                validator: (circleName) {
                  if (circleName == null || circleName.isEmpty) {
                    return 'Circle name should not be empty';
                  }
                  if (circleName.length < 3) {
                    return 'Circle name should be at least 3 characters';
                  }
                  return null;
                },
              ),
            ),
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
                    if(_formKey.currentState!.validate()) {
                      Circle circle = Circle(
                          name: circleNameController.text,
                          ownerId: model.currentUser!.id);
                      await model.createCircle(circle);
                      Navigator.pop(context);
                      ActionSnackbar(context, "Circle Created");
                    }
                  },
                  child: Text("Create", style: TextStyle(color: kcPrimaryColor)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Row AddFriendInCircleOptions(StateSetter setState, CircleViewModel model) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
              onPressed: () {
                setState(() {
                  model.friendRowSelected = true;
                });
              },
              style: OutlinedButton.styleFrom(
                  primary: model.friendRowSelected
                      ? Colors.white
                      : kcPrimaryColor,
                  backgroundColor: model.friendRowSelected
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
                  model.friendRowSelected = false;
                });
              },
              style: OutlinedButton.styleFrom(
                primary: model.friendRowSelected
                    ? kcPrimaryColor
                    : Colors.white,
                backgroundColor: model.friendRowSelected ? Colors
                    .white : kcPrimaryColor,
              ),
              child: Text("Invitations")
          ),
        ),
      ],
    );
  }

  Container FriendsRow(User user, CircleViewModel model, StateSetter setState) {
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

  Container InvitationsRow(CircleRequest circleRequest, CircleViewModel model, StateSetter setState) {

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
            child: Text(model.getCircleNameById(circleRequest.circleId!) +
                " (" + model.getUsernameById(circleRequest.senderId!) + ")",
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
              icon: Icon(Icons.add),
              constraints: BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () async {
                await model.acceptCircleRequest(circleRequest);
                if(model.selectedCircle != null) Navigator.of(context, rootNavigator: true).pop('dialog');
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
              await model.deleteCircleRequest(circleRequest);

              setState(() {

              });
            },
          ),
        ],
      ),
    );
  }

  Dialog EditCircleNameDialog(CircleViewModel model, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 150,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        alignment: Alignment.center,
        child:
        Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(border: null, labelText: "Edit Name..."),
                controller: circleNameController,
                validator: (circleName) {
                  if (circleName == null || circleName.isEmpty) {
                    return 'Circle name should not be empty';
                  }
                  if (circleName.length < 3) {
                    return 'Circle name should be at least 3 characters';
                  }
                  return null;
                },
              ),
            ),
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
                    if(_formKey.currentState!.validate()) {
                      Circle circle = Circle(
                          name: circleNameController.text,
                          ownerId: model.selectedCircle!.ownerId);
                      await model.editCircle(circle);
                      Navigator.pop(context);
                      ActionSnackbar(context, "Circle Edited");
                    }
                  },
                  child: Text("Edit", style: TextStyle(color: kcPrimaryColor)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Dialog DeleteCircleConfirmationDialog(CircleViewModel model, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 110,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
        child: Column(
          children: [
            Text("Are you sure you want to delete your circle ?"),
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
                    model.deleteCircle();
                    ActionSnackbar(context, "Circle Deleted");
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

  CircleUI(CircleViewModel model) {
    return ListView.builder(
      itemCount: model.selectedCircleMembers.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return UserRow(model.selectedCircleMembers[index], model);
      },
    );
  }

  NoCircleUI(CircleViewModel model) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h3("Create a circle"),
          titleDivider(),
          verticalSpaceRegular,
          Form(
            key: _formKey,
            child: Column(
              children: [
                CircleNameInput(),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_formKey.currentState!.validate()) {
                        Circle circle = Circle(
                            name: circleNameController.text,
                            ownerId: model.currentUser!.id);
                        await model.createCircle(circle);
                        ActionSnackbar(context, "Circle Created");
                        await model.initialize();
                        setState(() {

                        });
                      }
                    },
                    child: Text("Create"),
                    style: ElevatedButton.styleFrom(
                        primary: kcPrimaryColor
                    ),
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceRegular,
          h3("Invitations pending"),
          titleDivider(),
          verticalSpaceRegular,
          ListView.builder(
            itemCount: model.pendingInvitationsReceived.length,
            shrinkWrap: true,
            itemBuilder: (context, int index) {
              return InvitationsRow(model.pendingInvitationsReceived[index], model, setState);
            },
          ),
        ],
      ),
    );
  }

  TextFormField CircleNameInput() {
    return TextFormField(
      decoration: InputDecoration(border: null, labelText: "Circle Name"),
      controller: circleNameController,
      validator: (circleName) {
        if (circleName == null || circleName.isEmpty) {
          return 'Circle name should not be empty';
        }
        if (circleName.length < 3) {
          return 'Circle name should be at least 3 characters';
        }
        return null;
      },
    );
  }

  Container UserRow(User user, CircleViewModel model) {
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
          if (model.circleOwnerUser!.id == user.id) Icon(Icons.admin_panel_settings),
          if (model.circleOwnerUser!.id == model.currentUser!.id
              && user.id != model.currentUser!.id) IconButton(
            icon: Icon(Icons.remove),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            color: Colors.red,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DeleteUserFromAgendaConfirmationDialog(model, user.id, context),
            ),
          ),
        ],
      ),
    );
  }

  Dialog DeleteUserFromAgendaConfirmationDialog(
      CircleViewModel model, String userId, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 125,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              model.currentUser!.id == userId ?
              Text("Are you sure you want to leave this circle ?") :
              Text("Are you sure you want to delete this circle member ?"),
              verticalSpaceRegular,
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await model.removeCircleMember(userId);
                        Navigator.pop(context);
                        ActionSnackbar(context, "Circle member removed");
                        if (model.currentUser!.id == userId) model.initialize();
                      },
                      child: Text("Yes"),
                      style: ElevatedButton.styleFrom(
                          primary: kcPrimaryColor
                      ),
                    ),
                  ),
                  horizontalSpaceLarge,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("No"),
                      style: ElevatedButton.styleFrom(
                          primary: kcPrimaryColor
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}