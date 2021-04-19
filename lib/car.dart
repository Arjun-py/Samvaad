import 'package:Samvaad/dbhelper.dart';
import 'dart:typed_data';
class Car {
  int id;
  String name;
  String miles;
  String freq;

  Car(this.id, this.name, this.miles, this.freq);

  Car.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    miles = map['miles'];
    freq = map['freq'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles,
      DatabaseHelper.columnFreq: freq,
    };
  }
}