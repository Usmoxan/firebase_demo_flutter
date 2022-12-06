import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_bismillah/pages/next_page.dart';

import 'package:flutter/material.dart';

import '../services/firebase_crud.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> collectionReference = FirebaseCrud.readEmployee();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _add_name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Firebase Demo'),
        elevation: 5,
      ),
      body: Center(
        child: Column(children: [
          Expanded(
            child: StreamBuilder(
              stream: collectionReference,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView(
                      children: snapshot.data!.docs.map(
                        (e) {
                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Row(children: [
                                Expanded(
                                  child: Text(
                                    e['name'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("O'chirish"),
                                            content: Text(
                                                "Chindan ham o'chirishni istaysizmi?"),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Bekor qilish"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  var response =
                                                      await FirebaseCrud
                                                          .deleteEmployee(
                                                              docId: e.id);
                                                  if (response.code == 200) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          content: Text(response
                                                              .message
                                                              .toString()),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Olib tashlash"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete_forever_rounded)),
                              ]),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  );
                }

                return CircularProgressIndicator(
                  strokeWidth: 2,
                );
              },
            ),
          ),
          Material(
            elevation: 3,
            child: Container(
              color: Colors.white,
              height: 50,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Form(
                      key: _formKey,
                      child: TextField(
                        controller: _add_name,
                        decoration: InputDecoration.collapsed(
                            hintText: "Bu yerga xabar kiriting"),
                      ),
                    )),
                    IconButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var response = await FirebaseCrud.addEmployee(
                              name: _add_name.text,
                            );
                            if (response.code != 200) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content:
                                          Text(response.message.toString()),
                                    );
                                  });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content:
                                          Text(response.message.toString()),
                                    );
                                  });
                            }
                            _add_name.clear();
                          }
                        },
                        icon: Icon(Icons.send,
                            color: Color.fromARGB(255, 152, 234, 255)))
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
