import 'package:a_counter/main.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

import 'database_provider.dart';

@immutable
class Group {
  const Group(this.groupName, this.groupType);

  Future getGroupData() async {
    if (groupType == TypesOfGroup.priceData) {
      var queryResult = await DatabaseProvider.getPriceDataForGroup(groupName);

      List<AccountingData> dataList = [];
      for (var entry in queryResult) {
        String dateStr = entry["date"].toString().substring(0, 10);
        List<String> dateEls = dateStr.split("-");
        dataList.add(PriceData(entry["price_data_id"],
            DateTime(int.parse(dateEls[0]), int.parse(dateEls[1]), int.parse(dateEls[2])),
            entry["position"],
            double.parse(entry["price"].toString())));
      }
      return dataList;
    }

    else if (groupType == TypesOfGroup.timeData) {
      var queryResult = await DatabaseProvider.getTimeDataForGroup(groupName);
      List<AccountingData> accList = [];
      for (var entry in queryResult) {
        String dateStr = entry["date"].toString().substring(0, 10);
        List<String> dateEls = dateStr.split("-");

        String timeStr = entry["time"].toString().substring(11);
        List<String> timeEls = timeStr.split(":");

        accList.add(TimeData(
            entry["time_data_id"],
            DateTime(int.parse(dateEls[0]), int.parse(dateEls[1]), int.parse(dateEls[2]))
            , entry["position"],
            DateTime(2000, 1, 1, int.parse(timeEls[0]), int.parse(timeEls[1])))
        );
      }

      return accList;
    }

    return [];
  }

  Future getGroupStatistics() async {
    return await DatabaseProvider.getPriceDataStatistics(groupName);
  }

  final String groupName;
  final TypesOfGroup groupType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Group && other.groupName == groupName && other.groupType == groupType;
  }

  @override
  int get hashCode => groupName.hashCode ^ groupType.hashCode;
}

class GroupStatistics {
  GroupStatistics(
      this.overallAccountingData,
      this.maxActivityData,
      this.minActivityData,
      this.averageActivityData
  );

  OverallAccountingData overallAccountingData;
  MaxAccountingActivityData maxActivityData;
  MinAccountingActivityData minActivityData;
  AverageAccountingActivityData averageActivityData;
}

class SimpleDateTimeFactory {
  static DateTime createTime(int hours, int minutes) {
    return DateTime(0, 01, 01, hours, minutes);
  }

  static DateTime createCurrent() {
    return DateTime.now();
  }

  static DateTime createStart() {
    return DateTime(2000, 01, 01);
  }

  static DateTime createEnd() {
    return createCurrent();
  }
}

Duration getTimeFor(DateTime time) {
  return time.difference(DateTime(0, 01, 01));
}

String getTimeStrFor(DateTime time) {
  Duration diff = getTimeFor(time);

  return "${diff.inMinutes ~/ 60} ч, ${diff.inMinutes % 60} м";
}

abstract class OverallAccountingData {
  String getOverallValue();
  String getAverageValue();
}

class OverallPriceData implements OverallAccountingData {
  double overallPrice = 0;
  double averagePrice = 0;

  OverallPriceData(this.overallPrice, this.averagePrice);

  @override
  String getOverallValue() {
    return overallPrice.toStringAsFixed(2);
  }

  @override
  String getAverageValue() {
    return averagePrice.toStringAsFixed(2);
  }
}

class OverallTimeData implements OverallAccountingData {
  DateTime overallTime;
  DateTime averageTime;

  OverallTimeData(this.overallTime, this.averageTime);

  @override
  String getOverallValue() {
    return getTimeStrFor(overallTime);
  }

  @override
  String getAverageValue() {
    return getTimeStrFor(averageTime);
  }
}

abstract class MaxAccountingActivityData {
  List<String> getMaxValuePositions();
  String getMaxValue();
  List<Map<String, String>> getMaxValuesPerPosition();
}

class MaxPriceActivityData implements MaxAccountingActivityData {
  List<String> maxPricePositions;
  double maxPrice;
  List<Map<String, double>> maxPricePerPosition = [];

  MaxPriceActivityData(this.maxPricePositions, this.maxPrice, this.maxPricePerPosition);

  @override
  List<String> getMaxValuePositions() {
    return maxPricePositions;
  }

  @override
  String getMaxValue() {
    return maxPrice.toStringAsFixed(2);
  }

  @override
  List<Map<String, String>> getMaxValuesPerPosition() {
    List<Map<String, String>> perPosition = [];

    maxPricePerPosition.forEach((element) {
      String positionName = element.keys.toList()[0];
      perPosition.add({positionName: element[positionName]!.toStringAsFixed(2)});
    });

    return perPosition;
  }
}

class MaxTimeActivityData implements MaxAccountingActivityData {
  List<String> maxTimePositions;
  DateTime maxTime;
  List<Map<String, DateTime>> maxValuesPerPosition = [];

  MaxTimeActivityData(this.maxTimePositions, this.maxTime, this.maxValuesPerPosition);

  @override
  List<String> getMaxValuePositions() {
    return maxTimePositions;
  }

  @override
  String getMaxValue() {
    return getTimeStrFor(maxTime);
  }

  @override
  List<Map<String, String>> getMaxValuesPerPosition() {
    List<Map<String, String>> perPosition = [];

    maxValuesPerPosition.forEach((element) {
      String position = element.keys.toList()[0];
      DateTime averageTime = element[position]!;
      perPosition.add({position: getTimeStrFor(averageTime)});
    });

    return perPosition;
  }
}

abstract class MinAccountingActivityData {
  List<String> getMinValuePositions();
  String getMinValue();
  List<Map<String, String>> getMinValuePerPosition();
}

class MinPriceActivityData implements MinAccountingActivityData {
  List<String> minPricePositions = [];
  double minPrice = 0.0;
  List<Map<String, double>> minPricePerPosition = [];

  MinPriceActivityData(this.minPricePositions, this.minPrice, this.minPricePerPosition);

  @override
  List<String> getMinValuePositions() {
   return minPricePositions;
  }

  @override
  String getMinValue() {
    return minPrice.toStringAsFixed(2);
  }

  @override
  List<Map<String, String>> getMinValuePerPosition() {
    List<Map<String, String>> perPosition = [];

    minPricePerPosition.forEach((element) {
      String position = element.keys.toList()[0];
      perPosition.add({position: element[position]!.toStringAsFixed(2)});
    });

    return perPosition;
  }
}

class MinTimeActivityData implements MinAccountingActivityData {
  List<String> minTimePositions = [];
  DateTime minTime;
  List<Map<String, DateTime>> minTimePerPosition = [];

  MinTimeActivityData(this.minTimePositions, this.minTime, this.minTimePerPosition);

  @override
  List<String> getMinValuePositions() {
    return minTimePositions;
  }

  @override
  String getMinValue() {
    return getTimeStrFor(minTime);
  }

  @override
  List<Map<String, String>> getMinValuePerPosition() {
    List<Map<String, String>> perPosition = [];

    minTimePerPosition.forEach((element) {
      String position = element.keys.toList()[0];
      DateTime minTimePerPosition = element[position]!;
      perPosition.add({position: getTimeStrFor(minTimePerPosition)});
    });

    return perPosition;
  }
}

abstract class AverageAccountingActivityData {
  List<String> getFrequentPositions();
  int getCountOfFrequentPositionBuys();
  List<Map<String, String>> getAverageValuePerPosition();
}

class AveragePriceActivityData implements AverageAccountingActivityData{
  List<String> mostFrequentPositions;
  int countOfBuysForFrequentPosition;
  List<Map<String, double>> averagePricePerPosition = [];

  AveragePriceActivityData(this.mostFrequentPositions, this.countOfBuysForFrequentPosition, this.averagePricePerPosition);
  
  @override
  List<String> getFrequentPositions() {
    return mostFrequentPositions;
  }
  
  @override
  int getCountOfFrequentPositionBuys() {
    return countOfBuysForFrequentPosition;
  }
  
  @override
  List<Map<String, String>> getAverageValuePerPosition() {
    List<Map<String, String>> perPosition = [];

    averagePricePerPosition.forEach((element) {
      String position = element.keys.toList()[0];
      double averagePrice = element[position]!;
      perPosition.add({position: averagePrice.toStringAsFixed(2)});
    });

    return perPosition;
  }
}

class AverageTimeActivityData implements AverageAccountingActivityData{
  List<Map<String, DateTime>> averageTimePerPosition = [];

  AverageTimeActivityData(this.averageTimePerPosition);

  @override
  List<String> getFrequentPositions() {
    return [];
  }

  @override
  int getCountOfFrequentPositionBuys() {
    return 0;
  }

  @override
  List<Map<String, String>> getAverageValuePerPosition() {
    List<Map<String, String>> perPosition = [];

    averageTimePerPosition.forEach((element) {
      String position = element.keys.toList()[0];
      DateTime averageTime = element[position]!;
      perPosition.add({position: getTimeStrFor(averageTime)});
    });

    return perPosition;
  }
}

class AppStatus {
  AppStatus(this.isOk, this.message);
  AppStatus.ok() : this.isOk = true, this.message = "Ok!";
  AppStatus.err(this.message) : this.isOk = false;

  bool isOk;
  String message;
}

double ngram(String fst, String snd, {int gram_size = 2}) {
  if (fst.length < gram_size || snd.length < gram_size) {
    if (fst.length != 0 && snd.length != 0) {
      return ngram(fst, snd, gram_size: min(fst.length, snd.length));
    }

    return 0;
  }

  List<String> fst_gramms = [];
  for (int i = 0; i < fst.length - gram_size + 1; i ++) {
    fst_gramms.add(fst.substring(i, i + gram_size).toLowerCase());
  }
  List<String> snd_gramms = [];
  for (int i = 0; i < snd.length - gram_size + 1; i ++) {
    snd_gramms.add(snd.substring(i, i + gram_size).toLowerCase());
  }

  int interception_count = 0;
  for (String fst_gram in fst_gramms) {
    for (String snd_gram in snd_gramms) {
      if (fst_gram == snd_gram) {
        interception_count ++;
      }
    }
  }

  double ratio = fst_gramms.length / snd_gramms.length;

  if (ratio < 1) {
    ratio = 1 / ratio;
  }

  return ratio * interception_count / (fst_gramms.length + snd_gramms.length);
}