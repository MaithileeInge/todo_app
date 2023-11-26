import 'dart:developer';

import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:intl/intl.dart';
import 'task_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<ParseObject>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = getTaskList();
  }

  Future<void> updateDoneTask(String id, bool done) async {
    var task = ParseObject('Task')
      ..objectId = id
      ..set('done', done);
    await task.save();
  }

  Future<void> deleteTask(String id) async {
    var task = ParseObject('Task')..objectId = id;
    await task.delete();
  }

  Future<List<ParseObject>> getTaskList() async {
    print("Inside get todo");
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    final ParseResponse apiResponse = await queryTodo.query();
    if (apiResponse.success && apiResponse.results != null) {
      log('apiResponse--$apiResponse');
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Row(children: <Widget>[
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: tasks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No Tasks Added!');
                    } else {
                      log('snapShot--$snapshot');
                      List<ParseObject> taskList = snapshot.data!;
                      return ListView.builder(
                          padding: EdgeInsets.only(top: 10.0),
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            //*************************************
                            //Get Parse Object Values
                            // final varTodo = snapshot.data![index];
                            // log('varTodo- $varTodo');
                            final varTitle = taskList[index]['title'];

                            log('varTitle- $varTitle');
                            final varDescription =
                                taskList[index]['description'];
                            log('VARdescription- $varDescription');
                            final varDueDate = taskList[index]['due_date'];
                            log('varDueDate- $varDueDate');
                            final varDone = taskList[index]['done'] ?? false;
                            log('varDone- $varDone');
                            var lastUpdated = DateFormat('dd-MM-yyyy')
                                .format(taskList[index]['updatedAt']);

                            //*************************************
                            return InkWell(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xff121211),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 90,
                                child: Row(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        varDone ? Icons.check : Icons.error,
                                        color: varDone
                                            ? Colors.green
                                            : Colors.yellow,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Checkbox(
                                          value: varDone,
                                          focusColor: white,
                                          hoverColor: white,
                                          checkColor: Colors
                                              .green, // Color of the checkmark
                                          activeColor: Colors.white,
                                          onChanged: (value) async {
                                            log("value-$value");
                                            await updateDoneTask(
                                                taskList[index]['objectId'],
                                                value!);
                                            setState(() {
                                              // Refresh the list after updating
                                              tasks = getTaskList();
                                              final snackBar = SnackBar(
                                                content:
                                                    Text("Task status set!"),
                                                duration: Duration(seconds: 2),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..removeCurrentSnackBar()
                                                ..showSnackBar(snackBar);
                                            });
                                          }),
                                    ),
                                    SizedBox(width: 8.0),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: Text(varTitle,
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 20,
                                                      color: Colors.white))),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: Text(varDescription,
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 16,
                                                      color: Colors.white))),
                                          Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: Text(
                                                  "Last updated : " +
                                                      lastUpdated,
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 10,
                                                      color: Colors.white)))
                                        ]),
                                    SizedBox(width: 100.0),
                                    Container(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              log("Edit!");
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TaskView(
                                                            objectid: taskList[
                                                                    index]
                                                                ['objectId'],
                                                            title: varTitle,
                                                            description:
                                                                varDescription,
                                                            done: varDone,
                                                          )));
                                            })),
                                    Container(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: primaryRed,
                                            ),
                                            onPressed: () async {
                                              log("Delete!");
                                              await deleteTask(
                                                  taskList[index]['objectId']);
                                              setState(() {
                                                final snackBar = SnackBar(
                                                  content:
                                                      Text("Task deleted!"),
                                                  duration:
                                                      Duration(seconds: 2),
                                                );
                                                ScaffoldMessenger.of(context)
                                                  ..removeCurrentSnackBar()
                                                  ..showSnackBar(snackBar);
                                              });
                                              setState(() {
                                                // Refresh the list after updating
                                                tasks = getTaskList();
                                              });
                                            }))
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  })),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddTask()));
          }),
    ));
  }
}
