# sembast_example

1. create flutter project
```bash
flutter create sembast_example --org com.jboy
```

2. add package
```bash
flutter pub add sembast
flutter pub add path_provider
```

3. create model class
```dart
// data model of sembast
class Book {
  int? id;
  final String title;
  final String author;
  
  Book({
    this.id,
    required this.title,
    required this.author,
  });

  // toMap method to convert the object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
    };
  }

  // fromMap method to convert a map to an object
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
    );
  }
}
```

4. create dto class
```dart
// book dto class sembast
import 'package:sembast/sembast.dart';

import 'package:sembast_example/entity/book.dart';

// Singleton class for Sembast database
class BookDB {
  // Singleton instance
  static final BookDB _singleton = BookDB._();

  // Singleton accessor
  static BookDB get instance => _singleton;

  // Database instance
  late Database _database;

  // Store reference
  final _store = intMapStoreFactory.store('book_store');

  // Private constructor
  BookDB._();

  // Initialize database
  Future<void> init(Database database) async {
    _database = database;
  }

  // Insert a new book into the database
  Future<int> insert(Book book) async {
    return await _store.add(_database, book.toMap());
  }

  // Update an existing book in the database
  Future<int> update(Book book) async {
    final finder = Finder(filter: Filter.byKey(book.id));
    return await _store.update(_database, book.toMap(), finder: finder);
  }

  // Delete a book from the database
  Future<int> delete(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    return await _store.delete(_database, finder: finder);
  }

  // Get all books from the database
  Future<List<Book>> getAllSortedByName() async {
    final finder = Finder(sortOrders: [SortOrder('title')]);
    final recordSnapshots = await _store.find(_database, finder: finder);

    return recordSnapshots.map((snapshot) {
      final book = Book.fromMap(snapshot.value);
      book.id = snapshot.key;
      return book;
    }).toList();
  }
}
```

5. create ui class
```dart
import 'package:flutter/material.dart';
import 'package:sembast_example/dto/book_dto.dart';
import 'package:sembast_example/entity/book.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book List'),
      ),
      body: FutureBuilder<List<Book>>(
        future: BookDB.instance.getAllSortedByName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Book>? books = snapshot.data;
            return ListView.builder(
              itemCount: books?.length,
              itemBuilder: (_, index) {
                final book = books![index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await BookDB.instance.delete(book.id!);
                      setState(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted ${book.title}'
                          ),
                          backgroundColor: Colors.redAccent,
                          ),
                      );
                      });
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.add),
  onPressed: () async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new book'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Add this line
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(hintText: 'Author'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                String title = titleController.text;
                String author = authorController.text;

                // Add your book to the database here
                Book book = Book(title: title, author: author);
                await BookDB.instance.insert(book);
                setState(() {
                  titleController.clear();
                  authorController.clear();
                });
                if(context.mounted) {
                Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  },
),
    );
  }
}
```