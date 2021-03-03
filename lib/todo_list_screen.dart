import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'draw_screen.dart';

class MyListItem {
  String title = "";
  String subTitle = "";
  String id = "";

  MyListItem(String title, String subTitle) {
    this.title = title;
    this.subTitle = subTitle;
    this.id = UniqueKey().toString();
  }

  Map<String, String> toJson() => {
        'title': title,
        'subTitle': subTitle,
        'id': id,
      };
  MyListItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        subTitle = json['subTitle'],
        id = json['id'];
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  SharedPreferences prefs;
  List<ListTile> getWidgetsList(List<MyListItem> listItems) {
    List<ListTile> widgets = [];
    for (int i = 0; i < listItems.length; i++) {
      widgets.add(ListTile(
        title: Text(listItems[i].title),
        subtitle: Text(listItems[i].subTitle),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DrawScreen(fileName: listItems[i].id)),
          );
        },
      ));
    }
    return widgets;
  }

  List<MyListItem> listItems = [
    MyListItem("Item 1", "Subtitle 1"),
    MyListItem("Item 2", "Subtitle 2")
  ];
  List<MyListItem> showItems = [
    MyListItem("Item 1", "Subtitle 1"),
    MyListItem("Item 2", "Subtitle 2")
  ];

  TextEditingController textController = TextEditingController();

  void addNewItemToList(String title, String subtitle) {
    MyListItem item = MyListItem(title, subtitle);
    setState(() {
      listItems.add(item);
      if (item.title.contains(textController.text)) {
        showItems.add(item);
      }
    });
    setData();
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
              builder: (context) => DrawScreen(fileName: listItems.last.id)),
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
    String encoded = (prefs.getString('files') ?? "[]");
    List<dynamic> dyn = jsonDecode(encoded);
    List<MyListItem> temp =
        dyn.map((el) => MyListItem.fromJson(el)).toList().cast<MyListItem>();
    setState(() {
      listItems = temp;
      showItems = listItems
          .where((element) => element.title.contains(textController.text))
          .toList();
    });
  }

  setData() async {
    await prefs.setString('files', jsonEncode(listItems));
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void deactivate() {
    setData();
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
                        .toList();
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
