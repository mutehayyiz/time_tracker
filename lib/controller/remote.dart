import 'dart:convert';
import 'package:time_tracker/model/category.dart';
import 'package:time_tracker/model/entry.dart';
import 'package:http/http.dart' as http;
import 'package:time_tracker/model/total.dart';

class Remote {
  String host = "https://go-time-tracker-server.herokuapp.com";

  setUrl(String path) {
    return host + path;
  }

  addCategory(Category c) async {
    var url = Uri.parse(setUrl("/category"));
    await http.post(url, body: json.encode(c.toJson()));
  }

  Future<List<Category>> getCategories() async {
    var url = Uri.parse(setUrl("/category"));
    final response = await http.get(url);

    return List<Category>.from(json
        .decode(response.body)
        .map((x) => Category.fromJson({"name": x}))
        .toList());
  }

  deleteCategory(Category c) async {
    var url = Uri.parse(setUrl("/category"));
    await http.delete(url, body: json.encode(c.toJson()));
  }

  addEntry(Entry e) async {
    var url = Uri.parse(setUrl("/entry"));
    var response = await http.post(url, body: json.encode(e.toJson()));
    var id = json.decode(response.body)["id"];
    return id;
  }

  Future<List<Entry>> getEntries(String categoryName) async {
    var url = Uri.parse(setUrl("/entry/" + categoryName.toLowerCase()));
    final response = await http.get(url);

    return List<Entry>.from(
        json.decode(response.body).map((x) => Entry.fromJson(x)).toList());
  }

  Future<List<Entry>> getEntriesDaily(String categoryName, String date) async {
    var url = Uri.parse(setUrl("/entry/" + categoryName + "/daily"));
    final response = await http.post(url, body: json.encode({"date": date}));

    return List<Entry>.from(
        json.decode(response.body).map((x) => Entry.fromJson(x)).toList());
  }

  void removeEntry(String category, String id) async {
    var url = Uri.parse(setUrl('/entry/' + category.toLowerCase() + "/" + id));
    await http.delete(url);
  }

  Future<List<Total>> totalByDate(String date) async {
    var url = Uri.parse(setUrl("/total/daily"));
    final response = await http.post(url, body: json.encode({"date": date}));
    return List<Total>.from(
        json.decode(response.body).map((x) => Total.fromJson(x)).toList());
  }

  Future<List<String>> getDays() async {
    var url = Uri.parse(setUrl("/days"));
    final response = await http.get(url);
    return List<String>.from(json.decode(response.body).map((x) => x)).toList();
  }

  Future<Map<String, List<Entry>>> getAllData() async {
    var url = Uri.parse(setUrl('/entry'));
    final response = await http.get(url);

    var data = jsonDecode(response.body) as Map;

    return data.map((key, value) => MapEntry<String, List<Entry>>(key,
        List<Entry>.from(value.map((elem) => Entry.fromJson(elem)).toList())));
  }
}
