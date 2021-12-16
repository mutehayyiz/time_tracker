import 'package:time_tracker/model/category.dart';
import 'package:time_tracker/model/entry.dart';
import 'package:json_store/json_store.dart';


class Storage {
  JsonStore jsonStore = JsonStore();

  addCategory(Category c) async {
    await jsonStore.setItem(
      'category-${c.name}',
      c.toJson(),
    );
  }

  getCategories() async{
    List<Map<String, dynamic>> json = await jsonStore.getListLike('category-%')??[];
    return json.map((category) => Category.fromJson(category)).toList();
  }

  removeCategory(Category c){
    jsonStore.deleteItem('category-${c.name}');
  }

  addEntry(Entry e) async {
      String key = e.category+'-'+e.id;
      jsonStore.setItem(key, e.toJson());
  }

  getEntries(String categoryName) async{
    List<Map<String, dynamic>> json = await jsonStore.getListLike(categoryName+'-%')??[];
    return json.map((entry) => Entry.fromJson(entry)).toList();
  }

  removeEntry(Entry e){
    String key = e.category+'-'+e.id;
    jsonStore.deleteItem(key);
  }

  removeEntriesByCategory(String categoryName){
    jsonStore.deleteLike(categoryName+'-%');
  }

  dropDatabase(){
    jsonStore.clearDataBase();
  }
}
