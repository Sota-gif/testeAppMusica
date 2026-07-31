import 'package:flutter/material.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MeuAppMusica());
}

class MeuAppMusica extends StatelessWidget {
  const MeuAppMusica({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Música',
      theme: ThemeData.dark(), // Tema escuro para estilo "Spotify"
      home: const SearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}