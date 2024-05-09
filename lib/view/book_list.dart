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
