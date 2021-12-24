
import 'dart:io';
import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio hide  Column, Alignment;
import 'package:syncfusion_officechart/officechart.dart';
import 'package:time_tracker/components/date_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:time_tracker/model/total.dart';
import 'package:time_tracker/pages/pdf.dart';
import 'package:time_tracker/storage/storage.dart';
import '../common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';


class ActivityOne extends StatefulWidget {
  final List<List<Total>> totalList;
  final List<String> dateList;


  const ActivityOne({Key? key,required this.dateList, required this.totalList}) : super(key: key);

  @override
  State<ActivityOne> createState() => _ActivityOneState();
}

class _ActivityOneState extends State<ActivityOne>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  late Future<List<List<Total>>> futureTotalList;

  List<String> dayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  late int index;
  late String currentDate;
  late String currentDateTop;
  late List<String> dateList = [];
  late List<List<Total>> totalList = [];

  loadTotalList() async{
    futureTotalList = Storage().getDays();
  }

  @override
  void initState() {
    super.initState();

    totalList = widget.totalList;
    dateList = widget.dateList;

    var today = DateTime.now();
    currentDate = ymdToString(today);
    currentDateTop = getFormatted(today);

    index = dateList.indexOf(currentDate);
/*
    for(int i=0;i< totalList.length; i++){
      for(int j=0;j<totalList[i].length;j++){
        String columnName=String.fromCharCode(65+j)+"${i+2}";

        print(columnName + " : ${totalList[i][j].total}  :  ${totalList[i][j].category}");
      }
    }


 */

    initTabController();
  }

  initTabController(){
    tabController = TabController(
        vsync: this, length: dateList.length, initialIndex: index);

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          currentDate = dateList[tabController.index];
          currentDateTop = getFormatted(ymdToDate(currentDate));
          index = tabController.index;
        });
      }
      // Tab Changed swiping
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
      currentDateTop = getFormatted(c);
      tabController.animateTo(dateList.indexOf(currentDate));
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TabBar(
                  physics: const PageScrollPhysics(),
                  isScrollable: true,
                  onTap: (x) {
                    setState(() {
                      index = x;
                    });
                  },
                  controller: tabController,
                  tabs: dateList
                      .map((i) => Tab(
                    icon: Icon(Icons.circle_outlined,
                        color: dateList.indexOf(i) == index
                            ? Colors.amber
                            : Colors.grey),
                    child:  Text(
                      dayList[ymdToDate(i).weekday - 1].substring(0, 2),
                      // i.substring(i.length-2),
                    ),
                  ))
                      .toList(),
                  automaticIndicatorColorAdjustment: true,
                  indicatorColor: Colors.amber,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
        body:
        Stack(
          children: [
            TabBarView(
              controller: tabController,
              children: totalList.map((d) {
                return _getGraphicBox(d);
              }).toList(),

            ),
          ],
        ),

      ),
    );
  }


  Widget _getGraphicBox(List<Total> data) {
            return Row(
              children: [
                SfCircularChart(
                  title: ChartTitle(text: 'Sales by sales person'),
                  legend: Legend(isVisible: true),
                  series:
                  <PieSeries<Total, String>>[
                    PieSeries<Total, String>(
                        explode: true,
                        explodeIndex: 0,
                        explodeOffset: '10%',
                        dataSource: data,
                        xValueMapper: (Total data, _) => data.category,
                        yValueMapper: (Total data, _) => data.total,
                        dataLabelMapper: (Total data, _) => "${data.category} \n ${data.total}",
                        startAngle: 90,
                        endAngle: 90,
                        dataLabelSettings: const DataLabelSettings(isVisible: true)),
                  ],
                ),
              ],
            );
  }

  Future<void> _generateExcel() async {
    //Create a Excel document.

    //Creating a workbook.
    final xlsio.Workbook workbook = xlsio.Workbook();
    //Accessing via index
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Document';
    sheet.showGridlines = false;
    final xlsio.Worksheet sheet2 = workbook.worksheets.addWithName('Data');
    sheet.enableSheetCalculations();

    sheet.getRangeByIndex(1, 1, 1, 7).merge();
    final xlsio.Range range = sheet.getRangeByName('A1');
    range.rowHeight = 22.5;
    range.text = 'Document';
    range.cellStyle.vAlign = xlsio.VAlignType.center;
    range.cellStyle.hAlign = xlsio.HAlignType.center;
    range.cellStyle.bold = true;
    range.cellStyle.fontSize = 14;
    range.cellStyle.backColor = '#9BC2E6';

    sheet.getRangeByName('A1').columnWidth = 2.71;
    sheet.getRangeByName('B1').columnWidth = 10.27;
    sheet.getRangeByName('C1').columnWidth = 10.27;
    sheet.getRangeByName('D1').columnWidth = 0.19;
    sheet.getRangeByName('E1').columnWidth = 10.27;
    sheet.getRangeByName('F1').columnWidth = 10.27;
    sheet.getRangeByName('G1').columnWidth = 2.71;

    sheet.getRangeByIndex(1, 1, 1, 7).merge();

    sheet.getRangeByName('A13').rowHeight = 12;
    sheet.getRangeByName('A14').rowHeight = 21;
    sheet.getRangeByName('A15').rowHeight = 15;
    sheet.getRangeByName('A16').rowHeight = 3;
    sheet.getRangeByName('A17').rowHeight = 21;
    sheet.getRangeByName('A18').rowHeight = 15;
    sheet.getRangeByName('A19').rowHeight = 12;

    final xlsio.Range range5 = sheet.getRangeByName('B14:C14');
    final xlsio.Range range6 = sheet.getRangeByName('B15:C15');
    final xlsio.Range range7 = sheet.getRangeByName('B17:C17');
    final xlsio.Range range8 = sheet.getRangeByName('B18:C18');
    final xlsio.Range range9 = sheet.getRangeByName('E14:F14');
    final xlsio.Range range10 = sheet.getRangeByName('E15:F15');
    final xlsio.Range range11 = sheet.getRangeByName('E17:F17');
    final xlsio.Range range12 = sheet.getRangeByName('E18:F18');

    range5.text = r'$ 4.51 M';
    range9.formula = '=Data!D14';
    range7.formula = '=Data!C19';
    range11.formula = '=Data!E14';

    range5.merge();
    range6.merge();
    range7.merge();
    range8.merge();
    range9.merge();
    range10.merge();
    range11.merge();
    range12.merge();

    final List<xlsio.Style> styles = createStyles(workbook);
    range5.cellStyle = styles[0];
    range9.cellStyle = styles[1];
    range7.cellStyle = styles[2];
    range11.cellStyle = styles[3];

    range6.cellStyle = styles[4];
    range6.text = 'Sales Amount';
    range10.cellStyle = styles[5];
    range10.text = 'Average Unit Price';
    range8.cellStyle = styles[6];
    range8.text = 'Gross Profit Margin';
    range12.cellStyle = styles[7];
    range12.text = 'Customer Count';

    sheet2.getRangeByName('B1').columnWidth = 22.27;
    sheet2.getRangeByName('C1').columnWidth = 22.27;
    sheet2.getRangeByName('D1').columnWidth = 9.27;
    sheet2.getRangeByName('E1').columnWidth = 9.27;




    sheet2.getRangeByName('A1').text = 'Months';
    sheet2.getRangeByName('B1').text = 'Internet Sales Amount';
    sheet2.getRangeByName('C1').text = 'Reseller Sales Amount';
    sheet2.getRangeByName('D1').text = 'Unit Price';
    sheet2.getRangeByName('E1').text = 'Customers';

    sheet2.getRangeByName('A2').text = 'Jan';
    sheet2.getRangeByName('A3').text = 'Feb';
    sheet2.getRangeByName('A4').text = 'Mar';
    sheet2.getRangeByName('A5').text = 'Apr';
    sheet2.getRangeByName('A6').text = 'May';
    sheet2.getRangeByName('A7').text = 'June';
    sheet2.getRangeByName('A8').text = 'Jul';
    sheet2.getRangeByName('A9').text = 'Aug';
    sheet2.getRangeByName('A10').text = 'Sep';
    sheet2.getRangeByName('A11').text = 'Oct';
    sheet2.getRangeByName('A12').text = 'Nov';
    sheet2.getRangeByName('A13').text = 'Dec';
    sheet2.getRangeByName('A14').text = 'Total';

    sheet2.getRangeByName('B2').number = 226170;
    sheet2.getRangeByName('B3').number = 212259;
    sheet2.getRangeByName('B4').number = 181079;
    sheet2.getRangeByName('B5').number = 188809;
    sheet2.getRangeByName('B6').number = 198195;
    sheet2.getRangeByName('B7').number = 235524;
    sheet2.getRangeByName('B8').number = 185786;
    sheet2.getRangeByName('B9').number = 196745;
    sheet2.getRangeByName('B10').number = 164897;
    sheet2.getRangeByName('B11').number = 175673;
    sheet2.getRangeByName('B12').number = 212896;
    sheet2.getRangeByName('B13').number = 325634;
    sheet2.getRangeByName('B14').formula = '=SUM(B2:B13)';

    sheet2.getRangeByName('C2').number = 170234;
    sheet2.getRangeByName('C3').number = 189456;
    sheet2.getRangeByName('C4').number = 168795;
    sheet2.getRangeByName('C5').number = 143567;
    sheet2.getRangeByName('C6').number = 163567;
    sheet2.getRangeByName('C7').number = 163546;
    sheet2.getRangeByName('C8').number = 143787;
    sheet2.getRangeByName('C9').number = 149898;
    sheet2.getRangeByName('C10').number = 153784;
    sheet2.getRangeByName('C11').number = 164289;
    sheet2.getRangeByName('C12').number = 172453;
    sheet2.getRangeByName('C13').number = 223430;
    sheet2.getRangeByName('C14').formula = '=SUM(C2:C13)';

    sheet2.getRangeByName('D2').number = 202;
    sheet2.getRangeByName('D3').number = 204;
    sheet2.getRangeByName('D4').number = 191;
    sheet2.getRangeByName('D5').number = 223;
    sheet2.getRangeByName('D6').number = 203;
    sheet2.getRangeByName('D7').number = 185;
    sheet2.getRangeByName('D8').number = 198;
    sheet2.getRangeByName('D9').number = 196;
    sheet2.getRangeByName('D10').number = 220;
    sheet2.getRangeByName('D11').number = 218;
    sheet2.getRangeByName('D12').number = 299;
    sheet2.getRangeByName('D13').number = 185;
    sheet2.getRangeByName('D14').formula = '=AVERAGE(D2:D13)';

    sheet2.getRangeByName('E2').number = 1861;
    sheet2.getRangeByName('E3').number = 1522;
    sheet2.getRangeByName('E4').number = 1410;
    sheet2.getRangeByName('E5').number = 1488;
    sheet2.getRangeByName('E6').number = 1781;
    sheet2.getRangeByName('E7').number = 2155;
    sheet2.getRangeByName('E8').number = 1657;
    sheet2.getRangeByName('E9').number = 1767;
    sheet2.getRangeByName('E10').number = 1448;
    sheet2.getRangeByName('E11').number = 1556;
    sheet2.getRangeByName('E12').number = 1928;
    sheet2.getRangeByName('E13').number = 2956;
    sheet2.getRangeByName('E14').formula = '=SUM(E2:E13)';

    sheet2.getRangeByName('B17').text = '2018 Sales';
    sheet2.getRangeByName('B18').text = '2018 Sales';
    sheet2.getRangeByName('B19').text = 'Gain %';
    sheet2.getRangeByName('C17').number = 3845634;
    sheet2.getRangeByName('C18').formula = '=B14+C14';
    sheet2.getRangeByName('C19').formula = '=(C18-C17)/10000000';

    sheet2.getRangeByName('C19').numberFormat = '0.00%';
    sheet2.getRangeByName('C17:C18').numberFormat = r'_($* #,##0.00';
    sheet2.getRangeByName('B2:D13').numberFormat = r'_($* #,##0.00';

    sheet2.getRangeByName('A1:E1').cellStyle.backColor = '#C6E0B4';
    sheet2.getRangeByName('A1:E1').cellStyle.bold = true;
    sheet2.getRangeByName('A14:E14').cellStyle.backColor = '#C6E0B4';
    sheet2.getRangeByName('A14:E14').cellStyle.bold = true;
    sheet.getRangeByName('G30').text = '.';





    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    //Launch file.
    await FileSaveHelper.saveAndLaunchFile(bytes, 'Document.xlsx');
  }

  // Create styles for worksheet
  List<xlsio.Style> createStyles(xlsio.Workbook workbook) {
    final xlsio.Style style1 = workbook.styles.add('style1');
    style1.backColor = '#9BC2E6';
    style1.fontSize = 18;
    style1.bold = true;
    style1.numberFormat = r'$#,##0.00';
    style1.hAlign = xlsio.HAlignType.center;
    style1.vAlign = xlsio.VAlignType.center;
    style1.borders.top.lineStyle = xlsio.LineStyle.thin;
    style1.borders.top.color = '#757171';
    style1.borders.right.lineStyle = xlsio.LineStyle.thin;
    style1.borders.right.color = '#757171';
    style1.borders.left.lineStyle = xlsio.LineStyle.thin;
    style1.borders.left.color = '#757171';

    final xlsio.Style style2 = workbook.styles.add('style2');
    style2.backColor = '#F4B084';
    style2.fontSize = 18;
    style2.bold = true;
    style2.numberFormat = r'$#,##0.00';
    style2.hAlign = xlsio.HAlignType.center;
    style2.vAlign = xlsio.VAlignType.center;
    style2.borders.top.lineStyle = xlsio.LineStyle.thin;
    style2.borders.top.color = '#757171';
    style2.borders.right.lineStyle = xlsio.LineStyle.thin;
    style2.borders.right.color = '#757171';
    style2.borders.left.lineStyle = xlsio.LineStyle.thin;
    style2.borders.left.color = '#757171';

    final xlsio.Style style3 = workbook.styles.add('style3');
    style3.backColor = '#FFD966';
    style3.fontSize = 18;
    style3.bold = true;
    style3.numberFormat = '0.00%';
    style3.hAlign = xlsio.HAlignType.center;
    style3.vAlign = xlsio.VAlignType.center;
    style3.borders.top.lineStyle = xlsio.LineStyle.thin;
    style3.borders.top.color = '#757171';
    style3.borders.right.lineStyle = xlsio.LineStyle.thin;
    style3.borders.right.color = '#757171';
    style3.borders.left.lineStyle = xlsio.LineStyle.thin;
    style3.borders.left.color = '#757171';

    final xlsio.Style style4 = workbook.styles.add('style4');
    style4.backColor = '#A9D08E';
    style4.fontSize = 18;
    style4.bold = true;
    style4.numberFormat = '#,###';
    style4.hAlign = xlsio.HAlignType.center;
    style4.vAlign = xlsio.VAlignType.center;
    style4.borders.top.lineStyle = xlsio.LineStyle.thin;
    style4.borders.top.color = '#757171';
    style4.borders.right.lineStyle = xlsio.LineStyle.thin;
    style4.borders.right.color = '#757171';
    style4.borders.left.lineStyle = xlsio.LineStyle.thin;
    style4.borders.left.color = '#757171';

    final xlsio.Style style5 = workbook.styles.add('style5');
    style5.backColor = '#9BC2E6';
    style5.fontColor = '#757171';
    style5.hAlign = xlsio.HAlignType.center;
    style5.vAlign = xlsio.VAlignType.center;
    style5.borders.bottom.lineStyle = xlsio.LineStyle.thin;
    style5.borders.bottom.color = '#757171';
    style5.borders.right.lineStyle = xlsio.LineStyle.thin;
    style5.borders.right.color = '#757171';
    style5.borders.left.lineStyle = xlsio.LineStyle.thin;
    style5.borders.left.color = '#757171';

    final xlsio.Style style6 = workbook.styles.add('style6');
    style6.backColor = '#F4B084';
    style6.fontColor = '#757171';
    style6.hAlign = xlsio.HAlignType.center;
    style6.vAlign = xlsio.VAlignType.center;
    style6.borders.bottom.lineStyle = xlsio.LineStyle.thin;
    style6.borders.bottom.color = '#757171';
    style6.borders.right.lineStyle = xlsio.LineStyle.thin;
    style6.borders.right.color = '#757171';
    style6.borders.left.lineStyle = xlsio.LineStyle.thin;
    style6.borders.left.color = '#757171';

    final xlsio.Style style7 = workbook.styles.add('style7');
    style7.backColor = '#FFD966';
    style7.fontColor = '#757171';
    style7.hAlign = xlsio.HAlignType.center;
    style7.vAlign = xlsio.VAlignType.center;
    style7.borders.bottom.lineStyle = xlsio.LineStyle.thin;
    style7.borders.bottom.color = '#757171';
    style7.borders.right.lineStyle = xlsio.LineStyle.thin;
    style7.borders.right.color = '#757171';
    style7.borders.left.lineStyle = xlsio.LineStyle.thin;
    style7.borders.left.color = '#757171';

    final xlsio.Style style8 = workbook.styles.add('style8');
    style8.backColor = '#A9D08E';
    style8.fontColor = '#757171';
    style8.hAlign = xlsio.HAlignType.center;
    style8.vAlign = xlsio.VAlignType.center;
    style8.borders.bottom.lineStyle = xlsio.LineStyle.thin;
    style8.borders.bottom.color = '#757171';
    style8.borders.right.lineStyle = xlsio.LineStyle.thin;
    style8.borders.right.color = '#757171';
    style8.borders.left.lineStyle = xlsio.LineStyle.thin;
    style8.borders.left.color = '#757171';

    return <xlsio.Style>[
      style1,
      style2,
      style3,
      style4,
      style5,
      style6,
      style7,
      style8
    ];
  }

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