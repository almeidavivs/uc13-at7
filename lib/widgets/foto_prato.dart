import 'dart:io';
import 'package:flutter/material.dart';
import '../tema/app_cores.dart';

/// Exibe a foto de um prato seguindo três tentativas, nesta ordem:
///
/// 1. [caminhoLocal] — foto tirada pela câmera e salva no aparelho;
/// 2. [asset] — arquivo dentro de `assets/images/`;
/// 3. um bloco cinza com ícone, quando nenhuma das duas existe.
///
/// Graças ao passo 3, o aplicativo roda normalmente mesmo com a pasta
/// `assets/images/` vazia. Basta colocar os arquivos lá depois.
class FotoPrato extends StatelessWidget {
  final String? asset;
  final String? caminhoLocal;
  final double? altura;
  final double raio;
  final IconData icone;

  const FotoPrato({
    super.key,
    this.asset,
    this.caminhoLocal,
    this.altura,
    this.raio = 14,
    this.icone = Icons.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(
        height: altura,
        width: double.infinity,
        child: _conteudo(),
      ),
    );
  }

  Widget _conteudo() {
    // 1. Foto capturada pela câmera.
    if (caminhoLocal != null && caminhoLocal!.isNotEmpty) {
      final arquivo = File(caminhoLocal!);
      if (arquivo.existsSync()) {
        return Image.file(arquivo, fit: BoxFit.cover);
      }
    }

    // 2. Imagem da pasta assets. O errorBuilder evita que o app quebre
    //    quando o arquivo ainda não foi adicionado ao projeto.
    if (asset != null && asset!.isNotEmpty) {
      return Image.asset(
        'assets/images/$asset',
        fit: BoxFit.cover,
        errorBuilder: (context, erro, pilha) => _placeholder(),
      );
    }

    // 3. Nenhuma imagem disponível.
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppCores.superficieAlt,
      child: Center(
        child: Icon(icone, size: 32, color: AppCores.textoClaro),
      ),
    );
  }
}
