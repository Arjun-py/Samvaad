import 'package:Samvaad/car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final _databaseName = "cardb.db";
  static final _databaseVersion = 1;

  static final table = 'cars_table';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnMiles = 'miles';
  static final columnFreq = 'freq';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT,
            $columnMiles TEXT, 
            $columnFreq TEXT
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Car car) async {
    Database db = await instance.database;
    return await db.insert(table, {'name': car.name, 'miles': car.miles, 'freq': car.freq,});
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllF(category) async {
    Database db = await instance.database;
    print("$category");
    // print(await db.query(table, where: "$columnFreq LIKE '%$category%'"));
    return await db.query(table, where: "$columnFreq LIKE '%$category%'");
  }

  Future<int> insertCategory(category) async {
    Database db = await instance.database;
    // print(await db.query(table, where: "$columnFreq LIKE '%$category%'"));
    return await db.rawInsert('INSERT INTO $table ($columnFreq) VALUES ("$category")');
  }

  Future<List<Map<String, dynamic>>> queryCategory() async {
    Database db = await instance.database;
    // print(await db.query(table, where: "$columnFreq LIKE '%$category%'"));
    return await db.rawQuery("SELECT DISTINCT $columnFreq FROM $table");
  }

  // Queries rows based on the argument received
  Future<List<Map<String, dynamic>>> queryRows(name, category) async {
    Database db = await instance.database;
    if(category == "All"){
      return await db.rawQuery("SELECT * FROM $table WHERE $columnName LIKE '%$name%'");
    }
    //return await db.query(table, where: "$columnName LIKE '%$name%'");
    else {
      return await db.rawQuery(
          "SELECT * FROM $table WHERE $columnName LIKE '%$name%' AND $columnFreq LIKE '%$category%'");
    }
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Car car) async {
    Database db = await instance.database;
    int id = car.toMap()['id'];
    return await db.update(table, car.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}