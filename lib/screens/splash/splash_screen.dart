import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [

              Color(0xff6C63FF),

              Color(0xff8B5CF6),

            ],

          ),

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.menu_book_rounded,

              color: Colors.white,

              size: 90,

            ),

            const SizedBox(height: 25),

            const Text(

              "BookShelf",

              style: TextStyle(

                color: Colors.white,

                fontSize: 34,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 8),

            const Text(

              "Tu biblioteca personal",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 45),

            const CircularProgressIndicator(

              color: Colors.white,

            ),

          ],

        ),

      ),

    );

  }
}