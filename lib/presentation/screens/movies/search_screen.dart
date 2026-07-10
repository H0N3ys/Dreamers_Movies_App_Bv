import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class SearchScreen extends StatefulWidget {
  static const name = 'search-screen';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Buscar Películas', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Pantalla de búsqueda en construcción 🚧',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}