import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_example/dto/book_dto.dart';
import 'package:sembast_example/view/book_list.dart';

import 'package:sembast/sembast_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory
  final appDocumentDir = await getApplicationDocumentsDirectory();

  // Specify the location of the database file
  final dbPath = appDocumentDir.path + 'book.db';

  // Initialize your database
  DatabaseFactory dbFactory = databaseFactoryIo;
  Database db = await dbFactory.openDatabase(dbPath);

  // Initialize your singleton class with the database
  BookDB.instance.init(db);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BookList(),
    );
  }
}