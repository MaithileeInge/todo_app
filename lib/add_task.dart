import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'home.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> addTaskToBack4() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter title!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    log('addTaskToBack4: $titleController.text');
    final todo = ParseObject('Task')
      ..set('title', titleController.text)
      ..set('description', descriptionController.text)
      ..set('done', false);
    final ParseResponse saveResponse = await todo.save();
    if (saveResponse.success && saveResponse.results != null) {
      for (var o in saveResponse.results!) {
        setState(() {
          //<-- Clear at the end
          titleController.clear();
          descriptionController.clear();
          final snackBar = SnackBar(
            content: Text("Task Added!"),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
      // Fluttertoast.showToast(
      //     msg: "Task Added!",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.TOP_RIGHT,
      //     timeInSecForIosWeb: 10,
      //     backgroundColor: Colors.green,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      log('after Save:');
    } else {
      Fluttertoast.showToast(
          msg: "Error Adding New Task!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: 'Enter Title', border: OutlineInputBorder()),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Enter Description',
                      border: OutlineInputBorder()),
                ),
              ),
              SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Colors.purple.shade100;
                        return Theme.of(context).primaryColor;
                      })),
                      child: Text(
                        'Add Task',
                        style: GoogleFonts.roboto(fontSize: 18),
                      ),
                      onPressed: () {
                        addTaskToBack4();
                      }))
            ],
          )),
    );
  }
}
