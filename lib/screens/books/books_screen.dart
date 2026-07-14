import 'package:flutter/material.dart';

import '../../database/book_repository.dart';
import '../../models/book.dart';
import '../../utils/session.dart';
import '../../widgets/book_card.dart';
import 'book_form_screen.dart';
import '../reader/pdf_reader_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {

  final BookRepository repository = BookRepository();

  final TextEditingController searchController =
      TextEditingController();

  List<Book> books = [];

  List<Book> filteredBooks = [];

  bool loading = true;

  String selectedFilter = "Todos";

  @override
  void initState() {
    super.initState();

    loadBooks();
  }

  Future<void> loadBooks() async {

    books = await repository.getBooksByUser(
      Session.userId!,
    );

    loading = false;

    applyFilters();

  }

  Future<void> openForm() async {

    bool? refresh = await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const BookFormScreen(),

      ),

    );

    if (refresh == true) {

      loadBooks();

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Mi Biblioteca"),

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: openForm,

        child: const Icon(Icons.add),

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [
                        TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Buscar libro...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {

                applyFilters();

              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [

                  FilterChip(
                    label: const Text("Todos"),
                    selected: selectedFilter == "Todos",
                    onSelected: (_) {

                      setState(() {
                        selectedFilter = "Todos";
                      });

                      applyFilters();

                    },
                  ),

                  const SizedBox(width: 10),

                  FilterChip(
                    label: const Text("Leyendo"),
                    selected: selectedFilter == "Leyendo",
                    onSelected: (_) {

                      setState(() {

                        selectedFilter = "Leyendo";

                      });

                      applyFilters();

                    },
                  ),

                  const SizedBox(width: 10),

                  FilterChip(
                    label: const Text("Terminados"),
                    selected: selectedFilter == "Terminado",
                    onSelected: (_) {

                      setState(() {
                        selectedFilter = "Terminado";
                      });

                      applyFilters();

                    },
                  ),

                  const SizedBox(width: 10),

                  FilterChip(
                    label: const Text("Favoritos"),
                    selected: selectedFilter == "Favoritos",
                    onSelected: (_) {

                      setState(() {
                        selectedFilter = "Favoritos";
                      });

                      applyFilters();

                    },
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: loading

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : filteredBooks.isEmpty

                      ? const Center(
                          child: Text(
                            "No hay libros registrados",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )

                      : ListView.builder(

                          itemCount: filteredBooks.length,

                          itemBuilder: (context, index) {

                            final book = filteredBooks[index];

                            return BookCard(

                              title: book.title,

                              author: book.author,

                              imageUrl: book.imageUrl,

                              status: book.status,

                              favorite: book.favorite,

                              onRead: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) => PdfReaderScreen(

                                      pdfPath: book.pdfPath,

                                      title: book.title,

                                    ),

                                  ),

                                );

                              },

                              onEdit: () async {

                                bool? refresh = await Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) => BookFormScreen(
                                      book: book,
                                    ),

                                  ),

                                );

                                if (refresh == true) {

                                  loadBooks();

                                }

                              },

                              onDelete: () {

                                deleteBook(book);

                              },

                              onFavorite: () {

                                favoriteBook(book);

                              },

                            );

                          },

                        ),

            ),
          ],
      ),
    ),
  );
}

void applyFilters() {

  filteredBooks = List.from(books);

  if (searchController.text.trim().isNotEmpty) {

    filteredBooks = filteredBooks.where((book) {

      return book.title
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

    }).toList();

  }

  if (selectedFilter == "Leyendo") {

    filteredBooks = filteredBooks.where((book) {

      return book.status == "Leyendo";

    }).toList();

  }

  if (selectedFilter == "Terminado") {

    filteredBooks = filteredBooks.where((book) {

      return book.status == "Terminado";

    }).toList();

  }

  if (selectedFilter == "Favoritos") {

    filteredBooks = filteredBooks.where((book) {

      return book.favorite;

    }).toList();

  }

  setState(() {});
}

  Future<void> deleteBook(Book book) async {

    bool? confirm = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Eliminar libro"),

          content: Text(
            "¿Deseas eliminar '${book.title}'?",
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context, false);

              },

              child: const Text("Cancelar"),

            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(context, true);

              },

              child: const Text("Eliminar"),

            ),

          ],

        );

      },

    );

    if (confirm == true) {

      await repository.deleteBook(book.id!);

      loadBooks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text("Libro eliminado correctamente"),

        ),

      );

    }

  }

Future<void> favoriteBook(Book book) async {

  await repository.updateFavorite(

    book.id!,

    !book.favorite,

  );

  loadBooks();

  }

  @override
  void dispose() {

    searchController.dispose();

    super.dispose();

  }
}

