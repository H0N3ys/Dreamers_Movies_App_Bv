import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono
                  const Icon(Icons.movie_creation_rounded, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  
                  // Título
                  const Text(
                    'Bienvenido a Cinexa', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 40),

                  // Campo de Correo
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Contraseña
                  TextFormField(
                    obscureText: true, // Oculta los caracteres
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(height: 10),

                  // Botón de texto para registro
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}