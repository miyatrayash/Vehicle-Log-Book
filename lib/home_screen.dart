import 'dart:io';
import 'dart:math';

import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:log_book/custom_dialog.dart';
import 'package:log_book/custom_snackbar.dart';
import 'package:log_book/data_provider.dart';
import 'package:log_book/helper.dart';
import 'package:log_book/model_log.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  Log? log;
  final TextEditingController _startingKM = TextEditingController();
  final TextEditingController _endingKM = TextEditingController();
  final TextEditingController _vehicleDetails = TextEditingController();

  changeMonth() async {
    DateTime? newMonth =
        await showMonthPicker(context: context, initialDate: month);
    // print(newMonth!.month);
    setState(() {
      if (newMonth != null) {
        month = newMonth;
      }
    });

    await Provider.of<DataProvider>(context, listen: false).fetchData(month);
  }

  loadData() async {
    DataProvider data = Provider.of<DataProvider>(context);
    // print('here');
    setState(() {
      log = data.log;
      log ??= Log(
        id: '',
        vehicleDetail: '',
        month: month,
        startingKM: 0,
        endingKM: 0,
        dailyKM: [],
        dailyDetail: [],
        fuelDetail: [],
      );
    });
    // print(data.log!.month);
    if (data.log == null) {
      await data.updateLog(log!);
    }
  }

  changeData(Log item) async {
    DataProvider data = Provider.of<DataProvider>(context, listen: false);
    await data.updateLog(item);
  }

  void onEditingComplete() {
    if (int.parse(_startingKM.text, onError: (_) => 0) >
        int.parse(_endingKM.text, onError: (_) => 0)) {
      _endingKM.text = _startingKM.text;
    }

    setState(() {
      log!.startingKM = int.parse(_startingKM.text, onError: (_) => 0);
      log!.endingKM = int.parse(_endingKM.text, onError: (_) => 0);
      log!.vehicleDetail = _vehicleDetails.text;
      changeData(log!);
    });
  }

  int total() {
    int val = 0;

    for (int i = 0; i < log!.dailyKM.length; i++) {
      val += log!.dailyKM[i];
    }

    return val;
  }

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (log == null || snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (log?.startingKM != 0) {
            _startingKM.text = log!.startingKM.toString();
          }
          if (log!.endingKM != 0) {
            _endingKM.text = log!.endingKM.toString();
          }
          _vehicleDetails.text = log!.vehicleDetail;
          _startingKM.selection = TextSelection.fromPosition(
              TextPosition(offset: _startingKM.text.length));

          _endingKM.selection = TextSelection.fromPosition(
              TextPosition(offset: _endingKM.text.length));

          _vehicleDetails.selection = TextSelection.fromPosition(
              TextPosition(offset: _vehicleDetails.text.length));

          return Scaffold(
            appBar: AppBar(
              title: const Text('Log Book Entry'),
              centerTitle: true,
              actions: [
                SpeedDial(
                  openCloseDial: isDialOpen,
                  icon: Icons.settings,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  direction: SpeedDialDirection.down,
                  children: [
                    SpeedDialChild(
                      label: 'Export Pdf',
                      child: const Icon(Icons.picture_as_pdf_rounded),
                      onTap: () async {
                        Helper.exportToPdf(log!).then((a) {
                          CustomSnackBar.showSnackBar(
                              'Pdf is Exported To Downloads', context);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        changeMonth();
                      },
                      child: Text(
                        DateFormat('yMMMM').format(log!.month).toString(),
                        style: const TextStyle(fontSize: 25),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            return;
                          }

                          setState(() {
                            log?.vehicleDetail = _vehicleDetails.text;
                          });
                        },
                        child: TextFormField(
                          controller: _vehicleDetails,
                          onEditingComplete: onEditingComplete,
                          decoration: const InputDecoration(
                              label: Text(
                                "Vehicle Details",
                                style: TextStyle(fontSize: 25),
                              ),
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: TextFormField(
                              controller: _startingKM,
                              keyboardType: TextInputType.number,
                              onEditingComplete: onEditingComplete,
                              decoration: const InputDecoration(
                                label: Text(
                                  "Starting KM",
                                  style: TextStyle(fontSize: 25),
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            child: TextFormField(
                              controller: _endingKM,
                              onEditingComplete: onEditingComplete,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  label: Text(
                                    "Ending KM",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Mid(log: log),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class Mid extends StatefulWidget {
  const Mid({
    Key? key,
    this.log,
  }) : super(key: key);
  final Log? log;
  @override
  State<Mid> createState() => _MidState();
}

class _MidState extends State<Mid> {
  final TextEditingController _pendingKM = TextEditingController();
  final TextEditingController _usedKM = TextEditingController();

  @override
  initState() {
    super.initState();
    changePending();
  }

  void changePending() {
    int val = 0;
    for (int i = 0; i < widget.log!.dailyKM.length; i++) {
      val += widget.log!.dailyKM[i];
    }

    _pendingKM.text =
        max(0, (widget.log!.endingKM - val - widget.log!.startingKM))
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    Log? log = Provider.of<DataProvider>(context).log;
    if (log == null) {
      return const CircularProgressIndicator();
    }
    _usedKM.text = (log.endingKM - log.startingKM).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: TextFormField(
                controller: _usedKM,
                enabled: false,
                decoration: const InputDecoration(
                    label: Text(
                      "Used KM",
                      style: TextStyle(fontSize: 25),
                    ),
                    border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: TextFormField(
                enabled: false,
                controller: _pendingKM,
                decoration: const InputDecoration(
                    label: Text(
                      "Pending KM",
                      style: TextStyle(fontSize: 25),
                    ),
                    border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        DataGrid(
          startingKM: widget.log!.startingKM,
          endingKM: widget.log!.endingKM,
          changePending: changePending,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                DataProvider data =
                    Provider.of<DataProvider>(context, listen: false);

                data.updateLog(data.log!).then((value) {
                  CustomSnackBar.showSnackBar('Data Saved', context);
                });
              },
              child: const Text('Save'),
            ),
            Text(
                'Total: ${((int.parse(_usedKM.text) - int.parse(_pendingKM.text))).toString()}',
                style: const TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(0, 10),
                                          blurRadius: 10),
                                    ]),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      "Delete Item",
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const Text(
                                      "Are you Sure You Want to Clear this month",
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                          onPressed: (){
                                            DataProvider data =
                                            Provider.of<DataProvider>(context, listen: false);
                                            data.log!.dailyKM = [];
                                            data.log!.startingKM = 0;
                                            data.log!.endingKM = 0;
                                            data.log!.vehicleDetail = '';
                                            data.updateLog(data.log!);
                                          },
                                          child: const Text(
                                            "Confirm",
                                            style: TextStyle(fontSize: 18),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                    });
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        )
      ],
    );
  }
}

class DataGrid extends StatefulWidget {
  const DataGrid(
      {Key? key,
      required this.startingKM,
      required this.endingKM,
      required this.changePending})
      : super(key: key);

  final int startingKM;
  final int endingKM;
  final VoidCallback changePending;
  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  final List<TextEditingController> _dailyControllers = [];
  final List<FocusNode> _dailyFocuses = [];
  final List<Map<String, int>> kms = [];
  @override
  Widget build(BuildContext context) {
    Log? log = Provider.of<DataProvider>(context).log;

    if (log == null) {
      return const CircularProgressIndicator();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: MediaQuery.of(context).size.height / 2 - 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'End',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  '''KM\nUse''',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fuel',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
            rows: List.generate(log.dailyKM.length, (index) {
              _dailyControllers.add(TextEditingController());
              _dailyFocuses.add(FocusNode());
              _dailyControllers[index].text = log.dailyKM[index].toString();
              _dailyControllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: _dailyControllers[index].text.length));
              kms.add({});
              if (index == 0) {
                kms[index]['Start'] = int.parse(widget.startingKM.toString());
              } else {
                kms[index]['Start'] =
                    kms[index - 1].putIfAbsent('End', () => 0);
              }

              int newEnd = kms[index].putIfAbsent('Start', () => 0) +
                  int.parse(_dailyControllers[index].text, onError: (_) => 0);
              if (newEnd > widget.endingKM) {
                _dailyControllers[index].text =
                    (widget.endingKM - kms[index].putIfAbsent('Start', () => 0))
                        .toString();
                newEnd = widget.endingKM;
              }
              kms[index]['End'] = newEnd;

              return DataRow(cells: [
                DataCell(
                  Text(
                    DateFormat('dd/MM/y')
                        .format(log.month.add(Duration(days: index)))
                        .toString(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                DataCell(Text(
                  kms[index]['Start'].toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )),
                DataCell(Text(
                  kms[index]['End'].toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )),
                DataCell(
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        return;
                      }

                      setState(() {
                        log.dailyKM[index] = int.parse(
                            _dailyControllers[index].text,
                            onError: (_) => 0);
                        widget.changePending();
                      });
                    },
                    child: TextFormField(
                      controller: _dailyControllers[index],
                      focusNode: _dailyFocuses[index],
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: false),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      onEditingComplete: () {
                        setState(() {
                          log.dailyKM[index] = int.parse(
                              _dailyControllers[index].text,
                              onError: (_) => 0);

                          if (index != log.dailyKM.length - 1) {
                            _dailyFocuses[index + 1].requestFocus();
                          } else {
                            _dailyFocuses[index].unfocus();
                          }
                          widget.changePending();
                        });
                      },
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                          isFuel: false,
                          log: log,
                          index: index,
                          title: 'Details',
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ),
                DataCell(
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                          isFuel: true,
                          log: log,
                          index: index,
                          title: 'Fuel Details',
                        ),
                      );
                    },
                    icon: const Icon(FontAwesomeIcons.gasPump),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
