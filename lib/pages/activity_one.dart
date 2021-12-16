import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker/components/date_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ActivityOne extends StatefulWidget {
  const ActivityOne({Key? key}) : super(key: key);

  @override
  State<ActivityOne> createState() => _ActivityOneState();
}

class _ActivityOneState extends State<ActivityOne>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<String> dayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  String currentDate = "";
  String currentDatePrint = "";
  late int index;
  late int todaysIndex;
  late List<String> dateList;
  late DateTime today;

  getSortedDateList() {
    List<String> list = [
      "2021/12/13",
      "2021/12/14",
      "2021/12/15",
      currentDate,
    ];

    todaysIndex = list.length - 1;

    int missingCount = 6 - todaysIndex % 7;

    for (int i = 0; i < missingCount; i++) {
      list.add(ymdToString(today.add(Duration(days: i + 1))));
    }

    list.sort();
    return list;
  }

  @override
  void initState() {
    super.initState();

    today = DateTime.now();
    currentDate = ymdToString(today);
    currentDatePrint = getFormatted(today);
    index = today.weekday - 1;

    dateList = getSortedDateList();

    tabController = TabController(
        vsync: this, length: dateList.length, initialIndex: todaysIndex);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
      //  tabController.animateTo(tabController.index, duration: const Duration(seconds:10), curve: Curves.linear);

        setState(() {
          currentDate = dateList[tabController.index];
          currentDatePrint = getFormatted(ymdToDate(currentDate));
          index = tabController.index % 7;
        });

      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _onDatePicked(c) {
    _panelController.close();
    setState(() {
      currentDate = ymdToString(c);
      currentDatePrint = getFormatted(c);
      index = c.weekday - 1;
      tabController.animateTo(dateList.indexOf(currentDate));
    });
  }

  ymdToDate(String string) {
    return DateFormat("yyyy/MM/dd").parse(string);
  }

  String ymdToString(DateTime date) {
    return DateFormat("yyyy/MM/dd").format(date);
  }

  String getFormatted(DateTime date) {
    return DateFormat.yMMMEd().format(date);
  }

  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      color: Colors.transparent,
      controller: _panelController,
      backdropColor: Colors.grey,
      renderPanelSheet: true,
      backdropEnabled: true,
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      panel: DatePicker(
        callback: _onDatePicked,
        minDate: ymdToDate(dateList[0]),
      ),
      body: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarTextStyle: const TextStyle(color: Colors.white),
          foregroundColor: Colors.white,
          backgroundColor: Colors.black.withOpacity(0.5).withAlpha(200),
          centerTitle: true,
          title: Text(
            currentDatePrint,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.amber),
              onPressed: () {
                //TODO change this
                _panelController.open();
              },
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              //TODO print("Implement share");
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: dayList
                      .map((d) => SizedBox(
                            width: 30,
                            // padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                d[0],
                                style: TextStyle(
                                  color: index == dayList.indexOf(d)
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                TabBar(
                  enableFeedback:true,
                  physics: PageScrollPhysics(),
                  dragStartBehavior: DragStartBehavior.start,
                  isScrollable: true,
                  controller: tabController,
                  tabs: dateList
                      .map((i) => Tab(
                            icon: Icon(Icons.circle_outlined,
                                color: dateList.indexOf(i)%7 == index
                                    ? Colors.amber
                                    : Colors.grey),
                            child: Container(
                                child: const Text(
                              "hey",
                              style: TextStyle(color: Colors.white),
                            )),
                          ))
                      .toList(),
                  automaticIndicatorColorAdjustment: false,
                  indicatorColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: tabController,
              children: dateList.map((d) {
                return ListView(
                  children: [
                    Text(
                      d,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const Text(
                      "Graphics will be here",
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
