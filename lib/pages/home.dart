import 'package:flutter/material.dart';
import 'package:time_tracker/storage/storage.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Activity",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.black,
        // content will be here

        child: Center(
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: const Text("Drop"),
            onPressed: () {
              Storage().dropDatabase();
            },
          ),
        ),
      ),
    );
  }
}
