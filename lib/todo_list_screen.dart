import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draw_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  SharedPreferences prefs;
  TextEditingController textController = TextEditingController();

  // List of all drawings
  List<MyListItem> listItems = [
    MyListItem("Item 1", "Subtitle 1"),
    MyListItem("Item 2", "Subtitle 2")
  ];
  // List of drawings filtered according to search
  List<MyListItem> showItems = [
    MyListItem("Item 1", "Subtitle 1"),
    MyListItem("Item 2", "Subtitle 2")
  ];

  List<Dismissible> getWidgetsList(List<MyListItem> items) {
    List<Dismissible> widgets = [];
    MyListItem item;
    for (int i = 0; i < items.length; i++) {
      item = items[i];
      widgets.add(myListWidget(item, items, i));
    }
    return widgets;
  }

  Dismissible myListWidget(MyListItem item, List<MyListItem> items, int i) {
    return Dismissible(
      key: Key(item.id),
      onDismissed: (direction) {
        setState(() {
          listItems.remove(item);
          showItems = listItems
              .where((element) => element.title.contains(textController.text))
              .toList();
        });
        setData(listItems); // Save data locally
      },
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.subTitle),
        onTap: () {
          // Go to drawing
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrawScreen(
                fileName: item.id,
                prefs: prefs,
              ),
            ),
          );
        },
      ),
    );
  }

  void addNewItemToList(String title, String subtitle) {
    MyListItem item = MyListItem(title, subtitle);
    setState(() {
      listItems.add(item);
      if (item.title.contains(textController.text)) {
        showItems.add(item);
      }
    });
    setData(listItems);
  }

  showAlertDialog(BuildContext context) {
    TextEditingController name = TextEditingController();
    RaisedButton cancel = RaisedButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(),
    );

    RaisedButton next = RaisedButton(
      child: Text("Next"),
      onPressed: () {
        if (name.text == "") {
          name.text = "Item ${listItems.length + 1}";
        }
        addNewItemToList(name.text, "");
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrawScreen(
              fileName: listItems.last.id,
              prefs: prefs,
            ),
          ),
        );
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Enter name of drawing"),
      content: TextField(
        controller: name,
      ),
      actions: [
        cancel,
        next,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    String encoded =
        (prefs.getString('files') ?? "[]"); // Stores list of MyListItems
    List<dynamic> dyn = jsonDecode(encoded); // Decode string to json
    // Create list of MyListItem from json
    List<MyListItem> temp =
        dyn.map((el) => MyListItem.fromJson(el)).toList().cast<MyListItem>();
    setState(() {
      listItems = temp;
      showItems = listItems
          .where((element) => element.title.contains(textController.text))
          .toList();
    });
  }

  setData(List<MyListItem> listItems) async {
    await prefs.setString('files', jsonEncode(listItems)); // Write to disk
  }

  @override
  void initState() {
    super.initState();
    getData(); // Load data from disk
  }

  @override
  void deactivate() {
    setData(listItems); // Write to disk before exiting
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Assignment"),
      ),
      body: ListView(
        children: <Widget>[
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search Drawing...",
                ),
                onChanged: (String newText) {
                  textController.text = newText;
                  setState(() {
                    showItems = listItems
                        .where((element) =>
                            element.title.contains(textController.text))
                        .toList(); // Filter items to show
                  });
                },
              )
            ] +
            getWidgetsList(showItems),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add",
        child: Icon(Icons.add),
        onPressed: () {
          showAlertDialog(context);
        },
      ),
    );
  }
}

class MyListItem {
  String title = "";
  String subTitle = "";
  String id = ""; // Unique id to store data

  MyListItem(String title, String subTitle) {
    this.title = title;
    this.subTitle = subTitle;
    this.id = UniqueKey().toString();
  }

  // Convert data to json to store locally
  Map<String, String> toJson() => {
        'title': title,
        'subTitle': subTitle,
        'id': id,
      };
  // Create MyListItem from decoded json
  MyListItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        subTitle = json['subTitle'],
        id = json['id'];
}
