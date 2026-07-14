import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../database/user_repository.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,
            child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 10),

              const Text(

                "Crear Cuenta",

                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 8),

              const Text(

                "Completa tus datos para comenzar",

                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),

              ),

              const SizedBox(height: 40),

              CustomTextField(
                controller: nameController,
                label: "Nombre completo",
                icon: Icons.person_outline,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese su nombre";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

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
                    if (value == null || value.length < 6) {
                      return "Mínimo 6 caracteres";
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

              const SizedBox(height: 20),

              CustomTextField(
                controller: confirmPasswordController,
                label: "Confirmar contraseña",
                icon: Icons.lock_outline,
                obscureText: obscureConfirmPassword,

                validator: (value) {

                  if (value != passwordController.text) {
                    return "Las contraseñas no coinciden";
                  }

                  return null;
                },

                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                      !obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 35),

              CustomButton(
                text: "Registrarse",
                icon: Icons.person_add_alt_1,
                onPressed: () async {

                  if (_formKey.currentState!.validate()) {

                    final repository = UserRepository();

                    final existingUser = await repository.getUserByEmail(
                      emailController.text.trim(),
                    );

                    if (existingUser != null) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Este correo ya está registrado"),
                        ),
                      );
                      return;
                    }

                    final user = User(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );

                    await repository.registerUser(user);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Usuario registrado correctamente"),
                      ),
                    );

                    Navigator.pop(context);
                  }

                },
              ),

              const SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text("¿Ya tienes cuenta?"),

                  TextButton(

                    onPressed: () {

                      Navigator.pop(context);

                    },

                    child: const Text("Iniciar sesión"),

                  ),

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