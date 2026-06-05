import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/config/router/app_router.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
