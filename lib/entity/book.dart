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