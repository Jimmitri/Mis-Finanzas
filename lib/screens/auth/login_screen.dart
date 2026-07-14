import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import '../home/main_screen.dart';
import '../../database/user_repository.dart';
import '../../utils/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,
            child: Column(

            children: [

              const SizedBox(height: 40),

              Container(

                width: 100,
                height: 100,

                decoration: BoxDecoration(

                  color: AppColors.primary,

                  borderRadius: BorderRadius.circular(30),

                ),

                child: const Icon(

                  Icons.menu_book_rounded,

                  color: Colors.white,

                  size: 55,

                ),

              ),

              const SizedBox(height: 25),

              const Text(

                "BookShelf",

                style: TextStyle(

                  fontSize: 30,
                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 8),

              const Text(

                "Bienvenido de nuevo",

                style: TextStyle(

                  fontSize: 16,
                  color: AppColors.textSecondary,

                ),

              ),

              const SizedBox(height: 45),

              CustomTextField(

                controller: emailController,

                label: "Correo electrónico",

                icon: Icons.email_outlined,

                keyboardType: TextInputType.emailAddress,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese su correo";
                  }

                  if (!value.contains("@")) {
                    return "Correo inválido";
                  }

                  return null;
                },

              ),

              const SizedBox(height: 20),

              CustomTextField(

                controller: passwordController,

                label: "Contraseña",

                icon: Icons.lock_outline,

                obscureText: obscurePassword,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese su contraseña";
                  }

                  return null;
                },

                suffixIcon: IconButton(

                  icon: Icon(

                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),

                  onPressed: () {

                    setState(() {

                      obscurePassword = !obscurePassword;

                    });

                  },

                ),

              ),

              const SizedBox(height: 35),

              CustomButton(

                text: "Iniciar sesión",

                icon: Icons.login,

                onPressed: () async {

                  if (_formKey.currentState!.validate()) {

                    final repository = UserRepository();

                    final user = await repository.loginUser(
                      emailController.text.trim(),
                      passwordController.text,
                    );

                    if (!mounted) return;

                    if (user != null) {

                      Session.userId = user.id;
                      Session.userName = user.name;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Bienvenido ${user.name}"),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(),
                        ),
                      );

                    } else {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Correo o contraseña incorrectos"),
                        ),
                      );

                    }

                  }

                },

              ),

              const SizedBox(height: 30),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text("¿No tienes cuenta?"),

                  TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) => const RegisterScreen(),

                        ),

                      );

                    },

                    child: const Text("Crear cuenta"),

                  )

                ],

              )

            ],

          ),

          ),

        ),

      ),

    );

  }

}