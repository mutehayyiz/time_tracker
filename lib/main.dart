import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker/model/category.dart';
import 'package:time_tracker/pages/activity_one.dart';
import 'package:time_tracker/pages/category.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
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
  var screens = const [
   // Home(),
    CategoriesPage(),
    ActivityOne(),

  ];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "home",
          ),
           */
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
      body: screens[selectedTab],
    );
  }
}
