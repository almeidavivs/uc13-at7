import 'package:flutter/material.dart';
import '../tema/app_cores.dart';
import '../widgets/comuns.dart';

/// Histórico de pedidos.
///
/// Os pedidos abaixo são dados de exemplo mantidos em memória: a tabela de
/// pedidos não faz parte do escopo desta atividade, que cobre as tabelas de
/// usuário e de restaurante. A tela já está pronta para receber os dados do
/// SQLite quando a tabela for criada — basta trocar a lista `_pedidos` por
/// uma consulta em `DatabaseHelper`.
class AbaPedidos extends StatelessWidget {
  const AbaPedidos({super.key});

  static const List<Map<String, dynamic>> _pedidos = [
    {
      'data': 'Hoje, 12:45',
      'status': 'A caminho',
      'total': 34.90,
      'itens': [
        {'qtd': 1, 'nome': 'Fettuccine ao Pesto', 'valor': 32.90},
      ],
    },
    {
      'data': '12 Mai 2026, 20:15',
      'status': 'Entregue',
      'total': 58.50,
      'itens': [
        {'qtd': 1, 'nome': 'Filé à Parmegiana', 'valor': 42.50},
        {'qtd': 2, 'nome': 'Suco de Laranja Natural', 'valor': 16.00},
      ],
    },
    {
      'data': '08 Mai 2026, 13:10',
      'status': 'Entregue',
      'total': 29.90,
      'itens': [
        {'qtd': 1, 'nome': 'Salada Caesar', 'valor': 26.00},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        itemCount: _pedidos.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          // O primeiro item da lista é o subtítulo da tela.
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Histórico e andamento das suas refeições',
                style: TextStyle(fontSize: 14, color: AppCores.textoSuave),
              ),
            );
          }

          return _cartaoPedido(_pedidos[index - 1]);
        },
      ),
    );
  }

  Widget _cartaoPedido(Map<String, dynamic> pedido) {
    final entregue = pedido['status'] == 'Entregue';
    final itens = pedido['itens'] as List;

    return Container(
      decoration: BoxDecoration(
        color: AppCores.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: data à esquerda, selo de status à direita.
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data do pedido',
                    style: TextStyle(fontSize: 11, color: AppCores.textoSuave),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pedido['data'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppCores.texto,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Selo(
                texto: pedido['status'] as String,
                cor: entregue ? AppCores.verde : AppCores.azul,
                fundo: entregue ? AppCores.verdeFundo : AppCores.azulFundo,
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          const Text(
            'ITENS DO PEDIDO',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppCores.textoSuave,
            ),
          ),
          const SizedBox(height: 10),

          // Uma linha por item do pedido.
          ...itens.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${item['qtd']}x',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppCores.laranja,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['nome'] as String,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppCores.texto,
                      ),
                    ),
                  ),
                  Text(
                    formatarReal(item['valor'] as num),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppCores.textoSuave,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'Total do pedido',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppCores.texto,
                ),
              ),
              const Spacer(),
              Text(
                formatarReal(pedido['total'] as num),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppCores.laranja,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
