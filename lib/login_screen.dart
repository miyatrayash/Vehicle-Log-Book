import 'package:flutter/material.dart';
import 'package:log_book/data_provider.dart';
import 'package:log_book/model_log.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String err = '';

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  DateTime startingDate = DateTime.parse('2001-01-01');

  DateTime lastDate = DateTime.parse('3001-01-01');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Book Entry'),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Card(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: usernameController,
                    onChanged: (_) => setState(() {
                      err = '';
                    }),
                    validator: (txt) {
                      if (txt == null || txt.isEmpty) {
                        return 'Enter Username';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // showMonthPicker(context: context, initialDate: DateTime.now()),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {
                      err = '';
                    }),
                    validator: (txt) {
                      if (txt == null || txt.isEmpty) {
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  color: Colors.red,
                  height: (err.isNotEmpty) ? 50 : 0,
                  child: Center(
                      child: Text(
                    (err.isNotEmpty) ? err : '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  )),
                ),
                ElevatedButton(
                    onPressed: () async {
                      FormState? formState = formKey.currentState;
                      if (formState == null || !formState.validate()) {
                        return;
                      }
                      formState.save();
                      print(usernameController.text);
                      print(passwordController.text);
                      if (usernameController.text != 'Jayesh' ||
                          passwordController.text != '16112106@Yjm') {
                      //   if (usernameController.text != 'yash' ||
                      //       passwordController.text != '1234') {
                        setState(() {
                          err = 'Username Or Password is Incorrect';
                        });
                        return;
                      }

                      await Provider.of<DataProvider>(context,listen: false).updateAuth();

                    },
                    child: const Text('Submit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
