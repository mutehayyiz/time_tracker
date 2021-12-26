import 'package:flutter/material.dart';
import 'package:time_tracker/common.dart';
import 'package:time_tracker/controller/remote.dart';
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
  String date = ymdToString(DateTime.now());

  @override
  void initState() {
    super.initState();
    isRecording = false;
    timerString = "00:00:00";
    getEntries();
  }

  getEntries() async {
    var list = await Storage().getEntriesByDateAndCategory(widget.name, date);

    setState(() {
      entryList = list;
    });
  }

  addNewEntry(Entry e) async {
    e.category = widget.name.toLowerCase();
    e.id = "";

    var id = await Remote().addEntry(e);
    e.id = id;

    Storage().addEntry(e);

    entryList.add(e);
    return true;
  }

  void removeEntry(int index) {
    Storage().removeEntry(entryList[index]);
    Remote().removeEntry(widget.name.toLowerCase(), entryList[index].id);

    setState(() {
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
                leading: Text(toHMS(entryList[index].seconds),
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
      height: MediaQuery.of(context).size.width / 3,
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
                padding: isRecording
                    ? EdgeInsets.all(MediaQuery.of(context).size.width / 3 / 6)
                    : const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isRecording
                        ? const BorderRadius.all(Radius.circular(7))
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
