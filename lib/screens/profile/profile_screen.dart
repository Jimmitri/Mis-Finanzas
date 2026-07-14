import 'package:flutter/material.dart';

import '../../database/book_repository.dart';
import '../../database/user_repository.dart';
import '../../models/user.dart';
import '../../screens/auth/login_screen.dart';
import '../../utils/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final UserRepository userRepository = UserRepository();
  final BookRepository bookRepository = BookRepository();

  User? user;

  int totalBooks = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    user = await userRepository.getUserById(
      Session.userId!,
    );

    final books = await bookRepository.getBooksByUser(
      Session.userId!,
    );

    totalBooks = books.length;

    setState(() {

      loading = false;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Perfil"),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding: const EdgeInsets.all(20),

              child: Column(

                children: [
                                    const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    user?.name ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [

                          const Icon(
                            Icons.menu_book,
                            size: 45,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Libros registrados",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  totalBooks.toString(),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Cerrar sesión",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {

                        bool? salir = await showDialog<bool>(
                          context: context,
                          builder: (context) {

                            return AlertDialog(

                              title: const Text("Cerrar sesión"),

                              content: const Text(
                                "¿Desea cerrar la sesión?",
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
                                  child: const Text("Salir"),
                                ),

                              ],
                            );

                          },
                        );

                        if (salir == true) {

                          Session.userId = null;
                          Session.userName = null;

                          if (!mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );

                        }

                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}