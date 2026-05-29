import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                 
                  const Icon(Icons.movie_creation_rounded, size: 100, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  
                  
                  const Text(
                    'Bienvenido a Cinexa', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 40),

                  
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

                  
                  TextFormField(
                    obscureText: true, 
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

                  
                  TextButton(
                    onPressed: () {
                        context.push('/register');
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