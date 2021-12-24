import 'dart:convert';

class Total {
  String category;
  int total;

  Total.fromJson(Map<String, dynamic> json)
      : category = json["category"],
        total = json["total"];
}
