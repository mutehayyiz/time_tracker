import 'dart:convert';

class Total {
  String category;
  double total;
  int seconds;

  Total.fromJson(Map<String, dynamic> json)
      : category = json["category"],
        total = json["total"],
        seconds = json["seconds"];
}
