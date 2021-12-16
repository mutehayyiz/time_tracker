import 'package:flutter/material.dart';
import 'package:time_tracker/model/category.dart';
import 'package:time_tracker/pages/activity_one.dart';
import 'package:time_tracker/storage/storage.dart';
import 'category_details.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late List<Category> categoryList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategories();
  }

  getCategories() async {
    var list = await Storage().getCategories();

    setState(() {
      categoryList = list;
    });
  }

  addNewCategory(String name) {
    Category c = Category(name);

    for (Category ctg in categoryList) {
      if (ctg.name == name) {
        return false;
      }
    }

    Storage().addCategory(c);

    categoryList.add(c);

    return true;
  }

  removeCategory(int index) {
    setState(() {
      Storage().removeCategory(categoryList[index]);
      categoryList = List.from(categoryList)..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Activity",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            iconSize: 40,
            icon: const Icon(
              Icons.account_circle,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityOne(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.black,
        // content will be here

        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            _getListBox(),
            const Divider(
              height: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: _newCategoryButton(),
    );
  }

  Widget _newCategoryButton() {
    String input = "";
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          title: const Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: "Category name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                input == ""
                    ? null
                    : setState(() {
                        addNewCategory(input)
                            ? Navigator.pop(context, 'Add')
                            : null;
                      });
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      // Respond to button press
      child: const Icon(Icons.add),
    );
  }

  Widget _getListBox() {
    return SizedBox(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          return Slidable(
            key: ValueKey(categoryList[index]),
            closeOnScroll: true,
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: ListTile(
                tileColor: Colors.black87,
                leading: const Icon(Icons.category, color: Colors.white),
                //same over here
                title: Text(
                  categoryList[index].name,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),

                trailing: IconButton(
                  icon:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CategoryDetailsPage(
                              name: categoryList[index].name)),
                    );
                  },
                ),
              ),
            ),
            endActionPane: ActionPane(
              extentRatio: 0.2,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  key: ValueKey(categoryList[index]),
                  autoClose: true,
                  onPressed: (context) {
                    removeCategory(index);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
