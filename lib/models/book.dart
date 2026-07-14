class Book {
  int? id;
  int userId;

  String title;
  String author;
  String category;
  int year;
  String description;
  String imageUrl;
  String pdfPath;
  String status;
  bool favorite;

  Book({
    this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.pdfPath,
    required this.status,
    this.favorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'author': author,
      'category': category,
      'year': year,
      'description': description,
      'imageUrl': imageUrl,
      'pdfPath': pdfPath,
      'status': status,
      'favorite': favorite ? 1 : 0,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      author: map['author'],
      category: map['category'],
      year: map['year'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      pdfPath: map['pdfPath'],
      status: map['status'],
      favorite: map['favorite'] == 1,
    );
  }
}