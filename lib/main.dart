import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hero_test_app/pages/game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController text = TextEditingController();
  int level = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Noob Word Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*TextFormField(
              controller: text,
              minLines: 5,
              maxLines: 5,
            ),*/
            Text(
              'Select level',
              style:
                  TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.5)),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (level != 1) {
                        level--;
                      }
                    });
                  },
                  icon: Icon(
                    Icons.remove,
                    size: 36,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(1000),
                        ),
                        color: Colors.greenAccent),
                    child: Text(
                      '${level + 4}x${level + 4}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    )),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (level != 6) {
                        level++;
                      }
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    size: 36,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayGamePage(
                      level: level,
                      timeLimit: false,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'logo',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                    color: Colors.greenAccent,
                  ),
                  height: 50,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: Text(
                    'PLAY',
                    style: TextStyle(color: Colors.white),
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
            /*Expanded(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    print('copy');
                    Clipboard.setData(ClipboardData(text: '${text.text.replaceAll('\n', '\',\n\'')}'));
                  },
                  child: Text(
                      '${text.text.replaceAll('\n', '\',\n\'')}'),
                ),
              ),
            )),*/
          ],
        ),
      ),
    );
  }
}
