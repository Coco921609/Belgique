import 'package:flutter/material.dart';
import '../lib/langue.dart';
import '../lib/belgique/français/home.dart' show Home;
import '../lib/belgique/anglais/home.dart' show HomeEnglish;
import '../lib/belgique/français/bruxelles.dart' show Bruxelles;
import '../lib/belgique/français/Gand.dart' show Gand;
import '../lib/belgique/français/bruges.dart' show Bruges;
import '../lib/belgique/français/anvers.dart' show Anvers;
import '../lib/belgique/français/liege.dart' show Liege;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final screen = Uri.base.queryParameters['screen'] ?? 'language';

  final Widget page = switch (screen) {
    'language' => const LanguePage(),
    'home-fr' => const Home(),
    'home-en' => const HomeEnglish(),
    'brussels' => const Bruxelles(),
    'ghent' => const Gand(),
    'bruges' => const Bruges(),
    'antwerp' => const Anvers(),
    'liege' => const Liege(),
    _ => const LanguePage(),
  };

  runApp(MaterialApp(
    title: 'Belgique — aperçu',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: page,
  ));
}
