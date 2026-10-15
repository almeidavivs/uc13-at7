import 'package:flutter/material.dart';
import '../database/sessao.dart';
import 'ajuda_screen.dart';
import 'login_screen.dart';
import '../tema/app_cores.dart';
import '../widgets/comuns.dart';

/// Perfil do usuário: dados da conta, saldo e a lista de opções do app.
class AbaPerfil extends StatelessWidget {
  const AbaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _cartaoUsuario(context),
          const SizedBox(height: 16),
          _cartaoSaldo(),
          const SizedBox(height: 16),
          _listaOpcoes(context),
          const SizedBox(height: 24),

          // Sair da conta: limpa a sessão e volta para o login, removendo
          // todas as telas anteriores da pilha de navegação.
          Center(
            child: TextButton.icon(
              onPressed: () {
                Sessao.sair();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (rota) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sair da conta'),
              style: TextButton.styleFrom(
                foregroundColor: AppCores.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoUsuario(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      child: Row(
        children: [
          // Avatar com as iniciais do nome. Para usar uma foto, troque o
          // CircleAvatar por um ClipOval com Image.asset.
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppCores.laranjaFundo,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              Sessao.iniciais,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppCores.laranjaEscuro,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Sessao.nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppCores.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Sessao.telefone.isEmpty ? Sessao.email : Sessao.telefone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppCores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edição de perfil ainda não implementada.'),
              ),
            ),
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
              color: AppCores.laranja,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoSaldo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppCores.laranjaFundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meu saldo',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppCores.laranjaEscuro,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatarReal(Sessao.saldo),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppCores.laranjaEscuro,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 34,
            color: AppCores.laranja,
          ),
        ],
      ),
    );
  }

  Widget _listaOpcoes(BuildContext context) {
    // Cada item é um mapa com ícone, texto e a ação de toque.
    final opcoes = <Map<String, dynamic>>[
      {'icone': Icons.receipt_long_outlined, 'texto': 'Meus pedidos'},
      {'icone': Icons.location_on_outlined, 'texto': 'Endereços salvos'},
      {'icone': Icons.credit_card, 'texto': 'Métodos de pagamento'},
      {'icone': Icons.notifications_none, 'texto': 'Notificações'},
      {
        'icone': Icons.help_outline,
        'texto': 'Solicitar ajuda',
        'tela': const AjudaScreen(),
      },
      {'icone': Icons.star_border, 'texto': 'Minhas avaliações'},
      {'icone': Icons.settings_outlined, 'texto': 'Configurações'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      // ClipRRect impede que o efeito de toque vaze pelos cantos redondos.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: List.generate(opcoes.length, (i) {
            final opcao = opcoes[i];

            return Column(
              children: [
                if (i > 0) const Divider(indent: 52),
                ListTile(
                  leading: Icon(
                    opcao['icone'] as IconData,
                    size: 21,
                    color: AppCores.laranja,
                  ),
                  title: Text(
                    opcao['texto'] as String,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppCores.texto,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppCores.textoClaro,
                  ),
                  onTap: () {
                    final tela = opcao['tela'] as Widget?;

                    if (tela != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => tela),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${opcao['texto']}: em desenvolvimento.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
