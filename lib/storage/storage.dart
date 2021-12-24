import 'package:time_tracker/controller/remote.dart';
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
    //TODO var list= await Remote().getCategories();
    List<Map<String, dynamic>> json = await jsonStore.getListLike('category-%')??[];
    return json.map((category) => Category.fromJson(category)).toList();
  }

  deleteCategory(Category c){
    jsonStore.deleteItem('category-${c.name}');
    jsonStore.deleteLike(c.name+'-entry-%');
  }

  addEntry(Entry e) async {
      String key = e.category+"-"+e.date+"-"+e.id;
      jsonStore.setItem(key, e.toJson());
  }

  getEntriesByDate(String categoryName, String date) async {
    //var list = await Remote().getEntriesDaily(widget.name, date);

    String key = categoryName+"-"+date+"-%";
    List<Map<String, dynamic>> json = await jsonStore.getListLike(key)??[];
    return json.map((entry) => Entry.fromJson(entry)).toList();
  }

  getDays() {
    var data = jsonStore.getListLike("%-%-");
    print(data);

  }

  removeEntry(Entry e){
    String key = e.category+"-"+e.date+"-"+e.id;
    jsonStore.deleteItem(key);
  }

  dropDatabase(){
    jsonStore.clearDataBase();
    print("dropped");
  }

  addFromRemote() async {
    var data= await Remote().getAllData();
    int x = 0;
    data.forEach((key, value) {
      print("alldata: ");
      print(x);
      x++;
      print(value.runtimeType);

      addCategory(Category.fromJson({"name":key}));
      value.forEach((e){
        addEntry(e);
      });
    });
  }

}
