import 'dart:io';

import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:log_book/model_log.dart';
import 'package:permission_handler/permission_handler.dart';

class Helper {
  static Future<void> exportToPdf(Log log) async {
     String htmlContent = "";
    htmlContent += """
    <html lang="en">
    <head>

    <style>
        h2 {
          text-align: center;
        }
        table {
  table-layout: fixed;
  border-collapse: collapse;
  width: 1000px;
}
 td {
  font-size: 20px;
 }

        </style>
        
</head>
<body>
    <h2> Vehicle Log Book ${DateFormat('yMMMM').format(log.month)} </h2>
    <table border="1" cellspacing="0" cellpadding="0">
        <tr>
            <td colspan="6" align="center">Vehicle Name</td>
            <td colspan="6" align="center">${log.vehicleDetail}</td>
        </tr>
                <td colspan="3" align="center">Starting KMs</td>
                <td colspan="3" align="center">${log.startingKM} KM</td>
                <td colspan="3" align="center">Ending KMs</td>
                <td colspan="3" align="center">${log.endingKM} KM</td>

        </tr>
        <tr>
            <td colspan="6" align="center">Used KMs</td>
            <td colspan="6" align="center">${log.endingKM - log.startingKM}</td>
        </tr>
        </table>
        <table border="1" cellspacing="0" cellpadding="0">
        <tr>
            
                <th colspan="2" align="center">Date</th>
                <th colspan="2" align="center">Start</th>
                <th colspan="2" align="center">End</th>
                <th colspan="2" align="center">Used</th>
                <th colspan="3" align="center">Details</th>
                <th colspan="3" align="center">Fuel Details</th>
                             
        </tr>
        <tr>  
        """;

    var val = log.startingKM;
    for (int i = 0; i < log.dailyDetail.length; i++) {
      int startingKM = val;
      int endingKM = val + log.dailyKM[i];
      val = endingKM;
      htmlContent += '''<tr>
        <td colspan="2" align="center">${DateFormat('dd/MM/y').format(log.month.add(Duration(days: i)))}</td>
        <td colspan="2" align="center">$startingKM</td>
        <td colspan="2" align="center">$endingKM</td>
        <td colspan="2" align="center">${log.dailyKM[i]}</td>
        <td colspan="3" align="start">${log.dailyDetail[i]}</td>
        <td colspan="3" align="start">${log.fuelDetail[i]}</td>
    </tr> ''';
    }

    htmlContent += """</tr>
        </tr> </table> </body></html>""";

    var targetPath = "/storage/emulated/0/Download/";
    var targetFileName =
        "Vehicle Log ${DateFormat('yMMMM').format(log.month)}.pdf";

    if (await Permission.storage.request().isGranted &&
        await Permission.manageExternalStorage.request().isGranted) {
      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent, targetPath, targetFileName);
      // final file = File(
      //     '/storage/emulated/0/Download/Vehicle Log ${DateFormat('yMMMM').format(log.month)}.pdf');
      // await file.writeAsBytes(await pdf.save());
    }
  }
}
