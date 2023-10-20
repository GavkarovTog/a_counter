import 'package:a_counter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum TypesOfGroup { priceData, timeData, unknown }

class Type {
  static const List<TypesOfGroup> groupTypes = [ TypesOfGroup.priceData, TypesOfGroup.timeData ];

  static TypesOfGroup fromStringToEnum(String typeName) {
    switch(typeName) {
      case "Позиция - Стоимость":
        return TypesOfGroup.priceData;

      case "Позиция - Время":
        return TypesOfGroup.timeData;

      default:
        return TypesOfGroup.unknown;
    }
  }

  static String fromEnumToString(TypesOfGroup typeName) {
    switch(typeName) {
      case TypesOfGroup.priceData:
        return "Позиция - Стоимость";

      case TypesOfGroup.timeData:
        return "Позиция - Время";

      default:
        return "Неизвестно";
    }
  }

  static int fromEnumToId(TypesOfGroup typeName) {
    switch(typeName) {
      case TypesOfGroup.priceData:
        return 1;

      case TypesOfGroup.timeData:
        return 2;

      default:
        return -1;
    }
  }

  static int fromStringToId(String typeName) {
    switch(typeName) {
      case "Позиция - Стоимость":
        return 1;

      case "Позиция - Время":
        return 2;

      default:
        return -1;
    }
  }
}

abstract class AccountingData {
  AccountingData(this.id, this.date, this.positionName);

  int id;
  DateTime date;
  String positionName;

  String getData();
}

String convertTo2digit(int dayOrMonth) {
  if (dayOrMonth < 10)
    return "0$dayOrMonth";

  return dayOrMonth.toString();
}

class PriceData extends AccountingData {
  PriceData(super.id, super.date, super.positionName, this.price);
  double price;

  @override
  String getData() {
    return price.toStringAsFixed(2);
  }
}

class TimeData extends AccountingData {
  TimeData(super.id, super.data, super.positionName, this.time);
  DateTime time;

  @override
  String getData() {
    return "${time.hour}:${time.minute < 10 ? "0${time.minute}" : time.minute}";
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

  static Future<List<Group>> getGroupInfo() async {
    Database _db = await db;
    var result = await _db.transaction((txn) async {
       return await txn.rawQuery(
          """
          SELECT groups.name, type_name
          FROM
            groups
            INNER JOIN type USING(type_id)
          """);
    });

    List<Group> groups = [];
    for (var entry in result) {
      groups.add(Group(entry["name"].toString(), Type.fromStringToEnum(entry["type_name"].toString())));
    }

    return groups;
  }

  static Future getPriceDataForGroup(String groupName) async {
    var _db = await db;

    return _db.transaction((txn) async {
      return (await txn.rawQuery(
          '''
          SELECT price_data_id, date, position, price
          FROM
            groups
            INNER JOIN price_data USING(groups_id)
          WHERE groups.name = ?
          ORDER BY date DESC
          ''', [groupName]
      ));
    });
  }

  static Future getTimeDataForGroup(String groupName) async {
    var _db = await db;

    return _db.transaction((txn) async {
      return (await txn.rawQuery(
          '''
            SELECT time_data_id, date, position, time
            FROM
              groups
              INNER JOIN time_data USING(groups_id)
            WHERE groups.name = ?
            ORDER BY date DESC
            ''', [groupName]
      ));
    });
  }

  static Future<bool> deletePriceDataById(int id) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawDelete(
        '''
          DELETE FROM price_data
          WHERE price_data.price_data_id = ?
        ''',
        [id]
      );
    });

    return true;
  }

  static Future<bool> deleteTimeDataById(int id) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawDelete(
          '''
          DELETE FROM time_data
          WHERE time_data.time_data_id = ?
        ''',
          [id]
      );
    });

    return true;
  }

  static void addGroup(String groupName, TypesOfGroup groupType) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawInsert(
        """
        INSERT INTO groups(name, type_id)
        VALUES (?, ?)
        """,
        [groupName, Type.fromEnumToId(groupType)]
      );
    });
  }

  static Future<bool> addPriceData(String groupName, DateTime date, String positionName, double price) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawQuery(
      """
      INSERT INTO price_data(groups_id, date, position, price)
      SELECT groups_id, "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}", ?, ?
      FROM groups
      WHERE groups.name = ?
      """,
      [positionName, price, groupName]);
    });

    return true;
  }

  static Future<bool> addTimeData(String groupName, DateTime date, String positionName, DateTime time) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawQuery(
          '''
      INSERT INTO time_data(groups_id, date, position, time)
      SELECT   groups_id,
              "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}",
              ?,
              "2000-01-01 ${time.hour}:${time.minute}"
      FROM groups
      WHERE groups.name = ?
      ''',
      [positionName, groupName]);
    });

    return true;
  }

  static Future<bool> changePriceData(int entryId, DateTime date, String positionName, double price) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawUpdate(
        '''
        UPDATE price_data 
        SET date = "${date.year}-${convertTo2digit(date.month)}-${convertTo2digit(date.day)} ${convertTo2digit(date.hour)}:${convertTo2digit(date.minute)}:${convertTo2digit(date.second)}",
            position = ?,
            price = ?
        WHERE price_data_id = ?
        ''',
        [positionName, price, entryId]
      );
    });

    return true;
  }

  static Future<bool> changeTimeData(int entryId, DateTime date, String positionName, DateTime time) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawUpdate(
          '''
        UPDATE time_data 
        SET date = "${date.year}-${convertTo2digit(date.month)}-${convertTo2digit(date.day)} ${convertTo2digit(date.hour)}:${convertTo2digit(date.minute)}",
            position = ?,
            time = "${time.year}-${convertTo2digit(time.month)}-${convertTo2digit(time.day)} ${convertTo2digit(time.hour)}:${convertTo2digit(time.minute)}"
        WHERE time_data_id = ?
        ''',
          [positionName, entryId]
      );
    });

    return true;
  }

  static void deleteGroup(String groupName) async {
    var _db = await db;
    await _db.transaction((txn) async {
      await txn.rawQuery(
        '''
        DELETE FROM groups
        WHERE groups.name = ?
        ''',
        [groupName]
      );
    });
  }
}
