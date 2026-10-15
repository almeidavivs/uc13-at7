/// Guarda os dados do usuário que fez login, para que qualquer tela possa
/// consultá-los sem precisar receber tudo por parâmetro.
///
/// É uma solução simples e suficiente para o tamanho deste aplicativo. Em
/// projetos maiores, o mesmo papel seria feito por um gerenciador de estado.
class Sessao {
  static int? id;
  static String nome = 'visitante';
  static String email = '';
  static String telefone = '';
  static String endereco = 'Endereço não informado';
  static double saldo = 0;

  /// Preenche a sessão a partir da linha retornada pelo banco.
  static void entrar(Map<String, dynamic> usuario) {
    id = usuario['usu_id_usuario'] as int?;
    nome = (usuario['usu_nm_usuario'] as String?) ?? 'visitante';
    email = (usuario['usu_ds_email'] as String?) ?? '';
    telefone = (usuario['usu_ds_telefone'] as String?) ?? '';
    endereco =
        (usuario['usu_ds_endereco'] as String?) ?? 'Endereço não informado';
    saldo = ((usuario['usu_vl_saldo'] as num?) ?? 0).toDouble();
  }

  /// Limpa os dados ao sair da conta.
  static void sair() {
    id = null;
    nome = 'visitante';
    email = '';
    telefone = '';
    endereco = 'Endereço não informado';
    saldo = 0;
  }

  /// Primeiro nome, usado na saudação do topo da tela inicial.
  static String get primeiroNome => nome.split(' ').first;

  /// Iniciais para o avatar, quando não há foto.
  static String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }
}
