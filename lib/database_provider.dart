import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum TypesOfGroup { priceData, timeData, unknown }

class TypeConverter {
  static TypesOfGroup convert(String typeName) {
    switch(typeName) {
      case "Позиция - Стоимость":
        return TypesOfGroup.priceData;

      case "Позиция - Время":
        return TypesOfGroup.timeData;

      default:
        return TypesOfGroup.unknown;
    }
  }
}

abstract class AccountingData {
  AccountingData(this.date, this.positionName);

  DateTime date;
  String positionName;

  String getData();
}

class PriceData extends AccountingData {
  PriceData(super.date, super.positionName, this.price);
  double price;

  @override
  String getData() {
    return price.toString();
  }
}

class TimeData extends AccountingData {
  TimeData(super.data, super.positionName, this.time);
  DateTime time;

  @override
  String getData() {
    return time.toString();
  }
}

class DatabaseProvider {
  static final db_name = "accounting.db";
  static final db = _openDatabase();

  static Future<Database> _openDatabase() async {
    return openDatabase(join(await getDatabasesPath(), db_name), version: 1,
        onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE groups(
        groups_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(60),
        type_id INTEGER,
        FOREIGN KEY (type_id) REFERENCES type(type_id)
      );
      ''');
      await db.execute('''
      CREATE TABLE type(
        type_id INTEGER PRIMARY KEY AUTOINCREMENT,
        type_name VARCHAR(30)
      );
      ''');

      await db.execute('''
      CREATE TABLE time_data(
        time_data_id INTEGER PRIMARY KEY AUTOINCREMENT,
        groups_id INTEGER NOT NULL,
        date DATETIME,
        position VARCHAR(30),
        time DATETIME,
        FOREIGN KEY (groups_id) REFERENCES groups(groups_id) ON DELETE CASCADE
      );
      ''');

      await db.execute('''
      CREATE TABLE price_data(
        price_data_id INTEGER PRIMARY KEY AUTOINCREMENT,
        groups_id INTEGER NOT NULL,
        date DATETIME,
        position VARCHAR(30),
        price DECIMAL(8, 2),
        FOREIGN KEY (groups_id) REFERENCES groups(groups_id) ON DELETE CASCADE
      );
      ''');

      await db.execute('''
      INSERT INTO type(type_name)
      VALUES 
        ("Позиция - Стоимость"),
        ("Позиция - Время");
      ''');
    });
  }

  static Future<TypesOfGroup> getTypeOfGroup(String groupName) async {
    var _db = await db;

    return _db.transaction((txn) async {
      var queryResult = await txn.rawQuery(
        '''
        SELECT type_name
        FROM
          type
          INNER JOIN groups USING(type_id)
        WHERE groups.name = ?
        ''',
        [groupName]
      );

      String typeName = queryResult[0]["type_name"].toString();
      return TypeConverter.convert(typeName);
    });
  }

  static Future getGroupNames() async {
    Database _db = await db;
    return _db.transaction((txn) async {
      return await txn.rawQuery("SELECT name FROM groups");
    });
  }

  static Future<List<AccountingData>> getDataForGroup(String groupName) async {
    Database _db = await db;
    return _db.transaction((txn) async {
      TypesOfGroup group_type = await getTypeOfGroup(groupName);

      if (group_type == TypesOfGroup.timeData) {
        return (await txn.rawQuery(
          '''
          SELECT date, position, time
          FROM
            groups
            INNER JOIN time_data USING(groups_id)
          WHERE groups.name = ?
          ''', [groupName]
        )).map((element) => TimeData(
            DateTime.parse(element["date"].toString()),
            element["positionName"].toString(),
            DateTime.parse(element["time"].toString()))
        ).toList();
      } else if (group_type == TypesOfGroup.priceData) {
        return (await txn.rawQuery(
            '''
          SELECT date, position, time
          FROM
            groups
            INNER JOIN price_data USING(groups_id)
          WHERE groups.name = ?
          ORDER BY date DESC
          ''', [groupName]
        )).map((element) => PriceData(
            DateTime.parse(element["date"].toString()),
            element["positionName"].toString(),
            double.parse(element["price"].toString()))
        ).toList();
      }

      return [];
    });
  }
}
