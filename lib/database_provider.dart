import 'package:a_counter/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum TypesOfGroup { priceData, timeData, unknown }

class Type {
  static const List<TypesOfGroup> groupTypes = [
    TypesOfGroup.priceData,
    TypesOfGroup.timeData
  ];

  static TypesOfGroup fromStringToEnum(String typeName) {
    switch (typeName) {
      case "Позиция - Стоимость":
        return TypesOfGroup.priceData;

      case "Позиция - Время":
        return TypesOfGroup.timeData;

      default:
        return TypesOfGroup.unknown;
    }
  }

  static String fromEnumToString(TypesOfGroup typeName) {
    switch (typeName) {
      case TypesOfGroup.priceData:
        return "Позиция - Стоимость";

      case TypesOfGroup.timeData:
        return "Позиция - Время";

      default:
        return "Неизвестно";
    }
  }

  static int fromEnumToId(TypesOfGroup typeName) {
    switch (typeName) {
      case TypesOfGroup.priceData:
        return 1;

      case TypesOfGroup.timeData:
        return 2;

      default:
        return -1;
    }
  }

  static int fromStringToId(String typeName) {
    switch (typeName) {
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
  if (dayOrMonth < 10) return "0$dayOrMonth";

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
  String toString() {
    return time.toString();
  }

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
      return await txn.rawQuery("""
          SELECT groups.name, type_name
          FROM
            groups
            INNER JOIN type USING(type_id)
          """);
    });

    List<Group> groups = [];
    for (var entry in result) {
      groups.add(Group(entry["name"].toString(),
          Type.fromStringToEnum(entry["type_name"].toString())));
    }

    return groups;
  }

  static Future getPriceDataForGroup(String groupName) async {
    var _db = await db;

    return _db.transaction((txn) async {
      return (await txn.rawQuery('''
          SELECT price_data_id, date, position, price
          FROM
            groups
            INNER JOIN price_data USING(groups_id)
          WHERE groups.name = ?
          ORDER BY date DESC
          ''', [groupName]));
    });
  }

  static Future getTimeDataForGroup(String groupName) async {
    var _db = await db;

    return _db.transaction((txn) async {
      return (await txn.rawQuery('''
            SELECT time_data_id, date, position, time
            FROM
              groups
              INNER JOIN time_data USING(groups_id)
            WHERE groups.name = ?
            ORDER BY date DESC
            ''', [groupName]));
    });
  }

  static Future<bool> deletePriceDataById(int id) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawDelete('''
          DELETE FROM price_data
          WHERE price_data.price_data_id = ?
        ''', [id]);
    });

    return true;
  }

  static Future<bool> deleteTimeDataById(int id) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawDelete('''
          DELETE FROM time_data
          WHERE time_data.time_data_id = ?
        ''', [id]);
    });

    return true;
  }

  static void addGroup(String groupName, TypesOfGroup groupType) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawInsert("""
        INSERT INTO groups(name, type_id)
        VALUES (?, ?)
        """, [groupName, Type.fromEnumToId(groupType)]);
    });
  }

  static Future<bool> addPriceData(String groupName, DateTime date,
      String positionName, double price) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawQuery("""
      INSERT INTO price_data(groups_id, date, position, price)
      SELECT groups_id, ?, ?, ?
      FROM groups
      WHERE groups.name = ?
      """, [date.toString(), positionName, price, groupName]);
    });

    return true;
  }

  static Future<bool> addTimeData(String groupName, DateTime date,
      String positionName, DateTime time) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawQuery('''
      INSERT INTO time_data(groups_id, date, position, time)
      SELECT   groups_id, 
              ?,
              ?,
              ?
      FROM groups
      WHERE groups.name = ?
      ''', [date.toString(), positionName, time.toString(), groupName]);
    });

    return true;
  }

  static Future<bool> changePriceData(
      int entryId, DateTime date, String positionName, double price) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawUpdate('''
        UPDATE price_data 
        SET date = ?,
            position = ?,
            price = ?
        WHERE price_data_id = ?
        ''', [date.toString(), positionName, price, entryId]);
    });

    return true;
  }

  static Future<bool> changeTimeData(
      int entryId, DateTime date, String positionName, DateTime time) async {
    var _db = await db;

    await _db.transaction((txn) async {
      await txn.rawUpdate('''
        UPDATE time_data 
        SET date = ?,
            position = ?,
            time = ?
            WHERE time_data_id = ?
        ''', [date.toString(), positionName,  time.toString(), entryId]);
    });

    return true;
  }

  static Future getPriceDataStatistics(String groupName) async {
    var _db = await db;

    return await _db.transaction((txn) async {
      var queryResult = await txn.rawQuery('''
        SELECT SUM(price) as overallPrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        ''', [groupName]);

      double overallPrice = 0.0;
      if (queryResult.isNotEmpty) {
        overallPrice = double.parse(queryResult[0]["overallPrice"].toString());
      }

      queryResult = await txn.rawQuery('''
        SELECT AVG(overallPrice) as averagePrice
        FROM (
          SELECT SUM(price) as overallPrice
          FROM price_data
            INNER JOIN groups USING(groups_id)
          WHERE groups.name = ?
          GROUP BY position
        ) t1
        ''', [groupName]);

      double averagePrice = 0.0;
      if (queryResult.isNotEmpty) {
        averagePrice = double.parse(queryResult[0]["averagePrice"].toString());
      }

      OverallPriceData overallPriceData =
          OverallPriceData(overallPrice, averagePrice);

      // max data ============================================================
      queryResult = await txn.rawQuery('''
        SELECT position, SUM(price) as maxPrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY groups_id, position
        HAVING SUM(price) = (
          SELECT MAX(overallPrice)
          FROM (
            SELECT SUM(price) as overallPrice
            FROM price_data
              INNER JOIN groups USING(groups_id)
            WHERE groups.name = ?
            GROUP BY groups_id, position
          )
        )
        ''', [groupName, groupName]);


      List<String> maxPricePositions = [];
      double maxPrice = 0.0;
      if (queryResult.isNotEmpty) {
        maxPrice = double.parse(queryResult[0]["maxPrice"].toString());

        for (var entry in queryResult) {
          maxPricePositions.add(entry["position"].toString());
        }
      }

      queryResult = await txn.rawQuery('''
        SELECT position, MAX(price) as maxPrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        ''', [groupName]);


      List<Map<String, double>> maxPricePerPosition = [];
      for (var entry in queryResult) {
        maxPricePerPosition.add({
          entry["position"].toString():
              double.parse(entry["maxPrice"].toString())
        });
      }

      MaxAccountingActivityData maxAccountingActivityData =
          MaxPriceActivityData(
              maxPricePositions, maxPrice, maxPricePerPosition);

      // min data ==============================================================

      queryResult = await txn.rawQuery('''
        SELECT position, SUM(price) as minPrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY groups_id, position
        HAVING SUM(price) = (
          SELECT MIN(overallPrice)
          FROM (
          SELECT SUM(price) as overallPrice
          FROM price_data
            INNER JOIN groups USING(groups_id)
          WHERE groups.name = ?
          GROUP BY groups_id, position
          )
        )
        ''', [groupName, groupName]);

      List<String> minPricePositions = [];
      double minPrice = 0.0;
      if (queryResult.isNotEmpty) {
        minPrice = double.parse(queryResult[0]["minPrice"].toString());

        for (var entry in queryResult) {
          minPricePositions.add(entry["position"].toString());
        }
      }

      queryResult = await txn.rawQuery('''
        SELECT position, MIN(price) as minPrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        ''', [groupName]);

      List<Map<String, double>> minPricePerPosition = [];
      if (queryResult.isNotEmpty) {
        for (var entry in queryResult) {
          minPricePerPosition.add({
            entry["position"].toString():
                double.parse(entry["minPrice"].toString())
          });
        }
      }

      MinPriceActivityData minPriceActivityData = MinPriceActivityData(
          minPricePositions, minPrice, minPricePerPosition);

      queryResult = await txn.rawQuery('''
        SELECT position, COUNT(position) as positionCount
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        HAVING COUNT(position) = (
          SELECT MAX(positionCount)
          FROM (
            SELECT COUNT(position) as positionCount
            FROM price_data
              INNER JOIN groups USING(groups_id)
            WHERE groups.name = ?
            GROUP BY position
          )
        )
        ''', [groupName, groupName]);

      List<String> frequentPositions = [];
      int countOfFrequent = 0;

      if (queryResult.isNotEmpty) {
        countOfFrequent = int.parse(queryResult[0]["positionCount"].toString());

        for (var entry in queryResult) {
          frequentPositions.add(entry["position"].toString());
        }
      }

      queryResult = await txn.rawQuery('''
        SELECT position, AVG(price) as averagePrice
        FROM price_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        ''', [groupName]);



      List<Map<String, double>> averagePricePerPosition = [];
      if (queryResult.isNotEmpty) {
        for (var entry in queryResult) {
          String position = entry["position"].toString();
          averagePricePerPosition
              .add({position: double.parse(entry["averagePrice"].toString())});
        }
      }

      AverageAccountingActivityData averageAccountingActivityData =
          AveragePriceActivityData(
              frequentPositions, countOfFrequent, averagePricePerPosition);

      return GroupStatistics(overallPriceData, maxAccountingActivityData, minPriceActivityData, averageAccountingActivityData);
    });
  }

  static Future getTimeDataStatistics(String groupName) async {
    var _db = await db;

    return await _db.transaction((txn) async {
      var queryResult = await txn.rawQuery(
        '''
        SELECT SUM(strftime("%H", time)) + SUM(strftime("%M", time)) / 60 as overallHours, SUM(strftime("%M", time)) % 60 as overallMinutes
        FROM time_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        ''',
        [groupName]
      );

      DateTime overallTime = SimpleDateTimeFactory.createTime(0, 0);
      int hours = 0;
      int minutes = 0;
      if (queryResult.isNotEmpty) {
        hours = int.parse(queryResult[0]["overallHours"].toString());
        minutes = int.parse(queryResult[0]["overallMinutes"].toString());

        overallTime = SimpleDateTimeFactory.createTime(hours, minutes);
      }


      queryResult = await txn.rawQuery(
          '''
         SELECT ROUND(averageMinutes / 60, 0) as averageHours, averageMinutes % 60 as averageMinutes
         FROM (
          SELECT AVG(overallHours * 60 + overallMinutes) as averageMinutes
          FROM (
            SELECT SUM(strftime("%H", time)) + SUM(strftime("%M", time)) / 60 as overallHours, SUM(strftime("%M", time)) % 60 as overallMinutes
            FROM time_data
              INNER JOIN groups USING(groups_id)
            WHERE groups.name = ?
            GROUP BY position
            ) t1
         ) t1
        ''',
          [groupName]
      );
      DateTime averageTime = SimpleDateTimeFactory.createTime(0, 0);
      hours = 0;
      minutes = 0;
      if (queryResult.isNotEmpty) {
        hours = double.parse(queryResult[0]["averageHours"].toString()).toInt();
        minutes = double.parse(queryResult[0]["averageMinutes"].toString()).toInt();

        averageTime = SimpleDateTimeFactory.createTime(hours, minutes);
      }

      OverallTimeData overallTimeData = OverallTimeData(overallTime, averageTime);
      queryResult = await txn.rawQuery(
      '''
        SELECT position, SUM(strftime("%H", time)) + SUM(strftime("%M", time)) / 60 as hours, SUM(strftime("%M", time)) % 60 as minutes
        FROM time_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        HAVING SUM(strftime("%H", time)) * 60 + SUM(strftime("%M", time)) = (
            SELECT MAX(minutes)
            FROM (
                SELECT SUM(strftime("%H", time)) * 60 + SUM(strftime("%M", time)) as minutes
                FROM time_data
                  INNER JOIN groups USING(groups_id)
                  WHERE groups.name = ?
                GROUP BY position
            ) t1
        )
      ''',
      [groupName, groupName]
      );

      List<String> maxTimePositions = [];
      DateTime maxTime = SimpleDateTimeFactory.createTime(0, 0);
      hours = 0;
      minutes = 0;
      if (queryResult.isNotEmpty) {
        hours = double.parse(queryResult[0]["hours"].toString()).toInt();
        minutes = double.parse(queryResult[0]["minutes"].toString()).toInt();
        maxTime = SimpleDateTimeFactory.createTime(hours, minutes);

        for (var entry in queryResult) {
          maxTimePositions.add(entry["position"].toString());
        }
      }

      queryResult = await txn.rawQuery(
          '''
        SELECT position, minutes / 60 as hours, minutes % 60 as minutes
        FROM (
          SELECT position, MAX(strftime("%H", time) * 60 + (strftime("%M", time))) as minutes
          FROM time_data
            INNER JOIN groups USING(groups_id)
          WHERE groups.name = ?
          GROUP BY position
        ) t1
      ''',
      [groupName]
      );


      List<Map<String, DateTime>> maxTimePerPosition = [];
      for (var entry in queryResult) {
        maxTimePerPosition.add(
          {
            entry["position"].toString():
              SimpleDateTimeFactory.createTime(
                  int.parse(entry["hours"].toString()),
                  int.parse(entry["minutes"].toString())
              )
          }
        );
      }

      MaxTimeActivityData maxTimeActivityData = MaxTimeActivityData(maxTimePositions, maxTime, maxTimePerPosition);

      queryResult = await txn.rawQuery(
          '''
        SELECT position, SUM(strftime("%H", time)) + SUM(strftime("%M", time)) / 60 as hours, SUM(strftime("%M", time)) % 60 as minutes
        FROM time_data
          INNER JOIN groups USING(groups_id)
        WHERE groups.name = ?
        GROUP BY position
        HAVING SUM(strftime("%H", time)) * 60 + SUM(strftime("%M", time)) = (
            SELECT MIN(minutes)
            FROM (
                SELECT SUM(strftime("%H", time)) * 60 + SUM(strftime("%M", time)) as minutes
                FROM time_data
                  INNER JOIN groups USING(groups_id)
                  WHERE groups.name = ?
                GROUP BY position
            ) t1
        )
      ''',
          [groupName, groupName]
      );

      List<String> minTimePositions = [];
      DateTime minTime = SimpleDateTimeFactory.createTime(0, 0);
      hours = 0;
      minutes = 0;
      if (queryResult.isNotEmpty) {
        hours = int.parse(queryResult[0]["hours"].toString());
        minutes = int.parse(queryResult[0]["minutes"].toString());
        minTime = SimpleDateTimeFactory.createTime(hours, minutes);

        for (var entry in queryResult) {
          minTimePositions.add(entry["position"].toString());
        }
      }

      queryResult = await txn.rawQuery(
          '''
        SELECT position, minutes / 60 as hours, minutes % 60 as minutes
        FROM (
          SELECT position, MIN(strftime("%H", time) * 60 + (strftime("%M", time))) as minutes
          FROM time_data
            INNER JOIN groups USING(groups_id)
          WHERE groups.name = ?
          GROUP BY position
        ) t1
      ''',
          [groupName]
      );

      List<Map<String, DateTime>> minTimePerPosition = [];
      for (var entry in queryResult) {
        minTimePerPosition.add(
            {
              entry["position"].toString():
              SimpleDateTimeFactory.createTime(
                  int.parse(entry["hours"].toString()),
                  int.parse(entry["minutes"].toString())
              )
            }
        );
      }

      MinTimeActivityData minTimeActivityData = MinTimeActivityData(minTimePositions, minTime, minTimePerPosition);

      queryResult = await txn.rawQuery(
          '''
        SELECT position, minutes / 60 as hours, minutes % 60 as minutes
        FROM (
          SELECT position, AVG(strftime("%H", time) * 60 + (strftime("%M", time))) as minutes
          FROM time_data
            INNER JOIN groups USING(groups_id)
          WHERE groups.name = ?
          GROUP BY position
        ) t1
      ''',
          [groupName]
      );

      List<Map<String, DateTime>> averageTimePerPosition = [];

      for (var entry in queryResult) {
        averageTimePerPosition.add(
          {
            entry["position"].toString() :
                SimpleDateTimeFactory.createTime(
                  double.parse(entry["hours"].toString()).toInt(),
                  double.parse(entry["minutes"].toString()).toInt()
                )
          }
        );
      }

      AverageTimeActivityData averageTimeActivityData = AverageTimeActivityData(averageTimePerPosition);
      return GroupStatistics(overallTimeData, maxTimeActivityData, minTimeActivityData, averageTimeActivityData);
    });
  }

  static void deleteGroup(String groupName) async {
    var _db = await db;
    await _db.transaction((txn) async {
      await txn.rawQuery('''
        DELETE FROM groups
        WHERE groups.name = ?
        ''', [groupName]);
    });
  }
}
