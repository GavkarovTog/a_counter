import 'package:a_counter/utils.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:a_counter/database_provider.dart';

class GroupCreatorPage extends StatelessWidget {
  GroupCreatorPage({super.key});

  GlobalKey<FormState> _toCreate = GlobalKey<FormState>();
  TextEditingController _groupName = TextEditingController();
  TextEditingController _groupType = TextEditingController();

  void okAction(context) async {
    if (!_toCreate.currentState!.validate()) {
      return;
    }

    List<Group> groups =
    await DatabaseProvider.getGroupInfo();

    String groupName = _groupName.text;
    TypesOfGroup groupType = Type.fromStringToEnum(_groupType.text);
    AppStatus status = AppStatus.ok();

    if (groups.contains(Group(groupName, groupType))) {
      status = AppStatus.err("Попытка создать группу с занятым именем.");
    } else {
      DatabaseProvider.addGroup(groupName, groupType);
    }

    Navigator.of(context).pop(status);
  }

  Widget getNewGroupBadge() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 1),
            spreadRadius: 1,
            blurRadius: 2,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text("Создать новую группу",
          style: TextStyle(fontFamily: 'Times New Roman', fontSize: 22)),
    );
  }

  List<DropdownMenuEntry> getTypesMenuItems(List<TypesOfGroup> types) {
    List<DropdownMenuEntry> entries = [];

    for (int i = 0; i < types.length; i ++) {
      entries.add(DropdownMenuEntry(
        value: (i + 1).toString(),
        label: Type.fromEnumToString(types[i]),
        style: ButtonStyle(),
      ));
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal.shade400,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(AppStatus(true, "Operation canceled!"));
            return false;
          },
          child: Scaffold(
              backgroundColor: Colors.teal.shade400,
              body: Column(
                children: [
                  getNewGroupBadge(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _toCreate,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _groupName,
                              validator: (val) {
                                if (val == "") {
                                  return "Поле должно быть заполнено";
                                }
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.teal.shade100,
                                  labelText: "Наименование группы",
                                  errorStyle: TextStyle(color: Colors.black)),
                              maxLength: 38,
                            ),
                            DropdownMenu(
                              controller: _groupType,
                              inputDecorationTheme: InputDecorationTheme(
                                  filled: true,
                                  fillColor: Colors.teal.shade100),
                              menuStyle: MenuStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                          Colors.teal.shade100)),
                              label: Text("Тип группы"),
                              initialSelection: "1",
                              dropdownMenuEntries: getTypesMenuItems(Type.groupTypes),
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          AppStatus(true, "Cancel operation!"));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black45,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        backgroundColor: Colors.white),
                                    child: const Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                    onPressed: () => okAction(context),

                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        backgroundColor: Colors.teal.shade200),
                                    child: const Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
