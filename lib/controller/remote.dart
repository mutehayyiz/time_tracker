
import 'dart:convert';
import 'package:time_tracker/model/entry.dart';
import 'package:http/http.dart' as http;

class Remote {

  Future<List<Entry>> getEntriesFromRemote(String categoryName) async {
    var url =
    Uri.parse('http://localhost:4242/entry/' + categoryName.toLowerCase());
    final response = await http.get(url);

    return List<Entry>.from(
        json.decode(response.body).map((x) => Entry.fromJson(x)));
  }

  addRemote(Entry e) async {
    var url = Uri.parse('http://localhost:4242/entry');
    var response = await http.post(url, body: e.toJson());
    final id = jsonDecode(response.body).cast<String, dynamic>();
    e.id = id;
  }
}