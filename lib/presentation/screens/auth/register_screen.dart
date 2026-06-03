import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  static const name = 'register-screen';

  const RegisterScreen({super.key});

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


                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 100,
                    color: Colors.blueAccent,
                  ),

                  const SizedBox(height: 20),

                 
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Nombre
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                 
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                    ),
                  ),

                  const SizedBox(height: 30),

                
                 
                 
                  TextButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}