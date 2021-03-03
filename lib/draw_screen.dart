import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawScreen extends StatefulWidget {
  final String fileName;

  DrawScreen({this.fileName});

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  SharedPreferences prefs;
  List<List<Point>> points = [
    [
      Point(
        coordinates: Offset(0, 0),
        paint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      ),
      Point(
        coordinates: Offset(100, 100),
        paint: Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      ),
    ],
  ];

  getData(String filename) async {
    prefs = await SharedPreferences.getInstance();
    String encodedPoints = (prefs.getString(filename) ?? "[]");
    List<dynamic> dyn = jsonDecode(encodedPoints);
    List<List<Point>> temp = dyn
        .map((li) {
          return li.map((el) => Point.fromJson(el)).toList().cast<Point>();
        })
        .toList()
        .cast<List<Point>>();
    setState(() {
      points = temp;
    });
  }

  setData(String filename) async {
    await prefs.setString(filename, jsonEncode(points));
  }

  @override
  void initState() {
    super.initState();
    getData(widget.fileName);
  }

  @override
  void deactivate() {
    setData(widget.fileName);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a drawing"),
      ),
      body: GestureDetector(
        onPanStart: (details) {
          Point point = Point(
            coordinates: details.localPosition,
            paint: Paint()
              ..color = Colors.black
              ..strokeWidth = 2,
          );
          setState(() => points.add([point]));
        },
        onPanUpdate: (details) {
          Point point = Point(
            coordinates: details.localPosition,
            paint: Paint()
              ..color = Colors.black
              ..strokeWidth = 2,
          );
          setState(() => points[points.length - 1].add(point));
        },
        onPanEnd: (details) {},
        child: Container(
          constraints: BoxConstraints.expand(),
          child: CustomPaint(
            painter: Painter(points: points),
          ),
        ),
      ),
      bottomNavigationBar: ButtonBar(
        children: [
          FlatButton(
            child: Icon(Icons.add),
            onPressed: null,
          ),
          FlatButton(
            child: Icon(Icons.close),
            onPressed: () {
              setState(() => points = []);
            },
          ),
        ],
      ),
    );
  }
}

class Painter extends CustomPainter {
  List<List<Point>> points;

  Painter({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Point p;
    List<Point> curve;
    for (int i = 0; i < points.length; i++) {
      curve = points[i];
      for (int j = 0; j < curve.length - 1; j++) {
        p = curve[j];
        canvas.drawLine(p.coordinates, curve[j + 1].coordinates, p.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Point {
  Offset coordinates;
  Paint paint;
  Point({this.coordinates, this.paint});
  Map<String, dynamic> toJson() => {
        'x': coordinates.dx.toString(),
        'y': coordinates.dy.toString(),
        'color': paint.color.value.toString(),
        'strokeWidth': paint.strokeWidth.toString(),
      };
  Point.fromJson(Map<String, dynamic> json)
      : coordinates = Offset(double.parse(json['x']), double.parse(json['y'])),
        paint = Paint()
          ..color = Color(int.parse(json['color']))
          ..strokeWidth = double.parse(json['strokeWidth']);
}
