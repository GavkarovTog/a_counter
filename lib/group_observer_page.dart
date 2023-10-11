import 'package:a_counter/data_observer_page.dart';
import 'package:a_counter/group_creator_page.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:a_counter/database_provider.dart';

class GroupObserverPage extends StatefulWidget {
  const GroupObserverPage({super.key});

  @override
  State<GroupObserverPage> createState() => _GroupObserverPageState();
}

class _GroupObserverPageState extends State<GroupObserverPage> {
  // Future getGroupNames() async {
  //   Database db = await DatabaseProvider.db;
  //   return db.transaction((txn) async {
  //     return await txn.rawQuery("SELECT name FROM groups");
  //   });
  // }

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
      child: Text("Учетные группы",
          style: TextStyle(fontFamily: 'Times New Roman', fontSize: 22)),
    );
  }

  Widget getGroupTile(BuildContext context, String title) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(32, 0, 0, 0),
      title: Text("$title", style: TextStyle(fontSize: 20)),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: InkWell(
              onTap: () async {
                Database db = await DatabaseProvider.db;
                await db.transaction((txn) async {
                  await txn.rawQuery(
                  '''
                  DELETE FROM groups
                  WHERE groups.name = ?
                  ''',
                  [title]);
                });

                setState(() {});
              },
              splashColor: Colors.black12,
                child: Ink(
                  height: double.infinity,
                  color: Colors.redAccent,
                    child: Icon(Icons.delete_outline, color: Colors.black),
                ))
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.white24,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DataObserverPage(title)));
                },
                child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                      ),
                      color: Colors.tealAccent,
                    ),
                  height: double.infinity,
                  child: Icon(Icons.chevron_right, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      tileColor: Colors.teal.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget getGroupsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder(
        initialData: [],
        future: DatabaseProvider.getGroupNames(),
        builder: (context, snapshot) {
          if (! snapshot.hasData) {
            return Text("Загрузка базы данных");
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              String title = snapshot.data[index]["name"];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: getGroupTile(context, title),
              );
            },
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade400,
      appBar: AppBar(
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
          const SizedBox(height: 10),
          getGroupsList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        splashColor: Colors.black12,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GroupCreatorPage())
          ).then((status) {
            if (! status.isOk) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ошибка: " + status.message))
              );
            } else {
              setState(() {});
            }
          });
        },
        backgroundColor: Colors.teal.shade200,
        foregroundColor: Colors.black,
        child: Text("+", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
