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

    return dateList;
  }

  totalByDate(String date) async {
    String key = "entry-" + date + "-%";
    List<Map<String, dynamic>> data = await jsonStore.getListLike(key) ?? [];
    List<Entry> entries = data.map((entry) => Entry.fromJson(entry)).toList();

    List<Total> totals = [];

    List<String> categorNames = [];

    List<Category> categories = await getCategories();

    for (var c in categories) {
      categorNames.add(c.name);
    }

    for (String category in categorNames) {
      Total t = Total();
      t.date = date;
      t.seconds = 0;
      t.category = category;
      totals.add(t);
    }

    int dailyTotalSeconds = 0;

    for (Entry entry in entries) {
      dailyTotalSeconds += entry.seconds;
      int index = categorNames.indexOf(entry.category);
      totals[index].seconds += entry.seconds;
    }

    Total other = Total();
    other.category = "other";
    other.date = date;
    other.seconds = 86400 - dailyTotalSeconds;

    totals.add(other);

    for (Total t in totals) {
      t.total = double.parse(
          (100 * t.seconds.toDouble() / 86400.0).toStringAsFixed(2));
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
