import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio
    hide Column, Alignment;
import 'package:time_tracker/controller/date_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:time_tracker/model/total.dart';
import 'package:time_tracker/storage/storage.dart';
import '../common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';

class Summary extends StatefulWidget {
  const Summary({Key? key}) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> with AutomaticKeepAliveClientMixin {
  List<String> dayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  late String currentDate;
  late String currentDateTop;

  late PageController _pageController;

  late List<String> futureDateList = [];

  bool isLoaded = false;

  Future<bool> getDaysFromStorage() async {
    var list = await Storage().getDays();

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

    setState(() {
      futureDateList = list;
      isLoaded = true;
    });

    _pageController =
        PageController(initialPage: futureDateList.indexOf(currentDate));

    return true;
  }

  Future<List<Total>> loadTotalList(String date) async {
    return await Storage().totalByDate(date);
  }

  @override
  void initState() {
    super.initState();

    var today = DateTime.now();
    currentDate = ymdToString(today);
    currentDateTop = getFormatted(today);

    getDaysFromStorage();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onDatePicked(c) {
    _panelController.close();
    setState(() {
      currentDate = ymdToString(c);
      currentDateTop = getFormatted(c);
      _pageController.jumpToPage(futureDateList.indexOf(currentDate));
    });
  }

  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SlidingUpPanel(
        color: Colors.transparent,
        controller: _panelController,
        backdropColor: Colors.grey,
        renderPanelSheet: true,
        backdropEnabled: true,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        panel: isLoaded == true
            ? DatePicker(
                callback: _onDatePicked, minDate: ymdToDate(futureDateList[0]))
            : const Center(child: CircularProgressIndicator()),
        body: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarTextStyle: const TextStyle(color: Colors.white),
            foregroundColor: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.5).withAlpha(200),
            centerTitle: true,
            title: Text(
              currentDateTop,
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
                onPressed: _generateExcel,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: isLoaded == true
                  ? DefaultTabController(
                      initialIndex: futureDateList.length - 1,
                      length: futureDateList.length,
                      child: TabBar(
                        physics: const PageScrollPhysics(),
                        isScrollable: true,
                        onTap: (index) {
                          _pageController.jumpToPage(index);
                          setState(() {
                            currentDate = futureDateList[index];
                            currentDateTop =
                                getFormatted(ymdToDate(currentDate));
                          });
                        },
                        tabs: futureDateList
                            .map((i) => Tab(
                                  icon: Icon(Icons.circle_outlined,
                                      color: i == currentDate
                                          ? Colors.amber
                                          : Colors.grey),
                                  child: Text(
                                    dayList[ymdToDate(i).weekday - 1]
                                        .substring(0, 2),
                                  ),
                                ))
                            .toList(),
                        automaticIndicatorColorAdjustment: true,
                        indicatorColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.white,
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Loading...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
          body: isLoaded == true
              ? PageView.builder(
                  itemCount: futureDateList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() {
                      currentDate = futureDateList[i];
                      currentDateTop = getFormatted(ymdToDate(currentDate));
                    });
                  },
                  itemBuilder: (context, index) {
                    return _getGraphicBox(futureDateList[index]);
                  },
                )
              : const Center(child: CircularProgressIndicator()),
        ));
  }

  Widget _getGraphicBox(String date) {
    return FutureBuilder<List<Total>>(
        future: loadTotalList(date),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SfCircularChart(
                      title: ChartTitle(
                        text: date,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        orientation: LegendItemOrientation.horizontal,
                        position: LegendPosition.bottom,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      series: <PieSeries<Total, String>>[
                        PieSeries<Total, String>(
                          explode: true,
                          explodeAll: true,
                          explodeIndex: 0,
                          explodeOffset: '5%',
                          dataSource: snapshot.data,
                          xValueMapper: (Total data, _) => data.category,
                          yValueMapper: (Total data, _) => data.total,
                          dataLabelMapper: (Total data, _) =>
                              "${data.category} \n ${data.total}",
                          startAngle: 90,
                          endAngle: 90,
                          dataLabelSettings: const DataLabelSettings(
                            color: Colors.white,
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            showCumulativeValues: true,
                            showZeroValue: true,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: snapshot.data.map<Widget>(
                          (d) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 60),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${d.category}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      toHMS(d.seconds),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Future<void> _generateExcel() async {
    //Create a Excel document.

    //Creating a workbook.
    final xlsio.Workbook workbook = xlsio.Workbook();
    //Accessing via index
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.name = 'Document';
    sheet.showGridlines = true;
    sheet.enableSheetCalculations();

    int lastRow = futureDateList.length + 1;
    int lastColumn = 0;

    List<int> categoryTotals = [];

    for (int i = 0; i < futureDateList.length; i++) {
      var dayInfo = await loadTotalList(futureDateList[i]);
      dayInfo.sort((b, a) => a.category.compareTo(b.category));
      lastColumn = dayInfo.length + 1;

      for (int j = 0; j <= dayInfo.length; j++) {
        String columnName = String.fromCharCode(65 + j) + "${i + 1}";

        if (i == 0) {
          categoryTotals = List.filled(lastColumn - 1, 0);

          if (j == 0) {
            sheet.getRangeByName(columnName).text = dayInfo[j].date;
            continue;
          }

          sheet.getRangeByName(columnName).text = dayInfo[j - 1].category;
          sheet.getRangeByName(columnName).columnWidth = 22.27;

          continue;
        }

        if (j == 0) {
          sheet.getRangeByName(columnName).text = dayInfo[j].date;
          continue;
        }

        int seconds = dayInfo[j - 1].seconds;

        categoryTotals[j - 1] += seconds;

        sheet.getRangeByName(columnName).text = toHMS(seconds);
      }
    }

    String lastColumnChar = String.fromCharCode(65 + lastColumn);

    String titleColor = 'A1:${lastColumnChar}1';
    sheet.getRangeByName(titleColor).cellStyle.backColor = '#C6E0B4';
    sheet.getRangeByName(titleColor).cellStyle.bold = true;

    String totalColor = "A$lastRow:$lastColumnChar$lastRow";

    sheet.getRangeByName(totalColor).cellStyle.backColor = '#C6E0B4';
    sheet.getRangeByName(totalColor).cellStyle.bold = true;

    sheet.getRangeByName("A1").text = "days";
    sheet.getRangeByName("A1").columnWidth = 22.27;

    sheet.getRangeByName("A$lastRow").text = "total";

    for (int i = 0; i < categoryTotals.length; i++) {
      String columnName = String.fromCharCode(65 + i + 1) + "$lastRow";
      sheet.getRangeByName(columnName).text = toHMS(categoryTotals[i]);
    }

    final List<int> bytes = workbook.saveAsStream();

    workbook.dispose();
    //Launch file.
    await FileSaveHelper.saveAndLaunchFile(bytes, 'Document.xlsx');
  }

  // Create styles for worksheet

  @override
  bool get wantKeepAlive => true;
}

class FileSaveHelper {
  static const MethodChannel _platformCall = MethodChannel('launchFile');

  ///To save the pdf file in the device
  static Future<void> saveAndLaunchFile(
      List<int> bytes, String fileName) async {
    String? path;

    final Directory directory = await getApplicationSupportDirectory();
    path = directory.path;

    final File file =
        File(Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    if (Platform.isAndroid || Platform.isIOS) {
      final Map<String, String> argument = <String, String>{
        'file_path': '$path/$fileName'
      };
      try {
        //ignore: unused_local_variable
        final Future<Map<String, String>?> result =
            _platformCall.invokeMethod('viewExcel', argument);
      } catch (e) {
        throw Exception(e);
      }
    } else if (Platform.isWindows) {
      await Process.run('start', <String>['$path\\$fileName'],
          runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>['$path/$fileName'], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>['$path/$fileName'],
          runInShell: true);
    }
  }
}
