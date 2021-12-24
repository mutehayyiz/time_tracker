import 'package:time_tracker/model/entry.dart';

class Category {
  String name;

  Category(this.name);

  Category.fromJson(Map<String, dynamic> json)
      : name = json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
