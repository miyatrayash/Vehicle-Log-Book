import 'package:flutter/material.dart';
import 'package:log_book/database_service.dart';
import 'package:log_book/model_log.dart';

class DataProvider with ChangeNotifier {
    Log? log;
    bool isLogged = false;
    bool isDataLoaded = false;

    fetchData(DateTime month) async {

      isDataLoaded = false;
      isLogged = await DatabaseService().isLogged();
      if(isLogged) {
        log = await DatabaseService().getLogByMonth(month);
      }

      isDataLoaded = true;
      if(log == null) {
        log = Log(
            id: DateTime.now().toIso8601String(),
            vehicleDetail: '',
            month: month,
            startingKM: 0,
            endingKM: 0,
            dailyKM: [],
            dailyDetail: [],
            fuelDetail: [],
        );

        await DatabaseService().insertLog(log!);
      }
      notifyListeners();
    }

    Future updateLog(Log log) async {
      this.log = log;
      Log? oldLog = await DatabaseService().getLogByMonth(log.month);
      if(oldLog == null) {
          await DatabaseService().insertLog(log);
      }
      else {
        await DatabaseService().updateLog(log);
      }

      await fetchData(log.month);
      notifyListeners();
    }

    updateAuth() async {
      await DatabaseService().updateAuth();
      fetchData(DateTime(DateTime.now().year,DateTime.now().month));
    }

}