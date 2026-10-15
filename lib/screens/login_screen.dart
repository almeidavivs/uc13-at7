import 'package:flutter/material.dart';
// Classe que contém a lógica de conexão com o banco de dados SQLite.
import '../database/database_helper.dart';
import '../database/sessao.dart';
// Tela principal, para onde o usuário vai após o login.
import 'home_screen.dart';
import 'criar_conta_screen.dart';
import '../tema/app_cores.dart';
import '../widgets/comuns.dart';

/// Tela de Login. O usuário se identifica com e-mail e senha, que são
/// conferidos na tabela 'usuario' do SQLite.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController "captura" o texto que o usuário digita nos campos.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // Controla se a senha aparece como pontinhos (true) ou em texto claro.
  bool _senhaOculta = true;

  // Controla o estado de carregamento enquanto consultamos o banco.
  bool _carregando = false;

  // Libera os controllers da memória quando a tela é fechada.
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Função assíncrona que conecta a tela com a regra de negócio do banco.
  Future<void> _fazerLogin() async {
    final String email = _emailController.text.trim();
    final String senha = _senhaController.text;

    // Validação simples antes de ir ao banco: campos vazios nem chegam lá.
    if (email.isEmpty || senha.isEmpty) {
      _avisar('Preencha o e-mail e a senha para entrar.');
      return;
    }

    // setState avisa o Flutter para redesenhar a tela mostrando o loading.
    setState(() => _carregando = true);

    // 'await' porque o app precisa esperar o banco responder antes de seguir.
    final usuario =
        await DatabaseHelper.instancia.autenticarUsuario(email, senha);

    if (!mounted) return;
    setState(() => _carregando = false);

    // Verifica se a resposta do banco retornou dados (login válido) ou null.
    if (usuario != null) {
      // Guarda os dados do usuário para as demais telas consultarem.
      Sessao.entrar(usuario);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Login falhou: mostramos um SnackBar (aviso rápido no rodapé).
      _avisar('E-mail ou senha inválidos.');
    }
  }

  Future<void> _abrirCriarConta() async {
    // O 'await' aqui espera a tela de cadastro ser fechada. Se ela devolver
    // um e-mail, já preenchemos o campo para o usuário só digitar a senha.
    final emailCriado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CriarContaScreen()),
    );

    if (emailCriado != null && mounted) {
      setState(() => _emailController.text = emailCriado);
    }
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      // SafeArea impede que o conteúdo fique sob a barra de status.
      body: SafeArea(
        // SingleChildScrollView permite rolar a tela quando o teclado sobe.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------------------------------------------------------
              // MARCA
              // ------------------------------------------------------
              Center(
                child: Image.asset(
                  'assets/images/logo_horizontal.jpg',
                  width: 300,
                  height: 96,
                            ),
                ),

              const SizedBox(height: 28),

              const Text(
                'Veja o que temos de novidade para você!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppCores.texto,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Conheça melhor nossos pratos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppCores.textoSuave),
              ),

              const SizedBox(height: 36),

              // ------------------------------------------------------
              // CAMPO DE E-MAIL
              // ------------------------------------------------------
              const RotuloCampo('E-mail'),
              TextField(
                controller: _emailController,
                // Exibe o teclado com "@" para facilitar a digitação.
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'seuemail@exemplo.com',
                  prefixIcon: Icon(Icons.mail_outline, size: 20),
                ),
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------------
              // CAMPO DE SENHA
              // ------------------------------------------------------
              const RotuloCampo('Senha'),
              TextField(
                controller: _senhaController,
                // obscureText: true faz a senha aparecer como pontinhos.
                obscureText: _senhaOculta,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  // Ícone que mostra ou esconde a senha digitada.
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaOculta
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color.fromARGB(255, 255, 72, 0),
                    ),
                    onPressed: () {
                      setState(() => _senhaOculta = !_senhaOculta);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _avisar(
                    'Recuperação de senha ainda não implementada.',
                  ),
                  child: const Text('Esqueci minha senha'),
                ),
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------------
              // BOTÃO ENTRAR
              // ------------------------------------------------------
              // Enquanto _carregando for true, o onPressed fica nulo (botão
              // desabilitado) e mostramos a rodinha de progresso.
              ElevatedButton(
                onPressed: _carregando ? null : _fazerLogin,
                child: _carregando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 253, 82, 2)),
                        ),
                      )
                    : const Text('Entrar'),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ainda não tem conta?',
                    style: TextStyle(color: AppCores.textoSuave),
                  ),
                  TextButton(
                    onPressed: _abrirCriarConta,
                    child: const Text(
                      'Criar conta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lembrete do usuário de teste criado no DatabaseHelper.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppCores.superficieAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppCores.borda),
                ),
                child: const Text(
                  'Acesso de teste\nmaria@comabem.com  ·  123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: AppCores.textoSuave,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
