import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mon_agenda_partage/models/Family.dart';
import 'package:mon_agenda_partage/models/User.dart';
import 'package:mon_agenda_partage/ui/family/family_viewmodel.dart';
import 'package:mon_agenda_partage/ui/shared/base_appbar.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

class FamilyView extends StatefulWidget {
  const FamilyView({Key? key}) : super(key: key);

  @override
  _FamilyViewState createState() => _FamilyViewState();
}

class _FamilyViewState extends State<FamilyView> {

  bool deleteConfirmationAlert = false;
  late final familyNameController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar().getBaseAppBar(Text(
        "Family",
        style: TextStyle(color: Colors.black),
      )),
      body: ViewModelBuilder<FamilyViewModel>.reactive(
        onModelReady: (model) => model.initialize(),
        builder: (context, model, child) => SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: model.isBusy
                ? Align(child: CircularProgressIndicator())
                : Column(
              children: [
                model.family != null ? TitlePopupSelection(model) : h2("Create or join a family"),
                verticalSpaceMedium,
                model.family != null ? FamilyUI(model) : NoFamilyUI(model),
              ],
            ),
          ),
        ),
        viewModelBuilder: () => FamilyViewModel(),
      ),
    );
  }

  PopupMenuButton<int> TitlePopupSelection(FamilyViewModel model) {
    return PopupMenuButton<int>(
      offset: Offset(1, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          h2(model.family!.name),
          Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Text("Edit Family"),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text("Delete Family"),
        )
      ],
      onSelected: (item) async {
        switch(item) {
          case 0:
            showDialog(
              context: context,
              builder: (context) {
                familyNameController.text = model.family!.name;
                return EditFamilyNameDialog(model, context);
              },
            );
            break;
          case 1:
            showDialog(
              context: context,
              builder: (context) {
                familyNameController.text = "";
                return DeleteFamilyConfirmationDialog(model, context);
              },
            );
            break;
        }
      },
    );
  }

  FamilyUI(FamilyViewModel model) {
    return ListView.builder(
      itemCount: model.familyMembers.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return UserRow(model.familyMembers[index], model);
      },
    );
  }

  NoFamilyUI(FamilyViewModel model) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h3("Create a family"),
          titleDivider(),
          verticalSpaceRegular,
          Form(
            key: _formKey,
            child: Column(
              children: [
                FamilyNameInput(),
                verticalSpaceRegular,
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_formKey.currentState!.validate()) {
                        Family family = Family(name: familyNameController.text, ownerId: model.currentUser!.id);
                        await model.createFamily(family);
                        ActionSnackbar(context, "Family Created");
                        setState(() async {
                          await model.initialize();
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
        ],
      ),
    );
  }

  TextFormField FamilyNameInput() {
    return TextFormField(
      decoration: InputDecoration(border: null, labelText: "Family Name"),
      controller: familyNameController,
      validator: (familyName) {
        if (familyName == null || familyName.isEmpty) {
          return 'Family name should not be empty';
        }
        if (familyName.length < 3) {
          return 'Family name should be at least 3 characters';
        }
        return null;
      },
    );
  }

  Container UserRow(User user, FamilyViewModel model) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26)
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle),
          horizontalSpaceSmall,
          Text(user.email!),
          Spacer(),
          if (model.familyOwnerUser!.id == user.id) Icon(Icons.admin_panel_settings),
          if (model.familyOwnerUser!.id == model.currentUser!.id
              && user.id != model.currentUser!.id) IconButton(
            icon: Icon(Icons.remove),
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            splashRadius: 20,
            color: Colors.red,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DeleteConfirmationDialog(model, user.id, context),
            ),
          ),
        ],
      ),
    );
  }

  Dialog DeleteConfirmationDialog(FamilyViewModel model, String userId, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 100,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("Are you sure you want to delete this family member ?"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await model.removeFamilyMember(userId);
                        Navigator.pop(context);
                        ActionSnackbar(context, "Family member removed");
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

  Dialog EditFamilyNameDialog(FamilyViewModel model, BuildContext context) {
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
                controller: familyNameController,
                validator: (familyName) {
                  if (familyName == null || familyName.isEmpty) {
                    return 'Family name should not be empty';
                  }
                  if (familyName.length < 3) {
                    return 'Family name should be at least 3 characters';
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
                      Family family = Family(name: familyNameController.text, ownerId: model.family!.ownerId);
                      await model.editFamily(family);
                      Navigator.pop(context);
                      ActionSnackbar(context, "Family Edited");
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

  Dialog DeleteFamilyConfirmationDialog(FamilyViewModel model, BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 110,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
        child: Column(
          children: [
            Text("Are you sure you want to delete your family ?"),
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
                    model.deleteFamily();
                    ActionSnackbar(context, "Family Deleted");
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
}