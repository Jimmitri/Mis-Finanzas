import 'package:flutter/material.dart';

import '../../database/book_repository.dart';
import '../../models/book.dart';
import '../../utils/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final BookRepository repository = BookRepository();

  List<Book> books = [];

  bool loading = true;

  int totalBooks = 0;
  int favorites = 0;
  int reading = 0;
  int finished = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    books = await repository.getBooksByUser(
      Session.userId!,
    );

    totalBooks = books.length;

    favorites = books.where((b) => b.favorite).length;

    reading = books.where((b) => b.status == "Leyendo").length;

    finished = books.where((b) => b.status == "Terminado").length;

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Inicio"),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                                    Text(
                    "Hola ${Session.userName ?? "Usuario"} 👋",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Bienvenido nuevamente a tu biblioteca digital",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [

                      Expanded(
                        child: _buildCard(
                          icon: Icons.menu_book,
                          title: "Libros",
                          value: totalBooks.toString(),
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _buildCard(
                          icon: Icons.favorite,
                          title: "Favoritos",
                          value: favorites.toString(),
                          color: Colors.red,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: _buildCard(
                          icon: Icons.auto_stories,
                          title: "Leyendo",
                          value: reading.toString(),
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: _buildCard(
                          icon: Icons.check_circle,
                          title: "Terminados",
                          value: finished.toString(),
                          color: Colors.green,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Resumen",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              const Icon(Icons.menu_book, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Tienes $totalBooks libros registrados.",
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 30),

                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "$favorites marcados como favoritos.",
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 30),

                          Row(
                            children: [
                              const Icon(Icons.auto_stories, color: Colors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Actualmente lees $reading libros.",
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 30),

                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Has terminado $finished libros.",
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                                ],
              ),
            ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 16,
        ),
        child: Column(
          children: [

            Icon(
              icon,
              size: 40,
              color: color,
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),
    );
  }
}