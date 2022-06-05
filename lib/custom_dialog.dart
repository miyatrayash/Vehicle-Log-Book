import 'package:flutter/material.dart';
import 'package:log_book/data_provider.dart';
import 'package:log_book/model_log.dart';
import 'package:provider/provider.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog({
    Key? key,
    required this.log,
    required this.isFuel,
    required this.index,
    required this.title,
  }) : super(key: key);

  final Log log;
  final int index;
  final bool isFuel;
  final String title;
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if(isFuel) {
      _controller.text = log.fuelDetail[index];
    } else {
      _controller.text = log.dailyDetail[index];
    }
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
                 Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLength: null,
                  maxLines: 10,
                  controller: _controller,
                  style: const TextStyle(fontSize: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: (){
                          if(isFuel)
                            {
                              log.fuelDetail[index] = _controller.text;
                            }
                          else {
                            log.dailyDetail[index] = _controller.text;
                          }
                          Provider.of<DataProvider>(context,listen: false).updateLog(log);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
