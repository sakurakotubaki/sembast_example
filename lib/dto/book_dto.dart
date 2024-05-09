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