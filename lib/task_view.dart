import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'home.dart';

class TaskView extends StatefulWidget {
  final title, description, objectid;
  final bool done;

  const TaskView(
      {required this.objectid,
      required this.title,
      required this.description,
      required this.done});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<TaskView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late bool isCompleted = false;
  late String objectId;
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
    isCompleted = widget.done;
    objectId = widget.objectid;
  }

  Future<void> updateTaskToBack4() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter title!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    log('updateTaskToBack4: $titleController.text');
    var todo = ParseObject('Task')
      ..objectId = objectId
      ..set('title', titleController.text)
      ..set('description', descriptionController.text)
      ..set('done', isCompleted);
    final ParseResponse saveResponse = await todo.save();
    if (saveResponse.success && saveResponse.results != null) {
      for (var o in saveResponse.results!) {
        setState(() {
          //<-- Clear at the end
          titleController.clear();
          descriptionController.clear();
          isCompleted = false;
          final snackBar = SnackBar(
            content: Text("Task updated!"),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    } else {
      setState(() {
        final snackBar = SnackBar(
          content: Text("Problem updating Task!"),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(snackBar);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        color: darkBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Task',
                style: TextStyle(
                  fontSize: 24.0,
                  color: white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: white,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: white,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    focusColor: white,
                    hoverColor: white,
                    checkColor: Colors.green, // Color of the checkmark
                    activeColor: Colors.white,
                    value: isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        isCompleted = value!;
                      });
                    },
                  ),
                  Text('Done', style: TextStyle(color: white)),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Handle update logic here
                  updateTaskToBack4();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple, // Set the button color to purple
                ),
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
