import 'package:a_counter/utils.dart';
import 'package:flutter/material.dart';
import 'package:a_counter/database_provider.dart';
import 'package:path/path.dart';

bool dateIsEqual(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class DataObserverPage extends StatefulWidget {
  DataObserverPage(this.groupInfo, {super.key});

  Group groupInfo;

  @override
  State<DataObserverPage> createState() => _DataObserverPageState();
}

class _DataObserverPageState extends State<DataObserverPage> {
  TextEditingController searchText = TextEditingController();

  Widget getGroupsBadge() {
    return Container(
      decoration: BoxDecoration(color: Colors.teal.shade200, boxShadow: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(0, 1),
          spreadRadius: 1,
          blurRadius: 2,
        )
      ]),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text("Группа '${widget.groupInfo.groupName}'",
          style: TextStyle(fontFamily: 'Times New Roman', fontSize: 22)),
    );
  }

  Widget getDateBadge(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString();
    String day = date.day < 10 ? "0${date.day}" : date.day.toString();

    return Container(
      alignment: Alignment.center,
      color: Colors.teal.shade100,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "$day.$month.$year",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  String transformPrice(String priceText) {
    bool hasMinus = false;
    bool hasPeriod = false;
    bool alreadyHasNumber = false;
    bool hasLeadingZero = false;

    String result = "";

    for (int i = 0; i < priceText.length; i++) {
      String symbol = priceText[i];

      if ((symbol == "," || symbol == " ") ||
          (!alreadyHasNumber && symbol == ".") ||
          (hasPeriod && symbol == ".") ||
          (hasMinus && symbol == "-") ||
          (alreadyHasNumber && symbol == "-") ||
          (alreadyHasNumber && hasLeadingZero && symbol == "0")) {
        continue;
      }

      if (symbol == "0" && !alreadyHasNumber) {
        hasLeadingZero = true;
        alreadyHasNumber = true;
      } else if (symbol == "-") {
        hasMinus = true;
      } else if (symbol == ".") {
        hasPeriod = true;
      } else if ("123456789".contains(symbol) && !alreadyHasNumber) {
        alreadyHasNumber = true;
      } else if ("123456789".contains(symbol) &&
          alreadyHasNumber &&
          hasLeadingZero &&
          !hasPeriod) {
        result = result.substring(0, result.length - 1);
      }

      result += symbol;
    }

    return result;
  }

  String transformTime(String priceText) {
    bool hasColon = false;
    bool hasNumber = false;
    bool hasLeadingZero = false;

    String result = "";

    for (var letter in priceText.characters) {
      if ((!"0123456789:".contains(letter)) ||
          (!hasNumber && letter == ":") ||
          (hasColon && letter == ":") ||
          (hasLeadingZero && letter == "0" && !hasColon) ||
          (result.contains(":") &&
              result.substring(result.indexOf(":")).length - 1 >= 2) ||
          (result.contains(":") &&
              result.substring(result.indexOf(":")).length - 1 == 0 &&
              !"012345".contains(letter))) {
        continue;
      }

      if (!hasLeadingZero && !hasNumber && letter == "0") {
        hasLeadingZero = true;
        hasNumber = true;
      } else if (letter == ":") {
        hasColon = true;
      } else if (hasLeadingZero && !hasColon && "123456789".contains(letter)) {
        result = result.substring(0, result.length - 1);
        hasLeadingZero = false;
      } else if ("0123456789".contains(letter)) {
        hasNumber = true;
      }

      result += letter;
    }

    return result;
  }

  Widget getDataCreateDialog(BuildContext context, Group groupInfo) {
    TextEditingController name = TextEditingController();
    TextEditingController priceOrDate = TextEditingController();
    TextInputType inputType = groupInfo.groupType == TypesOfGroup.priceData
        ? TextInputType.number
        : TextInputType.datetime;

    String hintForData =
        groupInfo.groupType == TypesOfGroup.priceData ? "Цена" : "Время";

    GlobalKey<FormState> key = GlobalKey<FormState>();

    return Form(
      key: key,
      child: SimpleDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
        title: Text("Внести учетные данные"),
        children: [
          Container(
              // margin:
              //     EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
            validator: (text) {
              if (text == "") {
                return "Поле должно быть заполнено";
              }
            },
            textAlign: TextAlign.center,
            controller: name,
            decoration: InputDecoration(hintText: "Наименование"),
          )),
          Container(
              // margin:
              //     EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
            validator: (text) {
              if (text == "") {
                return "Поле должно быть заполнено";
              } else if (groupInfo.groupType == TypesOfGroup.timeData &&
                  !RegExp(r"^-?\d+:\d\d").hasMatch(text!)) {
                return "Нарушен формат 'hours:minutes'";
              } else if (groupInfo.groupType == TypesOfGroup.priceData &&
                  !RegExp(r"^-?\d+(\.\d+)?$").hasMatch(text!)) {
                return "Нарушен формат 'digits.digits или number'";
              }
            },
            textAlign: TextAlign.center,
            keyboardType: inputType,
            controller: priceOrDate,
            onChanged: (text) {
              String result = "";
              if (groupInfo.groupType == TypesOfGroup.priceData) {
                result = transformPrice(text);
              } else if (groupInfo.groupType == TypesOfGroup.timeData) {
                result = transformTime(text);
              } else {
                result = text;
              }

              priceOrDate.text = result;
              priceOrDate.selection = TextSelection(
                  baseOffset: result.length, extentOffset: result.length);
            },
            decoration: InputDecoration(hintText: hintForData),
          )),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Ink(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      color: Colors.redAccent,
                      child: Icon(Icons.close)),
                  splashColor: Colors.white24,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Ink(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      color: Colors.tealAccent,
                      child: Icon(Icons.check)),
                  splashColor: Colors.white24,
                  onTap: () async {
                    if (key.currentState!.validate()) {
                      if (groupInfo.groupType == TypesOfGroup.priceData) {
                        await DatabaseProvider.addPriceData(
                            groupInfo.groupName,
                            SimpleDateTimeFactory.createCurrent(),
                            name.text,
                            double.parse(priceOrDate.text));
                      } else if (groupInfo.groupType == TypesOfGroup.timeData) {
                        List<String> toTime = priceOrDate.text.split(":");
                        DateTime time = SimpleDateTimeFactory.createTime(
                            int.parse(toTime[0]), int.parse(toTime[1]));

                        await DatabaseProvider.addTimeData(
                            groupInfo.groupName,
                            SimpleDateTimeFactory.createCurrent(),
                            name.text,
                            time);
                      }

                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getDataChangeDialog(
      BuildContext context, Group groupInfo, AccountingData dataEntry) {
    TextEditingController name =
        TextEditingController(text: dataEntry.positionName);
    TextEditingController priceOrDate =
        TextEditingController(text: dataEntry.getData());
    ValueNotifier<DateTime> dateForEntry = ValueNotifier(dataEntry.date);

    TextInputType inputType = groupInfo.groupType == TypesOfGroup.priceData
        ? TextInputType.number
        : TextInputType.datetime;

    String hintForData =
        groupInfo.groupType == TypesOfGroup.priceData ? "Цена" : "Время";

    GlobalKey<FormState> key = GlobalKey<FormState>();

    return ValueListenableBuilder(
      valueListenable: dateForEntry,
      builder: (context, dateValue, _) => Form(
        key: key,
        child: SimpleDialog(
          clipBehavior: Clip.hardEdge,
          contentPadding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
          title: Text("Изменить учетные данные"),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 10,
                ),
                Text("Дата:", style: TextStyle(fontSize: 16)),
                TextButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: dataEntry.date,
                        firstDate: SimpleDateTimeFactory.createStart(),
                        lastDate: SimpleDateTimeFactory.createEnd(),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          dateForEntry.value = selectedDate;
                        }
                      });
                    },
                    child: Text(
                        "${dateValue.day}.${dateValue.month}.${dateValue.year}",
                        style: TextStyle(fontSize: 16))),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            Container(
                // margin:
                //     EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
              validator: (text) {
                if (text == "") {
                  return "Поле должно быть заполнено";
                }
              },
              textAlign: TextAlign.center,
              controller: name,
              decoration: InputDecoration(hintText: "Наименование"),
            )),
            Container(
                // margin:
                //     EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
              validator: (text) {
                if (text == "") {
                  return "Поле должно быть заполнено";
                } else if (groupInfo.groupType == TypesOfGroup.timeData &&
                    !RegExp(r"^\d+:\d\d").hasMatch(text!)) {
                  return "Нарушен формат 'hours:minutes'";
                } else if (groupInfo.groupType == TypesOfGroup.priceData &&
                    !RegExp(r"^\d+(\.\d+)?$").hasMatch(text!)) {
                  return "Нарушен формат 'digits.digits или number'";
                }
              },
              textAlign: TextAlign.center,
              keyboardType: inputType,
              controller: priceOrDate,
              onChanged: (text) {
                String result = "";
                if (groupInfo.groupType == TypesOfGroup.priceData) {
                  result = transformPrice(text);
                } else if (groupInfo.groupType == TypesOfGroup.timeData) {
                  result = transformTime(text);
                } else {
                  result = text;
                }

                priceOrDate.text = result;
                priceOrDate.selection = TextSelection(
                    baseOffset: result.length, extentOffset: result.length);
              },
              decoration: InputDecoration(hintText: hintForData),
            )),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Ink(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        color: Colors.redAccent,
                        child: Icon(Icons.close)),
                    splashColor: Colors.white24,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Ink(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        color: Colors.tealAccent,
                        child: Icon(Icons.check)),
                    splashColor: Colors.white24,
                    onTap: () async {
                      if (key.currentState!.validate()) {
                        if (groupInfo.groupType == TypesOfGroup.priceData) {
                          await DatabaseProvider.changePriceData(
                              dataEntry.id,
                              dateForEntry.value,
                              name.text,
                              double.parse(priceOrDate.text));
                        } else if (groupInfo.groupType ==
                            TypesOfGroup.timeData) {
                          List<String> toTime = priceOrDate.text.split(":");

                          DateTime time = SimpleDateTimeFactory.createTime(
                              int.parse(toTime[0]), int.parse(toTime[1]));

                          await DatabaseProvider.changeTimeData(dataEntry.id,
                              dateForEntry.value, name.text, time);
                        }

                        Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getAccountingDataCard(
      BuildContext context, DateTime date, List<AccountingData> data,
      {String toSearch = ""}) {
    List<DataRow> rows = [];

    for (var dataLine in data) {
      print("${dataLine.positionName}: ${ngram(dataLine.positionName, toSearch)}");

      if (toSearch == "" || ngram(dataLine.positionName, toSearch) > 0.3) {
        rows.add(DataRow(cells: [
          DataCell(Text(
            dataLine.positionName,
            style: TextStyle(fontSize: 16),
          )),
          DataCell(Text(dataLine.getData(), style: TextStyle(fontSize: 16))),
          DataCell(Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "delete",
                  child: Text("Удалить"),
                ),
                PopupMenuItem(
                  value: "change",
                  child: Text("Изменить"),
                ),
              ],
              onSelected: (value) {
                if (value == "delete") {
                  if (widget.groupInfo.groupType == TypesOfGroup.priceData) {
                    DatabaseProvider.deletePriceDataById(dataLine.id);
                  } else if (widget.groupInfo.groupType ==
                      TypesOfGroup.timeData) {
                    DatabaseProvider.deleteTimeDataById(dataLine.id);
                  }
                } else if (value == "change") {
                  showDialog(
                      useSafeArea: false,
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => getDataChangeDialog(
                          context, widget.groupInfo, dataLine));
                }

                setState(() {});
              },
            ),
          ))
        ]));
      }
    }

    List<Widget> cardHeader = [Expanded(child: getDateBadge(date))];
    if (dateIsEqual(SimpleDateTimeFactory.createCurrent(), date)) {
      cardHeader.add(InkWell(
        splashColor: Colors.white30,
        onTap: () {
          showDialog(
              context: context,
              builder: (context) =>
                  getDataCreateDialog(context, widget.groupInfo));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9.5, vertical: 9.5),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ));
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      color: Colors.teal.shade800,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardHeader,
          ),
          DataTable(
              dataRowColor: MaterialStatePropertyAll(Colors.white),
              // columnSpacing: 100,
              columns: [
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              headingRowHeight: 0,
              rows: rows)
        ],
      ),
    );
  }

  Widget getAccountingDataCards(String toSearch) {
    return FutureBuilder(
        future: widget.groupInfo.getGroupData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(""),
            );
          }
          List<AccountingData> dataEntries = snapshot.data;
          List<Widget> cards = [];

          if (dataEntries.isEmpty ||
              dataEntries.isNotEmpty &&
                  !dateIsEqual(dataEntries[0].date,
                      SimpleDateTimeFactory.createCurrent())) {
            cards.add(
              getAccountingDataCard(
                  context, SimpleDateTimeFactory.createCurrent(), []),
            );

            cards.add(SizedBox(height: 10));
          }

          int start = 0;
          int end = 1;
          while (end < dataEntries.length) {
            if (!dateIsEqual(dataEntries[start].date, dataEntries[end].date)) {
              cards.add(getAccountingDataCard(context, dataEntries[start].date,
                  dataEntries.sublist(start, end),
                  toSearch: toSearch));
              start = end;
              cards.add(SizedBox(height: 10));
            }

            end++;
          }

          if (dataEntries.isNotEmpty) {
            cards.add(getAccountingDataCard(context, dataEntries[start].date,
                dataEntries.sublist(start, end),
                toSearch: toSearch));
            cards.add(SizedBox(height: 10));
          }

          return Expanded(
              child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade400,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SearchBar(
          controller: searchText,
          onChanged: (text) {setState(() {
          });},
          trailing: [
            Icon(
              Icons.search,
              color: Colors.black,
            ),
            SizedBox(width: 15)
          ],
        ),
        toolbarHeight: 70,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getGroupsBadge(),
          SizedBox(height: 20),
          getAccountingDataCards(searchText.text)
        ],
      ),
    );
  }
}
