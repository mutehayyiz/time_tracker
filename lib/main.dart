import 'package:flutter/material.dart';
import 'package:time_tracker/pages/summary.dart';
import 'package:time_tracker/pages/category.dart';
import 'pages/profile.dart';

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
  int selectedTab = 0;

  getSelectedTab() {
    var screens = [
      const CategoriesPage(),
      const Summary(),
      ProfilePage(),
    ];

    return screens[selectedTab];
  }

  // secondary

  @override
  void initState() {
    super.initState();
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
            icon: Icon(Icons.credit_card),
            label: "summary",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
            label: "profile",
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
