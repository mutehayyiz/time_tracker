import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePicker extends StatefulWidget {
  final Function callback;
  final DateTime minDate;

  const DatePicker({Key? key, required this.callback, required this.minDate}) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final DateRangePickerController _pickerController =
      DateRangePickerController();
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pickerController.displayDate = date;
    _pickerController.addPropertyChangedListener((p) {
      if (p == "displayDate") {
        setState(() {
          date = _pickerController.displayDate!;
        });
      }
      if (p == "selectedDate") {
        widget.callback(_pickerController.selectedDate);
      }
    });
  }

  void _cancel(){
    widget.callback(date);
  }

  SfDateRangePicker _getVerticalCalendar() {
    return SfDateRangePicker(
      view: DateRangePickerView.month,
      selectionMode: DateRangePickerSelectionMode.single,
      todayHighlightColor: Colors.white,
      showNavigationArrow: true,
      backgroundColor: Colors.black,
      showActionButtons: false,
      navigationDirection: DateRangePickerNavigationDirection.vertical,
      allowViewNavigation: false,
      enableMultiView: true,
      controller: _pickerController,
      headerStyle: const DateRangePickerHeaderStyle(
        textAlign: TextAlign.justify,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        backgroundColor: Colors.black,
      ),
      monthViewSettings: const DateRangePickerMonthViewSettings(
        firstDayOfWeek: 1,
        viewHeaderHeight: 0,
      ),
      maxDate: DateTime.now(),
      minDate: widget.minDate,
      navigationMode: DateRangePickerNavigationMode.scroll,
      monthFormat: 'MMM',
      monthCellStyle: const DateRangePickerMonthCellStyle(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
        ),
        disabledDatesTextStyle: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // here the desired height
        child: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.8),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leadingWidth: 100,
          leading: TextButton(
            onPressed: _cancel,
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          title: Text(
            DateFormat(DateFormat.YEAR_MONTH).format(date),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 30,
              margin: const EdgeInsets.only(top: 0, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: ["M","T","W","T","F","S","S"].map((t) => Text(
                    t,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        width: double.infinity,
        child: _getVerticalCalendar(),
      ),
    );
  }
}

