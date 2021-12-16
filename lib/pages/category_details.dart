import 'package:flutter/material.dart';
import 'package:time_tracker/controller/timer_controller.dart';
import 'package:time_tracker/model/entry.dart';
import 'package:time_tracker/storage/storage.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String name;

  const CategoryDetailsPage({Key? key, required this.name}) : super(key: key);

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPage();
}

class _CategoryDetailsPage extends State<CategoryDetailsPage> {
  List<Entry> entryList = [];
  late bool isRecording;
  late String timerString;
  TimerController timer = TimerController();

  @override
  void initState() {
    super.initState();
    isRecording = false;
    timerString = "00:00:00";
    getEntries();
  }

  getEntries() async {
    var list = await Storage().getEntries(widget.name);

    setState(() {
      entryList = list;
    });
  }

  addNewEntry(Entry e) {
    e.category = widget.name.toLowerCase();
    e.id = e.start;
    Storage().addEntry(e);
    entryList.add(e);
    return true;
  }

  void removeEntry(int index) {
    setState(() {
      Storage().removeEntry(entryList[index]);
      entryList = List.from(entryList)..removeAt(index);
    });
  }


  void handleRecord() {
    if (isRecording) {
      Entry e = timer.stop();
      addNewEntry(e);
      timerString = "00:00:00";
    } else {
      timer.start((counter) {
        if (!mounted) {
          return;
        }
        setState(() {
          timerString = toHMS(counter);
        });
      });
    }
    setState(() {
      isRecording = isRecording == false;
    });
  }

  String toHMS(int i) {
    Duration diff = Duration(seconds: i);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(diff.inSeconds.remainder(60));
    return "${twoDigits(diff.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarTextStyle: const TextStyle(color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.5).withAlpha(200),
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: _historyBox(),
      bottomNavigationBar: _recordBox(),
    );
  }

  Widget _historyBox() {
    return SizedBox(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: entryList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            key: ObjectKey(entryList[index]),
            child: Card(
              child: ListTile(
                tileColor: Colors.black87,
                leading: Text(toHMS(entryList[index].diff),
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                //same over here
                title: Column(children: [
                  Text(entryList[index].start,
                      style: const TextStyle(color: Colors.white)),
                  Text(entryList[index].stop,
                      style: const TextStyle(color: Colors.white)),
                ]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    removeEntry(index);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recordBox() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(58, 58, 60, 1),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => handleRecord(),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(width: 4, color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: isRecording
                      ? const EdgeInsets.symmetric(vertical: 40, horizontal: 20)
                      : const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isRecording
                        ? const BorderRadius.all(Radius.circular(10))
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                timerString,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
