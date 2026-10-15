import 'package:flutter/material.dart';
import 'aba_home.dart';
import 'aba_favoritos.dart';
import 'aba_historico.dart';
import 'aba_configuracoes.dart';
import '../tema/app_cores.dart';

/// Tela principal do aplicativo.
///
/// Funciona como uma "casca": ela não desenha conteúdo próprio, apenas a
/// barra de navegação inferior e a aba selecionada no momento.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Guarda qual aba está aberta. 0 = Início.
  int _abaAtual = 0;

  // Lista das quatro telas que compõem a navegação inferior.
  final List<Widget> _abas = const [
    AbaHome(),
    AbaFavoritos(),
    AbaHistorico(),
    AbaConfiguracoes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FD9052, // Cor de fundo laranja suave.

      // IndexedStack mantém as abas vivas em segundo plano: ao voltar para
      // a tela inicial, a posição da rolagem e os filtros continuam como
      // estavam. Um simples _abas[_abaAtual] recriaria a tela toda vez.
      body: IndexedStack(index: _abaAtual, children: _abas),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppCores.superficie,
          border: Border(top: BorderSide(color: AppCores.borda)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _abaAtual,
            onTap: (indice) => setState(() => _abaAtual = indice),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppCores.laranja,
            unselectedItemColor: AppCores.textoSuave,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Carteira',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
