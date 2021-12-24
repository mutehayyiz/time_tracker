import 'package:flutter/material.dart';
import 'package:time_tracker/model/entry.dart';

class StateManager extends ChangeNotifier {
  final Map<String, List<Entry>> _items = <String, List<Entry>>{};

  void setAll(Map<String, List<Entry>> data) {
    data.forEach((key, value) {
      _items[key] = value;
    });
  }

  addCategory(String categoryName){
    _items[categoryName] = [];
  }

  deleteCategory(String categoryName){
    _items.remove(categoryName);
  }

  getCategories(){
    return _items.keys.toList();
  }

  void add(Entry e) {
    _items.update(e.category, (value) {
      value.add(e);
      return value;
    });

    notifyListeners();
  }

  void delete(Entry e) {
    _items.update(e.category, (value) {
      value.remove(e);
      return value;
    });

    notifyListeners();
  }
}
