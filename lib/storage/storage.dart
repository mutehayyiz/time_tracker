import 'package:time_tracker/controller/remote.dart';
import 'package:time_tracker/model/category.dart';
import 'package:time_tracker/model/entry.dart';
import 'package:json_store/json_store.dart';
import 'package:time_tracker/model/total.dart';

class Storage {
  JsonStore jsonStore = JsonStore();

  addCategory(Category c) async {
    await jsonStore.setItem(
      'category-${c.name}',
      c.toJson(),
    );
  }

  getCategories() async {
    //TODO var list= await Remote().getCategories();
    List<Map<String, dynamic>> json =
        await jsonStore.getListLike('category-%') ?? [];
    return json.map((category) => Category.fromJson(category)).toList();
  }

  deleteCategory(Category c) {
    jsonStore.deleteItem('category-${c.name}');
    jsonStore.deleteLike(c.name + '-entry-%');
  }

  addEntry(Entry e) async {
    String key = "entry-" + e.date + "-" + e.category + "-" + e.id;
    jsonStore.setItem(key, e.toJson());
  }

  getEntriesByDateAndCategory(String categoryName, String date) async {
    String key = "entry-" + date + "-" + categoryName + "-%";
    List<Map<String, dynamic>> json = await jsonStore.getListLike(key) ?? [];
    return json.map((entry) => Entry.fromJson(entry)).toList();
  }

  removeEntry(Entry e) {
    String key = "entry-" + e.date + "-" + e.category + "-" + e.id;
    jsonStore.deleteItem(key);
  }

  getDays() async {
    List<Map<String, dynamic>> data =
        await jsonStore.getListLike("entry-%") ?? [];
    List<Entry> entries = data.map((entry) => Entry.fromJson(entry)).toList();
    List<String> dateList = [];

    for (var entry in entries) {
      if (!dateList.contains(entry.date)) {
        dateList.add(entry.date);
      }
    }

    print(dateList);
    return dateList;
  }

  Future<List<Total>> totalByDate(String date) async {
    var key = "entry-" + date + "-%";
    List<Map<String, dynamic>> data = await jsonStore.getListLike(key) ?? [];
    List<Entry> entries = data.map((entry) => Entry.fromJson(entry)).toList();

    List<Total> totals = [];

    List<String> categories = [];

    for (Entry entry in entries) {
      if (!categories.contains(entry.date)) {
        categories.add(entry.date);
        Total tmp = Total();
        print(entry.category);
        tmp.category = entry.category;
        tmp.date = date;
        tmp.seconds = entry.seconds;
        totals.add(tmp);
      } else {
        int index = categories.indexOf(entry.category);
        totals[index].seconds += entry.seconds;
      }
    }
    for (Total t in totals) {
      t.total = 100 * t.seconds.toDouble() / 86400.0;
      print(t.category +" ${t.seconds} ${t.total} ${t.date}");
    }

    return totals;
  }

  dropDatabase() {
    jsonStore.clearDataBase();
  }

  addFromRemote() async {
    var data = await Remote().getAllData();
    data.forEach((key, value) {
      addCategory(Category.fromJson({"name": key}));
      for (var e in value) {
        addEntry(e);
      }
    });
  }
}
