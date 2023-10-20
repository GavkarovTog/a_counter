import 'package:a_counter/main.dart';
import 'package:flutter/cupertino.dart';

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

        // print(dateEls);
        // print(entry["time"]);
        // print(timeEls);
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

class AppStatus {
  AppStatus(this.isOk, this.message);
  AppStatus.ok() : this.isOk = true, this.message = "Ok!";
  AppStatus.err(this.message) : this.isOk = false;

  bool isOk;
  String message;
}

double ngram(String fst, String snd) {
  const gram_size = 1;
  if (fst.length < gram_size) {
    return 0;
  }

  else if (snd.length < gram_size) {
    return 0;
  }

  List<String> fst_gramms = [];
  for (int i = 0; i < fst.length ~/ gram_size; i ++) {
    fst_gramms.add(fst.substring(i * gram_size, i * gram_size + gram_size).toLowerCase());
  }

  List<String> snd_gramms = [];
  for (int i = 0; i < snd.length ~/ gram_size; i ++) {
    snd_gramms.add(snd.substring(i * gram_size, i * gram_size + gram_size).toLowerCase());
  }

  int interception_count = 0;
  for (String fst_gram in fst_gramms) {
    for (String snd_gram in snd_gramms) {
      if (fst_gram == snd_gram) {
        interception_count ++;
      }
    }
  }

  return interception_count / (fst_gramms.length + snd_gramms.length);
}