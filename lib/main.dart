import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Pacote base do Flutter para criação de interfaces (Material Design).
// Primeira tela que o usuário vê ao abrir o aplicativo.
import 'screens/splash_screen.dart';
// Tema e paleta do projeto.
import 'tema/app_tema.dart';



// A função main() é o ponto de partida de qualquer aplicativo Dart/Flutter.
void main() {
  runApp(const ComaBemApp());
}

class ComaBemApp extends StatelessWidget {
  const ComaBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura o app inteiro: título, tema e tela inicial.
    return MaterialApp(
      title: 'Coma Bem',
      // Remove a faixa vermelha de "DEBUG" no canto da tela.
      debugShowCheckedModeBanner: false,

      // Todo o visual do aplicativo vem do tema montado em AppTema.
      theme: AppTema.montar(),

      // home define qual tela abre primeiro: a Splash Screen.
      home: const SplashScreen(),
    );
  }
}
