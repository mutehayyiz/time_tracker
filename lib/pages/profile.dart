import 'package:flutter/material.dart';
import 'package:time_tracker/storage/storage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Text("drop"),
                onPressed: () {
                  Storage().dropDatabase();
                },
              ),
              FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: const Text("get"),
                  onPressed: () {
                    Storage().addFromRemote();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
