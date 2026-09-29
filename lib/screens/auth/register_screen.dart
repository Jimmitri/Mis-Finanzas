import 'package:flutter/material.dart';
import '../../database/user_repository.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = UserRepository();

    // Validar si el correo ya existe
    final existingUser = await repository.getUserByEmail(
      emailController.text.trim(),
    );

    if (!mounted) return;

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este correo ya se encuentra registrado"),
          backgroundColor: AppColors.expense,
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
        content: Text("Usuario registrado con éxito. Ahora inicia sesión."),
        backgroundColor: AppColors.income,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Regístrate",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ingresa tus datos para comenzar a registrar gastos",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),

                // Campo Nombre
                CustomTextField(
                  controller: nameController,
                  label: "Nombre completo",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ingrese su nombre completo";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Correo
                CustomTextField(
                  controller: emailController,
                  label: "Correo electrónico",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ingrese su correo electrónico";
                    }
                    if (!value.contains("@")) {
                      return "Ingrese un correo válido";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Contraseña
                CustomTextField(
                  controller: passwordController,
                  label: "Contraseña",
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  validator: (value) {
                    if (value == null || value.length < 4) {
                      return "La contraseña debe tener al menos 4 caracteres";
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Campo Confirmar Contraseña
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
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Botón Registrarse
                CustomButton(
                  text: "Registrarse",
                  icon: Icons.person_add_alt_1,
                  onPressed: _register,
                ),

                const SizedBox(height: 20),

                // Enlace a Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿Ya tienes cuenta?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}