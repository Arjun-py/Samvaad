
import 'package:flutter/material.dart';
import 'package:Samvaad/car.dart';
import 'package:Samvaad/dbhelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

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
      home: Admin(),
    );
  }
}
class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  File _image;
  String _imagepath;
  final dbHelper = DatabaseHelper.instance;
  //String txt;
  String text;
  final FlutterTts flutterTts = FlutterTts();
  GoogleTranslator translator = GoogleTranslator();
  String lang = 'en';
  String category = "All";
  var _val = false;
  var _valu = false;
  String miles;
  String name;
  String freq;
  String texte="";

  List<Car> cars = [];
  List<Car> carsByName = [];
  List<String> categories = ['All', 'I Want', 'I Like', 'Questions', 'Emergency', 'Other'];

  //controller used in insert operation UI
  TextEditingController nameController = TextEditingController();

  //controller used in update operation UI
  TextEditingController nameUpdateController = TextEditingController();

  // controller used for search UI
  TextEditingController queryController = TextEditingController();

  TextEditingController categoryController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
        )
    );
  }
  @override

  void initState() {
    super.initState();
    _queryAll();
    _queryCategories();
  }

  Widget build(BuildContext context) {
    Future _speak(txt) async{
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
          bottom: TabBar(
            tabs: [
              Tab(
                text: "My Voice",
              ),

              Tab(
                text: "Search",
              ),

              Tab(
                text: "Add Voice",
              ),
            ],
          ),
          title: Text('Samvaad',style:TextStyle(fontStyle: FontStyle.italic)),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              body: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: cars.length + 1,
                itemExtent: 75.0,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cars.length) {
                    return Column(
                      children: [
                        SizedBox(height: 10,),
                      ],
                    );
                  }
                  Uint8List bytes = base64Decode(cars[index].miles);
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
                        child:
                        Image.memory((bytes), fit: BoxFit.cover),),
                      onTap: (){
                        setState(() {
                          text = cars[index].name;
                          void _translate(lang) {
                            translator.translate(text, to:lang).then((output){
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
                        cars[index].name,
                        style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Text(cars[index].freq),
                      trailing: ButtonBar(
                        mainAxisSize: MainAxisSize.min,
                        buttonPadding: EdgeInsets.all(5),
                        children: [
                          FloatingActionButton(
                            heroTag:"btn268950",
                            child: Icon(Icons.update),
                            mini:true,
                            onPressed:(){
                              _showDialog() async {
                                await showDialog<String>(context: context,
                                  child: new AlertDialog(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    content: new Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[

                                        TextField(
                                          controller: nameUpdateController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Enter Text',
                                          ),
                                        ),
                                        SizedBox(height: 15,),
                                        _imagepath != null
                                            ? CircleAvatar(
                                          backgroundImage: FileImage(File(_imagepath)),
                                          radius: 80,
                                        )
                                            : CircleAvatar(
                                          radius: 60,
                                          backgroundImage: _image != null
                                              ? FileImage(_image)
                                              : AssetImage(
                                            'assets/LOGO.png',
                                          ),
                                        ),
                                        DropdownButton<String>(
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
                                      ],
                                    ),

                                    actions: <Widget>[
                                      FloatingActionButton(
                                        heroTag:"btn3",
                                        onPressed: () {
                                          PickImage();
                                        },
                                        child: Icon(Icons.add_a_photo),
                                      ),

                                      FloatingActionButton(
                                        heroTag:"btn4",
                                        child: Icon(Icons.save),
                                        onPressed: () {
                                          int id = cars[index].id;
                                          String name = nameUpdateController.text;
                                          String miles = Utility.base64String(_image.readAsBytesSync());
                                          String freq = category;
                                          _update(id, name, miles, freq);
                                          Navigator.of(context).pop();
                                          _queryAll();
                                          _queryCategories();
                                        },
                                      ),
                                      FloatingActionButton(
                                        heroTag:"btn5",
                                        child:Icon(Icons.clear),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                              _showDialog();
                            },
                            //backgroundColor: Colors.red,
                          ),
                          FloatingActionButton(
                            heroTag:"btn6",
                            mini:true ,
                            child: Icon(Icons.delete),
                            onPressed: (){
                              Future<void> _showMyDialog() async {
                                return showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Alert'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text('Do you want to delete the selected AWAAZ'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            FloatingActionButton(
                                              heroTag:"btn7",
                                              child: Icon(Icons.done),
                                              onPressed: (){
                                                _delete(cars[index].id);
                                                _queryAll();
                                                _queryCategories();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            SizedBox(width: 50,),
                                            FloatingActionButton(
                                              heroTag:"btn8",
                                              child:Icon(Icons.clear),
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              _showMyDialog();
                            },
                          ),
                        ],
                      ),


                    ),
                  );
                },
              ),
              floatingActionButton: DropdownButton<String>(
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
                    //print(category);
                    if(category=="All")
                      _queryAll();
                    else
                      _queryF(category);
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
            /////////////////////////////////////////////////////////////////////////////////
            /////////////////////////////////////////////////////////////////////////////////
            Center(
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          height: 100,
                          padding: EdgeInsets.all(20),
                          child: TextField(
                            controller: queryController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Text',
                            ),
                            onChanged: (texte) {
                              if (texte.length >= 1) {
                                setState(() {
                                  _query(texte,category);
                                });
                              }
                              else {
                                setState(() {
                                  carsByName.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      DropdownButton<String>(
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
                    ],
                  ),

                  Flexible(
                    child: Container(
                      height: 500,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: carsByName.length,
                        itemBuilder: (BuildContext context, int index) {
                          Uint8List bytes = base64Decode(carsByName[index].miles);
                          return Card(
                            child: ListTile(
                              // leading: new Image.memory(bytes,width: 50,height: 50,),
                              leading: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 500,
                                  maxWidth: 300,
                                  maxHeight: 500,
                                ),
                                child:
                                Image.memory((bytes), fit: BoxFit.cover),),
                              onTap: (){
                                setState(() {
                                  text = carsByName[index].name;
                                  void _translate(lang) {
                                    translator.translate(text, to:lang).then((output){
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
                                style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold
                                ),
                              ),
                              subtitle: Text(carsByName[index].freq),
                              trailing: ButtonBar(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FloatingActionButton(
                                    heroTag:"btn9",
                                    child: Icon(Icons.update),
                                    mini:true,
                                    onPressed:(){
                                      _showDialog() async {
                                        await showDialog<String>(context: context,
                                          child: new AlertDialog(
                                            contentPadding: const EdgeInsets.all(16.0),
                                            content: new Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[

                                                TextField(
                                                  controller: nameUpdateController,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: 'Enter Text',
                                                  ),
                                                ),
                                                SizedBox(height: 15,),
                                                _imagepath != null
                                                    ? CircleAvatar(
                                                  backgroundImage: FileImage(File(_imagepath)),
                                                  radius: 80,
                                                )
                                                    : CircleAvatar(
                                                  radius: 60,
                                                  backgroundImage: _image != null
                                                      ? FileImage(_image)
                                                      : AssetImage(
                                                    'assets/LOGO.png',
                                                  ),
                                                ),
                                                DropdownButton<String>(
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
                                              ],
                                            ),

                                            actions: <Widget>[
                                              FloatingActionButton(
                                                heroTag:"btn10",
                                                onPressed: () {
                                                  PickImage();
                                                },
                                                child: Icon(Icons.add_a_photo),
                                              ),

                                              FloatingActionButton(
                                                heroTag:"btn11",
                                                child: Icon(Icons.save),
                                                onPressed: () {
                                                  int id = cars[index].id;
                                                  String name = nameUpdateController.text;
                                                  String miles = Utility.base64String(_image.readAsBytesSync());
                                                  String freq = category;
                                                  _update(id, name, miles, freq);
                                                  _queryAll();
                                                  _queryCategories();
                                                  _query(name,category);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              FloatingActionButton(
                                                heroTag:"btn12",
                                                child:Icon(Icons.clear),
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      _showDialog();
                                    },
                                    //backgroundColor: Colors.red,
                                  ),
                                  FloatingActionButton(
                                    heroTag:"btn13",
                                    mini:true ,
                                    child: Icon(Icons.delete),
                                    onPressed: (){
                                      Future<void> _showMyDialog() async {
                                        return showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Alert'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Do you want to delete the selected AWAAZ'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    FloatingActionButton(
                                                      heroTag:"btn14",
                                                      child: Icon(Icons.done),
                                                      onPressed: (){
                                                        _delete(cars[index].id);
                                                        _query(cars[index].name, cars[index].freq);
                                                        _queryAll();
                                                        _queryCategories();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    SizedBox(width: 50,),
                                                    FloatingActionButton(
                                                      heroTag:"btn15",
                                                      child:Icon(Icons.clear),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      _showMyDialog();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////

            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter Text',
                              ),
                            ),
                          ),
                        ),
                        FloatingActionButton(
                          heroTag: "btn16",
                          child: Icon(Icons.category, color: Colors.white,),
                          onPressed:(){
                            _showDialog() async {
                              await showDialog<String>(context: context,
                                child: new AlertDialog(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  content: new Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      DropdownButton<String>(
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
                                    ],
                                  ),

                                  actions: <Widget>[
                                    FloatingActionButton(
                                      heroTag:"btn17",
                                      child: Icon(Icons.add),
                                      onPressed:(){
                                        _showDialog() async {
                                          await showDialog<String>(context: context,
                                            child: new AlertDialog(
                                              contentPadding: const EdgeInsets.all(16.0),
                                              content: new Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[

                                                  TextField(
                                                    controller: categoryController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      labelText: 'Enter Category Name',
                                                    ),
                                                  ),
                                                  SizedBox(height: 15,),
                                                ],
                                              ),

                                              actions: <Widget>[
                                                FloatingActionButton(
                                                  heroTag:"btn18",
                                                  onPressed: () {
                                                    String newCategory = categoryController.text;
                                                    print(categories);
                                                    print(categories.length);
                                                    categories.contains(newCategory)?
                                                    print("hello"):
                                                    categories.insert(categories.length, newCategory);
                                                    print(categories);
                                                    category=newCategory;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Icon(Icons.done),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        _queryCategories();
                                        _showDialog();
                                      },
                                    ),
                                    FloatingActionButton(
                                      heroTag:"btn19",
                                      child:Icon(Icons.clear),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                            _showDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  _imagepath != null
                      ? CircleAvatar(
                    backgroundImage: FileImage(File(_imagepath)),
                    radius: 80,
                  )
                      : CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image)
                        : AssetImage(
                      'assets/LOGO.png',
                    ),
                  ),
                  SizedBox(height:16.5),

                  Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag:"btn20",
                            onPressed: () {
                              PickImage();
                            },
                            child: Icon(Icons.add_a_photo),
                          ),
                          FloatingActionButton(
                            heroTag:"btn21",

                            child: Icon(Icons.save),
                            onPressed: () {
                              //List<int> bytes = _image.readAsBytesSync();
                              miles = Utility.base64String(_image.readAsBytesSync());
                              name = nameController.text;
                              freq = category;
                              print("freq: $freq");
                              _insert(name, miles, freq);
                              _queryAll();
                              //print(miles);
                            },
                          ),
                        ],
                      )
                  ),
                ],
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

  void _queryCategories() async {
    final categs = await dbHelper.queryCategory();
    //categories.clear();
    categs.forEach((categ) {
      categories.contains(categ.values.first)
          ? print("hi")
          : categories.add(categ.values.first);
    });
    //await dbHelper.queryCategory();
    setState(() {});
  }

  // void _addCateg(freq) async {
  //   await dbHelper.insertCategory(freq);
  //   _showMessageInScaffold('Added Category');
  // }

  void _insert(name, miles, freq) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles,
      DatabaseHelper.columnFreq: freq,
    };
    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold('Added AWAAZ');
  }

  void _update(id, name, miles, freq) async {
    // row to update
    Car car = Car(id, name, miles, freq);
    final rowsAffected = await dbHelper.update(car);
    _showMessageInScaffold('Updated AWAAZ');
  }

  void _delete(id) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(id);
    _showMessageInScaffold('Deleted AWAAZ');
  }

  void _query(name,category) async {
    final allRows = await dbHelper.queryRows(name, category);
    carsByName.clear();
    allRows.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  void _queryF(category) async{
    final allRows = await dbHelper.queryAllF(category);
    cars.clear();
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    setState(() {});
  }

  void PickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
  void SaveImage(path) async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    saveimage.setString("imagepath", path);
  }

  void LoadImage() async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    setState(() {
      _imagepath = saveimage.getString("imagepath");
    });
  }

}