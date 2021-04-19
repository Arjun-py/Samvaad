import 'package:flutter/material.dart';
import 'package:Samvaad/car.dart';
import 'package:Samvaad/dbhelper.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:Samvaad/language.dart';
import 'package:Samvaad/cat.dart';

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samvaad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryBlack,
      ),
      home: User(),
    );
  }
}

class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  File _image;
  String _imagepath;
  final dbHelper = DatabaseHelper.instance;
  //String txt;
  String text;
  final FlutterTts flutterTts = FlutterTts();
  GoogleTranslator translator = GoogleTranslator();
  String lang = 'en';
  String category = "All";
  String texte = "";

  List<Car> cars = [];
  List<Car> carsByName = [];
  List<String> categories = [
    'All',
    'I Want',
    'I Like',
    'Questions',
    'Emergency',
    'Other'
  ];

  TextEditingController queryController = TextEditingController();

  List<Languages> languages = [
    Languages(displayText: 'English', lang: 'en'),
    Languages(displayText: 'हिंदी', lang: 'hi'),
    Languages(displayText: 'ಕನ್ನಡ', lang: 'kn'),
    Languages(displayText: 'தமிழ்', lang: 'ta'),
    Languages(displayText: 'తెలుగు', lang: 'te'),

  ];

  List<Cats> cats = [
    Cats(name: 'All', icon: 'assets/all.jpg'),
    Cats(name: 'I Want', icon: 'assets/want.jpg'),
    Cats(name: 'I Like', icon: 'assets/like.jpg'),
    Cats(name: 'Questions', icon: 'assets/questions.jpg'),
    Cats(name: 'Emergency', icon: 'assets/emergency.jpg'),
    Cats(name: 'Other', icon: 'assets/other.jpg'),
  ];
  String ic = "assets/extra.jpg";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    _queryAll();
    _queryCategories();
  }

  Widget build(BuildContext context) {
    Future _speak(txt) async {
      await flutterTts.setPitch(1);
      await flutterTts.setVolume(1);
      //await flutterTts.setVoice("hi-x-sfg#male_1-local");
      await flutterTts.setLanguage("hi");
      await flutterTts.speak(txt);
      //print(await flutterTts.getLanguages);
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/admin');
                },
                child: Icon(Icons.admin_panel_settings, size: 30),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: "My Voice",
              ),
              Tab(
                text: "Search",
              ),
              Tab(
                text: "Language",
              ),
            ],
          ),
          title: Text(
            'Samvaad',
            style: TextStyle(
                fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 100,
                  child: DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Select Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(color: primaryBlack),
                  ),
                ),
                Flexible(child: Container(
                  height: 500,
                    child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: cats.length,
                  //itemExtent: 75.0,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: EdgeInsets.all(10),
                        child: ListTile(
                          leading: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 100,
                              minHeight: 70,
                              maxWidth: 120,
                              maxHeight: 84,
                            ),
                            child: Image.asset((cats[index].icon), fit: BoxFit.cover),
                          ),
                          onTap: () {
                            setState(() {
                              category = cats[index].name;
                              //print(category);
                              if (category == "All") {
                                _queryAll();
                                _queryCategories();
                              }
                              else {
                                _queryF(category);
                                _queryCategories();
                              }
                              Navigator.of(context).pop();
                            });
                          },
                          title: Text(
                            cats[index].name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ));
                  },
                ),),),
                FloatingActionButton(heroTag:"btn1", child: Icon(Icons.refresh),onPressed:()
                  {_queryCategories();},)
              ],
            )
        ),
        body: TabBarView(
          children: [
            Scaffold(
              backgroundColor: Colors.grey[300],
              body: GridView.builder(
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                padding: const EdgeInsets.all(8),
                itemCount: cars.length + 1,
                //itemExtent: 75.0,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cars.length) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }
                  Uint8List bytes = base64Decode(cars[index].miles);
                  return Card(
                    elevation: 15,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: GridTile(
                      // leading: new Image.memory(bytes,width: 50,height: 50,),
                      child: new InkResponse(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(children: [
                          Flexible(child:Image.memory((bytes),),),
                          Text(
                            cars[index].name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(cars[index].freq),
                        ],),),
                        onTap: () {
                          setState(() {
                            text = cars[index].name;
                            void _translate(lang) {
                              translator.translate(text, to: lang).then((output) {
                                setState(() {
                                  text = output.toString();
                                  print(text);
                                  _speak(text);
                                });
                              });
                            }

                            _translate(lang);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            Scaffold(
              backgroundColor: Colors.grey[300],
              body: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          height: 100,
                          padding: EdgeInsets.all(20),
                          child: Card(
                            elevation: 10,
                            child: TextField(
                              controller: queryController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter Text',
                              ),
                              onChanged: (texte) {
                                if (texte.length >= 1) {
                                  setState(() {
                                    _query(texte, category);
                                  });
                                } else {
                                  setState(() {
                                    carsByName.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: DropdownButton<String>(
                            value: category,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: primaryBlack),
                            underline: Container(
                              height: 2,
                              color: primaryBlack,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                category = newValue;
                                _query(texte, category);
                              });
                            },
                            items: categories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      height: 500,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: carsByName.length,
                        itemBuilder: (BuildContext context, int index) {
                          Uint8List bytes =
                          base64Decode(carsByName[index].miles);
                          return Card(
                            elevation: 15,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              // leading: new Image.memory(bytes,width: 50,height: 50,),
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 500,
                                  maxWidth: 300,
                                  maxHeight: 500,
                                ),
                                child: Image.memory((bytes), fit: BoxFit.cover),
                              ),
                              onTap: () {
                                setState(() {
                                  text = carsByName[index].name;
                                  void _translate(lang) {
                                    translator
                                        .translate(text, to: lang)
                                        .then((output) {
                                      setState(() {
                                        text = output.toString();
                                        print(text);
                                        _speak(text);
                                      });
                                    });
                                  }

                                  _translate(lang);
                                });
                              },
                              title: Text(
                                carsByName[index].name,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(carsByName[index].freq),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////////////////////

            Scaffold(
              backgroundColor: Colors.grey[300],
              body: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation:(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          lang = languages[index].lang;
                        });
                        _showMessageInScaffold('Language Selected');
                      },
                      title: Text(languages[index].displayText,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cars.clear();
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    setState(() {});
  }

  void _queryF(category) async {
    final allRows = await dbHelper.queryAllF(category);
    cars.clear();
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    setState(() {});
  }

  void _queryCategories() async {
    final categs = await dbHelper.queryCategory();
    //categories.clear();
    categs.forEach((categ) {
      categories.contains(categ.values.first)
          ? print("hi")
          : appendCat(categ.values.first);
          // : categories.add(categ.values.first);
          // : Cats newCat = new Cats(name: categ.values.first, icon: "assets/LOGO.png");
      //print(categories);
      //Cats newCat = new Cats(name: categ.values.first, icon: );
      //print(newCat);

    });
    //await dbHelper.queryCategory();
    setState(() {});
  }

  void _query(name, category) async {
    final allRows = await dbHelper.queryRows(name, category);
    carsByName.clear();
    allRows.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  void LoadImage() async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    setState(() {
      _imagepath = saveimage.getString("imagepath");
    });
  }
  void appendCat(c) async {
    categories.add(c);
    Cats newCat = new Cats(name: c, icon: "assets/extra.jpg");
    cats.add(newCat);
  }
}

