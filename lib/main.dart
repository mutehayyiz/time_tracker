
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/pages/activity_one.dart';
import 'package:time_tracker/pages/category.dart';
import 'common.dart';
import 'controller/remote.dart';
import 'model/category.dart';
import 'model/entry.dart';
import 'controller/provider.dart';
import 'model/total.dart';
import 'pages/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) {
        return StateManager();
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),

      home: const TimeTrackerApp(),
      //home: const Home(),
    );
  }
}

class TimeTrackerApp extends StatefulWidget {
  const TimeTrackerApp({Key? key}) : super(key: key);

  @override
  _TimeTrackerAppState createState() => _TimeTrackerAppState();
}

class _TimeTrackerAppState extends State<TimeTrackerApp> {

  int selectedTab = 0;
  late List<String> dateList = [];
  late List<List<Total>> totalList = [];
  late List<Category> categoryList = [];

  getSelectedTab() {
    if (selectedTab == 2) {
      return ActivityOne(
        dateList : dateList,
        totalList: totalList,
      );
    }
    var screens =  [
      Home(),
      const CategoriesPage(),
    ];

    return screens[selectedTab];
  }


  // secondary
  Map<String, List<Entry>> allData = <String, List<Entry>>{};

  @override
  void initState() {
    super.initState();
    getDaysFromRemote();
  }

  getDaysFromRemote() async {
    var list = await Remote().getDays();

    var currentDate = ymdToString(DateTime.now());
    if (!list.contains(currentDate)) {
      list.add(currentDate);
    }

    list.sort();

    var min = ymdToDate(list[0]);

    for (int i = 1; i < list.length; i++) {
      var exists = ymdToString(min.add(Duration(days: i)));
      if (!list.contains(exists)) {
        list.add(exists);
      }
    }
    list.sort();

    List<List<Total>> ttList = [];
    for (int i = 0; i < list.length; i++) {
      var tlist = await Remote().totalByDate(list[i]);
      ttList.add(tlist);
    }

    setState(() {
      dateList = list;
      totalList = ttList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "card",
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        showUnselectedLabels: true,
        iconSize: 30,
      ),
      body: getSelectedTab(),
    );
  }
}
