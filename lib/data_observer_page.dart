import 'package:flutter/material.dart';
import 'package:a_counter/database_provider.dart';
import 'package:path/path.dart';

bool dateIsEqual(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class GroupData {
  GroupData(this.groupType, this.data);
  
  TypesOfGroup groupType;
  List<AccountingData> data;
}

class DataObserverPage extends StatelessWidget {
  DataObserverPage(this.groupName, {super.key});

  String groupName;

  Future fetchDataFromDatabase() async {
    return GroupData(
        await DatabaseProvider.getTypeOfGroup(groupName), 
        await DatabaseProvider.getDataForGroup(groupName)
    );
  }

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
      child: Text("Группа '$groupName'",
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

  Widget getDataCreateDialog(BuildContext context, String groupName, TypesOfGroup groupType) {
    TextEditingController name = TextEditingController();
    TextEditingController priceOrDate = TextEditingController();
    TextInputType inputType = groupType == TypesOfGroup.priceData ?
    TextInputType.number : TextInputType.datetime;

    String hintForData = groupType == TypesOfGroup.priceData
        ? "Цена" : "Время";

    return SimpleDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
      title: Text("Внести учетные данные"),
      children: [
        Container(
          // margin:
          //     EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              textAlign: TextAlign.center,
              controller: name,
              decoration:
              InputDecoration(hintText: "Наименование"),
            )),
        Container(
          // margin:
          //     EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: inputType,
              controller: priceOrDate,
              decoration: InputDecoration(hintText: hintForData),
            )),
        Row(
          children: [
            Expanded(
              child: InkWell(
                child: Ink(
                    padding:
                    EdgeInsets.symmetric(vertical: 5),
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
                    padding:
                    EdgeInsets.symmetric(vertical: 5),
                    color: Colors.tealAccent,
                    child: Icon(Icons.check)),
                splashColor: Colors.white24,
                onTap: () async {

                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget getAccountingDataCard(
      BuildContext context, TypesOfGroup groupType, DateTime date, List<AccountingData> data) {
    List<DataRow> rows = [];

    for (var dataLine in data) {
      rows.add(DataRow(cells: [
        DataCell(Text(dataLine.positionName)),
        DataCell(Text(dataLine.getData()))
      ]));
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
            children: [
              Expanded(child: getDateBadge(date)),
              InkWell(
                splashColor: Colors.white30,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => getDataCreateDialog(context, groupName, groupType));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.5, vertical: 9.5),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              )
              // ElevatedButton(onPressed: () {}, child: Icon(Icons.add))
            ],
          ),
          DataTable(
              columnSpacing: 1,
              columns: [
                DataColumn(label: Text('')),
                DataColumn(label: Text(''))
              ],
              headingRowHeight: 0,
              rows: rows)
        ],
      ),
    );
  }

  Widget getAccountingDataCards() {
    return FutureBuilder(
        future: fetchDataFromDatabase(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(""),
            );
          }

          TypesOfGroup type = snapshot.data.groupType;
          List<AccountingData> dataEntries = snapshot.data.data;
          List<Widget> cards = [];

          if (dataEntries.isEmpty ||
              dataEntries.isNotEmpty &&
                  dateIsEqual(dataEntries[0].date, DateTime.now())) {
            cards.add(
              getAccountingDataCard(context, type, DateTime.now(), []),
            );
          }

          int start = 0;
          int end = 1;
          while (end < dataEntries.length) {
            if (!dateIsEqual(dataEntries[start].date, dataEntries[end].date)) {
              cards.add(getAccountingDataCard(context, type,
                  dataEntries[start].date,
                  dataEntries.sublist(start, end)));
              start = end;
            }

            end++;
          }

          if (dataEntries.isNotEmpty) {
            cards.add(getAccountingDataCard(context, type,
                dataEntries[start].date,
                dataEntries.sublist(start, end - 1)));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade400,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SearchBar(
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
          getAccountingDataCards()
        ],
      ),
    );
  }
}
