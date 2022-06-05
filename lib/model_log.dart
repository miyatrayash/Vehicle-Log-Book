import 'dart:convert';

class Log {
  String id;
  String vehicleDetail;
  DateTime month;
  int startingKM;
  int endingKM;
  List<int> dailyKM;
  List<String> dailyDetail;
  List<String> fuelDetail;

  Log(
      {required this.id,
      required this.vehicleDetail,
      required this.month,
      required this.startingKM,
      required this.endingKM,
      required this.dailyKM,
      required this.dailyDetail,
      required this.fuelDetail}) {
    if (dailyKM.isEmpty) {
      for (DateTime indexDay = DateTime(month.year, month.month);
          indexDay.month == month.month;
          indexDay = indexDay.add(const Duration(days: 1))) {
        dailyKM.add(0);
        dailyDetail.add('');
        fuelDetail.add('');
      }
    }
  }

  factory Log.fromJson(Map<String, dynamic> data) {
    List<int> d = json.decode(data['dailyKM']).cast<int>();
    List<String> dailyDetail = json.decode(data['dailyDetail']).cast<String>();
    List<String> fuelDetail = json.decode(data['fuelDetail']).cast<String>();
    DateTime m = DateTime.parse(data['month']);
    if (d.isEmpty) {
      for (DateTime indexDay = DateTime(m.year, m.month);
          indexDay.month == m.month;
          indexDay = indexDay.add(const Duration(days: 1))) {
        d.add(0);
        dailyDetail.add('');
        fuelDetail.add('');
      }
    }
    return Log(
        id: data['id'],
        vehicleDetail: data['vehicleDetail'],
        month: m,
        startingKM: data['startingKM'],
        endingKM: data['endingKM'],
        dailyKM: d,
        dailyDetail: dailyDetail,
        fuelDetail: fuelDetail);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleDetail': vehicleDetail,
        'month': month.toIso8601String(),
        'startingKM': startingKM,
        'endingKM': endingKM,
        'dailyKM': json.encode(dailyKM),
        'dailyDetail': json.encode(dailyDetail),
        'fuelDetail': json.encode(fuelDetail),
      };
}
