import 'package:flutter/material.dart';
// DatabaseHelper dá acesso às funções de consulta (SELECT).
import '../database/database_helper.dart';
import '../database/sessao.dart';
// Tela de cadastro, aberta pelo botão "+".
import 'cadastro_screen.dart';
import 'detalhe_screen.dart';
import '../tema/app_cores.dart';
import '../widgets/foto_prato.dart';
import '../widgets/comuns.dart';

/// Tela inicial: lista os pratos cadastrados no SQLite, ordenados pela nota.
///
/// Traz a busca por nome e os filtros por categoria, como no protótipo.
class AbaInicio extends StatefulWidget {
  const AbaInicio({super.key});

  @override
  State<AbaInicio> createState() => _AbaInicioState();
}

class _AbaInicioState extends State<AbaInicio> {
  // Lista de Mapas para guardar os dados retornados do banco. Cada "Mapa"
  // representa uma linha da tabela 'restaurante'.
  List<Map<String, dynamic>> _pratos = [];
  List<String> _categorias = [];

  String _categoriaAtual = 'Todos';
  String _busca = '';
  bool _carregando = true;

  final _buscaController = TextEditingController();

  // Assim que a tela carrega, já buscamos os dados no banco.
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  /// Executa os SELECTs no banco e atualiza a tela com o resultado.
  Future<void> _carregarDados() async {
    final categorias = await DatabaseHelper.instancia.listarCategorias();
    final pratos = await DatabaseHelper.instancia.listarRestaurantes(
      categoria: _categoriaAtual,
      busca: _busca,
    );

    if (!mounted) return;

    // setState avisa o Flutter que os dados mudaram, forçando o redesenho.
    setState(() {
      _categorias = ['Todos', ...categorias];
      _pratos = pratos;
      _carregando = false;
    });
  }

  /// Abre a tela de cadastro e recarrega a lista ao voltar dela.
  Future<void> _abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
    _carregarDados();
  }

  Future<void> _abrirDetalhe(Map<String, dynamic> prato) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalheScreen(prato: prato)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,

      // CustomScrollView permite que o cabeçalho role junto com a lista,
      // em vez de ficar preso no topo ocupando espaço.
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        color: AppCores.laranja,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _cabecalho()),
            SliverToBoxAdapter(child: _filtros()),
            if (_carregando)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppCores.laranja),
                ),
              )
            else if (_pratos.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _listaVazia())
            else
              _grade(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        backgroundColor: AppCores.laranja,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -----------------------------------------------------------------
  // CABEÇALHO ESCURO
  // -----------------------------------------------------------------
  Widget _cabecalho() {
    return Container(
      decoration: const BoxDecoration(
        color: AppCores.escuro,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Linha do topo: nome do app e ícone de sacola.
            Row(
              children: [
                const Text(
                  'Coma Bem',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppCores.laranja,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Saudação com o nome de quem fez login.
            Text(
              'Olá, ${Sessao.primeiroNome}!',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

            // Endereço, com o pino em laranja.
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 15,
                  color: AppCores.laranja,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    Sessao.endereco,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppCores.textoClaro,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Campo de busca. onChanged dispara a consulta a cada tecla.
            TextField(
              controller: _buscaController,
              onChanged: (texto) {
                _busca = texto;
                _carregarDados();
              },
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar pratos...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                // O campo de busca fica sobre o fundo escuro, então
                // removemos as bordas visíveis para ele parecer flutuar.
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppCores.laranja),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // CHIPS DE CATEGORIA
  // -----------------------------------------------------------------
  Widget _filtros() {
    if (_categorias.isEmpty) return const SizedBox(height: 20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),

        // ListView horizontal: os chips deslizam para o lado quando não
        // cabem todos na largura da tela.
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categorias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final categoria = _categorias[i];
              final ativo = categoria == _categoriaAtual;

              return GestureDetector(
                onTap: () {
                  setState(() => _categoriaAtual = categoria);
                  _carregarDados();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ativo ? AppCores.laranja : AppCores.superficie,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ativo ? AppCores.laranja : AppCores.borda,
                    ),
                  ),
                  child: Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ativo ? Colors.white : AppCores.textoSuave,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              const Text(
                'Pratos em destaque',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppCores.texto,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${_pratos.length} itens',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppCores.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------
  // GRADE DE PRATOS
  // -----------------------------------------------------------------
  Widget _grade() {
       return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      // SliverGrid monta as duas colunas do protótipo. childAspectRatio
      // controla a proporção do cartão (largura ÷ altura).
      sliver: SliverGrid(          // <-- era "child:", troque para "sliver:"
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _cartao(_pratos[index]),
          childCount: _pratos.length,
        ),
      ),
    );
  }

  Widget _cartao(Map<String, dynamic> prato) {
    final preco = (prato['res_vl_preco'] as num?)?.toDouble() ?? 0;
    final nota = (prato['res_nu_ranking'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () => _abrirDetalhe(prato),
      child: Container(
        decoration: BoxDecoration(
          color: AppCores.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppCores.borda),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto ocupando o topo do cartão.
            Padding(
              padding: const EdgeInsets.all(8),
              child: FotoPrato(
                asset: prato['res_nm_asset'] as String?,
                caminhoLocal: prato['res_im_foto'] as String?,
                altura: 106,
                raio: 11,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prato['res_nm_restaurante'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: AppCores.texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    NotaAvaliacao(nota: nota, tamanho: 11.5),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatarReal(preco),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppCores.laranja,
                            ),
                          ),
                        ),
                        // Botão "+" circular do protótipo.
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppCores.laranja,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // ESTADO VAZIO
  // -----------------------------------------------------------------
  Widget _listaVazia() {
    // A mensagem muda conforme o motivo de a lista estar vazia: nenhum
    // resultado para a busca é diferente de nenhum prato cadastrado.
    final filtrando = _busca.isNotEmpty || _categoriaAtual != 'Todos';

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            filtrando ? Icons.search_off_rounded : Icons.ramen_dining_outlined,
            size: 56,
            color: AppCores.textoClaro,
          ),
          const SizedBox(height: 18),
          Text(
            filtrando ? 'Nenhum prato encontrado' : 'Seu ranking está vazio',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppCores.texto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filtrando
                ? 'Tente outro termo de busca ou volte para a categoria Todos.'
                : 'Toque no botão + para cadastrar o primeiro prato.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppCores.textoSuave,
            ),
          ),
        ],
      ),
    );
  }
}
