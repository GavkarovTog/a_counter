import 'dart:math';

import 'package:a_counter/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:a_counter/utils.dart';
import 'package:flutter/rendering.dart';

// overall price
// goods with max price
// goods with min price
// average overall price
// most frequently buyed products
// max price per good
// min price per good
// average price for distinct good

// overall time
// average overall time
// activity with max summary time
// activity with min summary time
// average time per activity
// min time per activity
// max time per activity

class StatisticsPage extends StatelessWidget {
  StatisticsPage(this.groupInfo, {super.key});

  Group groupInfo;

  Widget getGroupStatisticsBadge() {
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
      child: Text("Статистика группы '${groupInfo.groupName}'",
          style: TextStyle(fontFamily: 'Times New Roman', fontSize: 22)),
    );
  }

  // Widget getPriceDataStatistics() {
  //   return Expanded(
  //     child: SingleChildScrollView(
  //       child: FutureBuilder(
  //           future:
  //               DatabaseProvider.getPriceDataStatistics(groupInfo.groupName),
  //           builder: (context, snapshot) {
  //             if (!snapshot.hasData) {
  //               return Text("");
  //             }
  //
  //             GroupStatistics statistics = snapshot.data;
  //
  //             List<DataRow> maxValues = [];
  //             for (var entry
  //                 in statistics.maxActivityData.getMaxValuesPerPosition()) {
  //               String position = entry.keys.toList()[0].toString();
  //
  //               maxValues.add(DataRow(cells: [
  //                 DataCell(Text(position)),
  //                 DataCell(Text(entry[position].toString()))
  //               ]));
  //             }
  //
  //             List<DataRow> averageValues = [];
  //             for (var entry in statistics.averageActivityData
  //                 .getAverageValuePerPosition()) {
  //               String position = entry.keys.toList()[0].toString();
  //
  //               averageValues.add(DataRow(cells: [
  //                 DataCell(Text(position)),
  //                 DataCell(Text(entry[position].toString()))
  //               ]));
  //             }
  //
  //             List<DataRow> minValues = [];
  //             for (var entry
  //                 in statistics.minActivityData.getMinValuePerPosition()) {
  //               String position = entry.keys.toList()[0].toString();
  //
  //               minValues.add(DataRow(cells: [
  //                 DataCell(Text(position)),
  //                 DataCell(Text(entry[position].toString()))
  //               ]));
  //             }
  //
  //             TextStyle fieldStyle = TextStyle(fontSize: 16);
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Card(
  //                   clipBehavior: Clip.hardEdge,
  //                   margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //                   color: Colors.white,
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         color: Colors.teal.shade100,
  //                         height: 20,
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Общие расходы:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.overallAccountingData.getOverallValue()}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Средний расход на товар:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.overallAccountingData.getAverageValue()}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Наибольшая цена товара:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.maxActivityData.getMaxValue()}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Товары с наибольшей ценой:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.maxActivityData.getMaxValue() != 0.0 ? statistics.maxActivityData.getMaxValuePositions().join(", ") : ""}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Наименьшая цена товара:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.minActivityData.getMinValue()}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Товары с наименьшей ценой:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.minActivityData.getMinValue() != 0.0 ? statistics.minActivityData.getMinValuePositions().join(", ") : ""}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Товары с наименьшей ценой:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.minActivityData.getMinValue() != 0.0 ? statistics.minActivityData.getMinValuePositions().join(", ") : ""}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Количество частых покупок:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.averageActivityData.getCountOfFrequentPositionBuys()}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       ListTile(
  //                         leading: Text(
  //                           "Самые частые покупки:",
  //                           style: fieldStyle,
  //                         ),
  //                         trailing: Text(
  //                           "${statistics.averageActivityData.getCountOfFrequentPositionBuys() != 0 ? statistics.averageActivityData.getFrequentPositions().join(", ") : ""}",
  //                           style: fieldStyle,
  //                         ),
  //                       ),
  //                       Container(
  //                         color: Colors.teal.shade100,
  //                         height: 20,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   margin: EdgeInsets.symmetric(horizontal: 20),
  //                   child: DataTable(
  //                       dataRowColor: MaterialStatePropertyAll(Colors.white),
  //                       headingRowColor:
  //                           MaterialStatePropertyAll(Colors.teal.shade100),
  //                       columns: [
  //                         DataColumn(label: Text("Позиция")),
  //                         DataColumn(label: Text("Максимальная цена"))
  //                       ],
  //                       rows: maxValues),
  //                 ),
  //                 Container(
  //                   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //                   child: DataTable(
  //                       dataRowColor: MaterialStatePropertyAll(Colors.white),
  //                       headingRowColor:
  //                           MaterialStatePropertyAll(Colors.teal.shade100),
  //                       columns: [
  //                         DataColumn(label: Text("Позиция")),
  //                         DataColumn(label: Text("Средняя цена"))
  //                       ],
  //                       rows: averageValues),
  //                 ),
  //                 Container(
  //                   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //                   child: DataTable(
  //                       dataRowColor: MaterialStatePropertyAll(Colors.white),
  //                       headingRowColor:
  //                           MaterialStatePropertyAll(Colors.teal.shade100),
  //                       columns: [
  //                         DataColumn(label: Text("Позиция")),
  //                         DataColumn(label: Text("Минимальная цена"))
  //                       ],
  //                       rows: minValues),
  //                 ),
  //               ],
  //             );
  //           }),
  //     ),
  //   );
  // }

  Widget getPriceDataStatistics() {
    return Expanded(
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: DatabaseProvider.getPriceDataStatistics(groupInfo.groupName),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("");
              }
              GroupStatistics statistics = snapshot.data;
              TextStyle fieldStyle = TextStyle(fontSize: 14);

              List<DataRow> maxValues = [];
              for (var entry
              in statistics.maxActivityData.getMaxValuesPerPosition()) {
                String position = entry.keys.toList()[0].toString();

                maxValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<DataRow> averageValues = [];
              for (var entry in statistics.averageActivityData
                  .getAverageValuePerPosition()) {
                String position = entry.keys.toList()[0].toString();

                averageValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<DataRow> minValues = [];
              for (var entry
              in statistics.minActivityData.getMinValuePerPosition()) {
                String position = entry.keys.toList()[0].toString();

                minValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<Widget> positionsWithMaxValues = [];
              for (String position
              in statistics.maxActivityData.getMaxValuePositions()) {
                positionsWithMaxValues.add(
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        alignment: Alignment.center,
                        child: Text(position, style: fieldStyle)
                    )
                );
              }

              List<Widget> positionsWithMinValues = [];
              for (String position
              in statistics.minActivityData.getMinValuePositions()) {
                positionsWithMinValues.add(
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        alignment: Alignment.center,
                        child: Text(position, style: fieldStyle)
                    )
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    color: Colors.white,
                    child: Column(children: [
                      // Container(
                      //   color: Colors.teal.shade100,
                      //   height: 20,
                      // ),
                      DataTable(
                          dividerThickness: 0,
                          horizontalMargin: 0,
                          columns: [
                            DataColumn(label: Text("")),
                            DataColumn(label: Text("")),
                          ],
                          headingRowHeight: 0,
                          rows: [
                            DataRow(cells: [
                              DataCell(Text("Общие расходы:", style: fieldStyle)),
                              DataCell(Text(
                                "${statistics.overallAccountingData.getOverallValue()}",
                                style: fieldStyle,
                                softWrap: false,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Средний расход на товар:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.overallAccountingData.getAverageValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Наибольшая цена товара:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.maxActivityData.getMaxValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Наименьшая цена товара:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.minActivityData.getMinValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            // DataRow(cells: [
                            //   DataCell(),
                            //   DataCell()
                            // ]),
                          ]),


                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.teal.shade100,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Text("Товары с наибольшей ценой"),
                          ),
                          Column(
                            children: positionsWithMaxValues,
                          )
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.teal.shade100,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Text("Товары с наименьшей ценой"),
                          ),
                          Column(
                            children: positionsWithMinValues,
                          )
                        ],
                      ),
                      // Container(
                      //   color: Colors.teal.shade100,
                      //   height: 20,
                      // ),
                    ]),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                        MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Максимальный расход"))
                        ],
                        rows: maxValues),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                        MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Средний расход"))
                        ],
                        rows: averageValues),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                        MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Минимальный расход"))
                        ],
                        rows: minValues),
                  ),
                ],
              );
            }),
      ),
    );
  }


  Widget getTimeDataStatistics() {
    return Expanded(
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: DatabaseProvider.getTimeDataStatistics(groupInfo.groupName),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("");
              }
              GroupStatistics statistics = snapshot.data;
              TextStyle fieldStyle = TextStyle(fontSize: 14);

              List<DataRow> maxValues = [];
              for (var entry
                  in statistics.maxActivityData.getMaxValuesPerPosition()) {
                String position = entry.keys.toList()[0].toString();

                maxValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<DataRow> averageValues = [];
              for (var entry in statistics.averageActivityData
                  .getAverageValuePerPosition()) {
                String position = entry.keys.toList()[0].toString();

                averageValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<DataRow> minValues = [];
              for (var entry
                  in statistics.minActivityData.getMinValuePerPosition()) {
                String position = entry.keys.toList()[0].toString();

                minValues.add(DataRow(cells: [
                  DataCell(Text(position)),
                  DataCell(Text(entry[position].toString()))
                ]));
              }

              List<Widget> positionsWithMaxValues = [];
              for (String position
                  in statistics.maxActivityData.getMaxValuePositions()) {
                positionsWithMaxValues.add(
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      alignment: Alignment.center,
                        child: Text(position, style: fieldStyle)
                    )
                );
              }

              List<Widget> positionsWithMinValues = [];
              for (String position
              in statistics.minActivityData.getMinValuePositions()) {
                positionsWithMinValues.add(
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    alignment: Alignment.center,
                      child: Text(position, style: fieldStyle)
                  )
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    color: Colors.white,
                    child: Column(children: [
                      // Container(
                      //   color: Colors.teal.shade100,
                      //   height: 20,
                      // ),
                      DataTable(
                          dividerThickness: 0,
                          horizontalMargin: 0,
                          columns: [
                            DataColumn(label: Text("")),
                            DataColumn(label: Text("")),
                          ],
                          headingRowHeight: 0,
                          rows: [
                            DataRow(cells: [
                              DataCell(Text("Общее время:", style: fieldStyle)),
                              DataCell(Text(
                                "${statistics.overallAccountingData.getOverallValue()}",
                                style: fieldStyle,
                                softWrap: false,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Среднее время на позицию:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.overallAccountingData.getAverageValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Наибольшее время позиции:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.maxActivityData.getMaxValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            DataRow(cells: [
                              DataCell(Text(
                                "Наименьшее время позиции:",
                                style: fieldStyle,
                              )),
                              DataCell(Text(
                                "${statistics.minActivityData.getMinValue()}",
                                style: fieldStyle,
                              ))
                            ]),
                            // DataRow(cells: [
                            //   DataCell(),
                            //   DataCell()
                            // ]),
                          ]),

                      // Container(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.stretch,
                      //     children: [
                      //
                      //       Container(
                      //         alignment: Alignment.center,
                      //         color: Colors.teal.shade100,
                      //         child: Text(
                      //           "Позиции с наибольшим временем:",
                      //           style: fieldStyle,
                      //         ),
                      //       ),
                      //       // ListView.builder(
                      //       //   shrinkWrap: true,
                      //       //   itemCount: statistics.maxActivityData.getMaxValuePositions().length,
                      //       //   itemBuilder: (context, index) {
                      //       //     List<String> maxTimePositions = statistics.maxActivityData.getMaxValuePositions();
                      //       //     List<Widget> positionsToList = [];
                      //       //     maxTimePositions.forEach((element) {
                      //       //       positionsToList.add(Container(child: Text(element), alignment: Alignment.center));
                      //       //     });
                      //       //
                      //       //     return positionsToList[index];
                      //       //   },
                      //       // )
                      //       // Text(
                      //       //   "${statistics.maxActivityData.getMaxValue() != "0 ч, 0 м" ? statistics.maxActivityData.getMaxValuePositions().join(", ") : ""}",
                      //       //   style: fieldStyle,
                      //       // )
                      //     ],
                      //   ),
                      // ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.teal.shade100,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Text("Позиции с наибольшим временем"),
                          ),
                          Column(
                            children: positionsWithMaxValues,
                          )
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.teal.shade100,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Text("Позиции с наименьшим временем"),
                          ),
                          Column(
                            children: positionsWithMinValues,
                          )
                        ],
                      ),
                      // Container(
                      //   color: Colors.teal.shade100,
                      //   height: 20,
                      // ),
                    ]),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                            MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Максимальное время"))
                        ],
                        rows: maxValues),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                            MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Среднее время"))
                        ],
                        rows: averageValues),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: DataTable(
                        dataRowColor: MaterialStatePropertyAll(Colors.white),
                        headingRowColor:
                            MaterialStatePropertyAll(Colors.teal.shade100),
                        columns: [
                          DataColumn(label: Text("Позиция")),
                          DataColumn(label: Text("Минимальное время"))
                        ],
                        rows: minValues),
                  ),
                ],
              );
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal.shade400,
        body: SafeArea(
          child: Column(
            children: [
              getGroupStatisticsBadge(),
              groupInfo.groupType == TypesOfGroup.priceData
                  ? getPriceDataStatistics()
                  : getTimeDataStatistics(),
            ],
          ),
        ));
  }
}
