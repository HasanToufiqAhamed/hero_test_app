import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:hero_test_app/touch/position.dart';
import 'package:hero_test_app/ws/word_search.dart';

class DrawingArea {
  Offset? point;
  Paint? areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class HeroPage extends StatefulWidget {
  const HeroPage({Key? key}) : super(key: key);

  @override
  _HeroPageState createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  List<List<String>> modText = [];
  int puzzleHW = 5;
  List<String> selectedBox = [];

  List<List<Position>> position = [];
  List<List<Offset>> positionCenter = [];
  Offset? lastUpdateLocation;

  final List<String> wl = ['hello', 'world', 'fool', 'bar', 'kids', 'dart'];

  // List<DrawingArea>? points = [];
  List<DrawingPoints> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 25;
  bool puzzleDone = false;

  Offset? startPoint;

  @override
  void initState() {
    super.initState();
    makePuzzle(puzzleHW, wl);
  }

  @override
  Widget build(BuildContext context) {
    double displayH = MediaQuery.of(context).size.height;
    double displayW = MediaQuery.of(context).size.width;

    double puzzleW = MediaQuery.of(context).padding.top;
    double puzzleH = MediaQuery.of(context).size.width;

    double extraHeight = displayH - displayW;
    double puzzleEndH = displayH - MediaQuery.of(context).padding.top;

    if (!puzzleDone) {
      makePosition(puzzleHW, displayH, displayW, extraHeight);
    }

    GlobalKey key = GlobalKey();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedBox.clear();
                  points.clear();
                });
              },
              child: Text('reset'),
            ),
            Row(
              children: [
                Container(
                  height: 10,
                  width: displayW / 5,
                  color: Colors.red,
                ),
                Container(
                  height: 10,
                  width: displayW / 5,
                  color: Colors.blue,
                ),
                Container(
                  height: 10,
                  width: displayW / 5,
                  color: Colors.black,
                ),
                Container(
                  height: 10,
                  width: displayW / 5,
                  color: Colors.green,
                ),
                Container(
                  height: 10,
                  width: displayW / 5,
                  color: Colors.red,
                ),
              ],
            ),
            ClipRRect(
              child: Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: puzzleHW,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index1) => Row(
                        children: [
                          Container(
                            height:
                                MediaQuery.of(context).size.width / puzzleHW,
                            child: ListView.builder(
                              itemCount: puzzleHW,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index2) => Row(
                                children: [
                                  GestureDetector(
                                    onPanStart: (a) {
                                      print('${a.localPosition}');
                                    },
                                    onPanUpdate: (a) {
                                      print('${a.globalPosition}');
                                    },
                                    onTap: () {
                                      setState(() {
                                        if (!selectedBox
                                            .contains('$index1$index2')) {
                                          selectedBox.add('$index1$index2');
                                        }
                                      });
                                      // print(selectedBox);

                                      print('$index1 $index2');

                                      print(
                                          'leftT: [$index1 $index2] ${position[index1][index2].leftT!.dx} ${position[index1][index2].leftT!.dy}');
                                      print(
                                          'leftB: [$index1 $index2] ${position[index1][index2].leftB!.dx} ${position[index1][index2].leftB!.dy}');
                                      print(
                                          'rightT: [$index1 $index2] ${position[index1][index2].rightT!.dx} ${position[index1][index2].rightT!.dy}');
                                      print(
                                          'rightB: [$index1 $index2] ${position[index1][index2].rightB!.dx} ${position[index1][index2].rightB!.dy}');
                                      print(
                                          'x: [$index1 $index2] ${positionCenter[index1][index2].dx}');
                                      print(
                                          'y: [$index1 $index2] ${positionCenter[index1][index2].dy}');
                                    },
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        child: Container(
                                          height: double.maxFinite,
                                          width: double.maxFinite,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: selectedBox.contains(
                                                      ('$index1$index2'))
                                                  ? Colors.red.withOpacity(0.6)
                                                  : Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                            '${modText[index1][index2].toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          lastUpdateLocation = renderBox.globalToLocal(
                            Offset(startPoint!.dx, details.localPosition.dy),
                          );
                          points.add(
                            DrawingPoints(
                                points: renderBox.globalToLocal(
                                  Offset(
                                    positionCenter[0][0].dx,
                                    details.localPosition.dy,
                                  ),
                                ),
                                paint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = false
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth),
                          );
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          points.add(
                            DrawingPoints(
                              points:
                                  renderBox.globalToLocal(lastUpdateLocation!),
                              paint: Paint()
                                ..strokeCap = StrokeCap.round
                                ..isAntiAlias = false
                                ..color = selectedColor.withOpacity(0)
                                ..strokeWidth = 0,
                            ),
                          );
                        });
                      },
                      onPanStart: (details) {
                        setState(() {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;


                          startPoint = renderBox.globalToLocal(
                            details.localPosition,
                          );
                        });
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DrawingPainter(
                          pointsList: points,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void makePuzzle(int i, List<String> puzzleStringList) {
    final WSSettings ws = WSSettings(
      width: i,
      height: i,
      orientations: List.from([
        WSOrientation.horizontal,
        WSOrientation.vertical,
        WSOrientation.diagonal,
      ]),
    );

    final WordSearch wordSearch = WordSearch();
    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(puzzleStringList, ws);

    if (newPuzzle.errors.isEmpty) {
      // The puzzle output
      print(newPuzzle.toString().replaceAll(' ', ''));

      print(newPuzzle.puzzle!);

      setState(() {
        modText = newPuzzle.puzzle!;
      });

      // Solve puzzle for given word list
      final WSSolved solved =
          wordSearch.solvePuzzle(newPuzzle.puzzle!, ['dart', 'word']);
      // All found words by solving the puzzle
      solved.found.forEach((element) {
        print('word: ${element.word}, orientation: ${element.orientation}');
        print('x:${element.x}, y:${element.y}');
      });

      // All words that could not be found
      print('Not found Words!');
      solved.notFound.forEach((element) {
        print('word: ${element}');
      });
    } else {
      // Notify the user of the errors
      newPuzzle.errors.forEach((error) {
        print(error);
      });
    }
  }

  void makePosition(
    int boxNumber,
    double displayH,
    double displayW,
    double ex,
  ) {
    puzzleDone = true;
    double boxHW = displayW / boxNumber;
    List<Position> position2d = [];
    List<Offset> positionCenter2d = [];

    for (int a = 0; a != boxNumber; a++) {
      print(a);
      position2d = [];
      positionCenter2d = [];

      double x = ex + (boxHW * a);

      double z = x + boxHW;

      for (int b = 0; b != boxNumber; b++) {
        double start = 0;

        double w = start + (boxHW * b);
        double y = w + boxHW;

        // if (b==0)print(x);
        position2d.add(
          Position(
            Offset(w, x),
            Offset(w, z),
            Offset(y, x),
            Offset(y, z),
          ),
        );

        positionCenter2d.add(
          Offset(
              (position2d[b].leftT!.dx +
                      position2d[b].leftB!.dx +
                      position2d[b].rightT!.dx +
                      position2d[b].rightB!.dx) /
                  4,
              (position2d[b].leftT!.dy +
                      position2d[b].leftB!.dy +
                      position2d[b].rightT!.dy +
                      position2d[b].rightB!.dy) /
                  4),
        );
      }

      setState(() {
        position.add(position2d);
        positionCenter.add(positionCenter2d);
      });

      print(
          'leftT: [${position.length - 1} 0] ${position[position.length - 1][0].leftT!.dy}');
      print(
          'leftB: [${position.length - 1} 0] ${position[position.length - 1][0].leftB!.dy}');
    }
  }

  void extract() {
    for (int a = 0; a != position.length; a++) {
      for (int b = 0; b != position[a].length; b++) {
        print('leftB: [$a $b] ${position[a][b].leftT!.dy}');
      }
    }
  }
}

class MyPainter extends CustomPainter {
  //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(50, 50);
    final p2 = Offset(250, 150);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea>? points;

  MyCustomPainter({@required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (int x = 0; x < points!.length - 1; x++) {
      if (points![x] != null && points![x + 1] != null) {
        canvas.drawLine(
            points![x].point!, points![x + 1].point!, points![x].areaPaint!);
      } else if (points![x] != null && points![x + 1] == null) {
        canvas.drawPoints(
            PointMode.points, [points![x].point!], points![x].areaPaint!);
      }
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class DrawingPoints {
  Paint? paint;
  Offset? points;

  DrawingPoints({this.points, this.paint});
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.pointsList});

  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points!, pointsList[i + 1].points!,
            pointsList[i].paint!);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points!);
        offsetPoints.add(Offset(
            pointsList[i].points!.dx + 0.1, pointsList[i].points!.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint!);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
