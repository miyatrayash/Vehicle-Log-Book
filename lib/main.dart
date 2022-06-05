import 'package:flutter/material.dart';
import 'package:log_book/data_provider.dart';
import 'package:log_book/home_screen.dart';
import 'package:log_book/model_log.dart';
import 'package:log_book/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => DataProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Provider.of<DataProvider>(context, listen: false).fetchData(DateTime(DateTime.now().year,DateTime.now().month));
    return MaterialApp(
      title: 'Log Book Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    DataProvider? data = context.watch<DataProvider>();

    if (!context.watch<DataProvider>().isDataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Log Book Entry'),
          centerTitle: true,
        ),
        body: const CircularProgressIndicator(),
      );
    }

    if (!data.isLogged) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}