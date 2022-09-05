import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mon_agenda_partage/ui/calendar/month/month_view.dart';
import 'package:mon_agenda_partage/ui/family/family_view.dart';
import 'package:mon_agenda_partage/ui/friends/friends_view.dart';
import 'package:mon_agenda_partage/ui/home/home_viewmodel.dart';
import 'package:mon_agenda_partage/ui/shared/base_appbar.dart';
import 'package:mon_agenda_partage/ui/shared/styles.dart';
import 'package:mon_agenda_partage/ui/shared/ui_helpers.dart';
import 'package:mon_agenda_partage/ui/circle/circle_view.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar().getBaseAppBar(Text(
        "Home",
        style: TextStyle(color: Colors.black),
      )),
      body: ViewModelBuilder<HomeViewModel>.reactive(
        builder: (context, model, child) => Container(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 40,
            crossAxisSpacing: 40,
            children: [
              HomeCardBuilder(
                  title: "Calendar",
                  icon: Icons.calendar_today,
                  background: Colors.blue,
                  navigateToView: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MonthView())
                  )
              ),
              HomeCardBuilder(
                  title: "Family",
                  icon: Icons.family_restroom_outlined,
                  background: kcPrimaryColor,
                  navigateToView: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FamilyView())
                  )
              ),
              HomeCardBuilder(
                  title: "Friends",
                  icon: Icons.calendar_today,
                  background: kcPrimaryColor,
                  navigateToView: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FriendsView())
                  )
              ),
              HomeCardBuilder(
                  title: "Circles",
                  icon: Icons.calendar_today,
                  background: kcPrimaryColor,
                  navigateToView: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CircleView())
                  )
              ),
              HomeCardBuilder(
                  title: "Settings",
                  icon: Icons.calendar_today,
                  background: kcPrimaryColor,
                  navigateToView: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView())
                  )
              ),
            ],
          ),
        ),
        viewModelBuilder: () => HomeViewModel(),
      ),
    );
  }

  GestureDetector HomeCardBuilder({title: String, background: Color, icon: Icon, navigateToView: Function}) {
    return GestureDetector(
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: background
            ),
            child: Column(
              children: [
                SizedBox(height: 35),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        onTap: navigateToView
    );
  }
}
