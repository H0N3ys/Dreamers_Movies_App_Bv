import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:go_router/go_router.dart';
>>>>>>> 3bc987ed97a9d5bee28c54c31dc1b04c86f1bbb6

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
<<<<<<< HEAD
                  const Icon(Icons.movie_creation_rounded, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  
                  // Título
                  const Text(
                    'Bienvenido a Cinexa', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 40),

                  // Campo de Correo
=======
                  const Icon(
                    Icons.movie_creation_rounded,
                    size: 100,
                    color: Colors.blueAccent,
                  ),

                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Bienvenido a Cinexa',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Campo de correo
>>>>>>> 3bc987ed97a9d5bee28c54c31dc1b04c86f1bbb6
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(
<<<<<<< HEAD
                        borderRadius: BorderRadius.circular(12)
=======
                        borderRadius: BorderRadius.circular(12),
>>>>>>> 3bc987ed97a9d5bee28c54c31dc1b04c86f1bbb6
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 20),

                  //Contraseña
                  TextFormField(
                    obscureText: true, // Oculta los caracteres
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
=======

                  const SizedBox(height: 20),

                  // Contraseña
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
>>>>>>> 3bc987ed97a9d5bee28c54c31dc1b04c86f1bbb6
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 30),
                  const SizedBox(height: 10),

                  // Botón de texto para registro
                  TextButton(
                    onPressed: () {
                      
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  )
=======

                  const SizedBox(height: 30),

                  // Botón login
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Iniciar sesión'),
                  ),

                  const SizedBox(height: 10),

                  // Registro
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                    ),
                  ),
>>>>>>> 3bc987ed97a9d5bee28c54c31dc1b04c86f1bbb6
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}