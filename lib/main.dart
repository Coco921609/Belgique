import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour bloquer l'orientation
import 'langue.dart';

void main() {
  // Assure que les liaisons Flutter sont initialisées
  WidgetsFlutterBinding.ensureInitialized();

  // Bloque l'orientation en mode portrait uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Enlève le bandeau DEBUG en haut à droite
      title: 'Belgique Voyage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LanguePage(), // Votre page initiale
    );
  }
}