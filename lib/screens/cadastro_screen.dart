import 'package:flutter/material.dart';
// Pacote que acessa o hardware da câmera.
import 'package:image_picker/image_picker.dart';
// Pacote que acessa o hardware de GPS.
import 'package:geolocator/geolocator.dart';
// Lida com o sistema de arquivos do aparelho (para exibir a foto).
import 'dart:io';
// Motor de banco de dados, para fazermos o INSERT.
import '../database/database_helper.dart';
import '../tema/app_cores.dart';
import '../widgets/comuns.dart';

/// Formulário de cadastro de prato, com foto pela câmera e coordenadas
/// capturadas pelo GPS do aparelho.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  // Controladores de texto para ler o que o usuário digita nos campos.
  final _nomeController = TextEditingController();
  final _culinariaController = TextEditingController();
  final _precoController = TextEditingController();
  final _rankingController = TextEditingController();
  final _descricaoController = TextEditingController();

  // Categoria escolhida no seletor.
  String _categoria = 'Massas';
  final List<String> _categorias = const [
    'Massas',
    'Saladas',
    'Carnes',
    'Sobremesas',
    'Bebidas',
  ];

  // A variável _fotoPrato é do tipo File e guarda o caminho da foto no
  // aparelho. A interrogação '?' significa que ela pode iniciar nula.
  File? _fotoPrato;

  // Variáveis para guardar as coordenadas de GPS.
  String _latitude = '';
  String _longitude = '';

  bool _buscandoLocalizacao = false;
  bool _salvando = false;

  // Instância do ImagePicker, que lida com a requisição da câmera.
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomeController.dispose();
    _culinariaController.dispose();
    _precoController.dispose();
    _rankingController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // CÂMERA
  // ---------------------------------------------------------------
  Future<void> _tirarFoto(ImageSource origem) async {
    // pickImage abre a câmera (ImageSource.camera) ou a galeria de
    // imagens (ImageSource.gallery) do dispositivo.
    final XFile? fotoCapturada =
        await _picker.pickImage(source: origem, imageQuality: 70);

    // Se o usuário tirou a foto (não cancelou a ação)...
    if (fotoCapturada != null) {
      setState(() {
        // Converte o arquivo retornado em um objeto File.
        _fotoPrato = File(fotoCapturada.path);
      });
    }
  }

  /// Deixa o usuário escolher entre câmera e galeria.
  void _escolherOrigemFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppCores.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppCores.laranja),
              title: const Text('Tirar foto com a câmera'),
              onTap: () {
                Navigator.pop(context);
                _tirarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppCores.laranja),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _tirarFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // GEOLOCALIZAÇÃO
  // ---------------------------------------------------------------
  Future<void> _pegarLocalizacao() async {
    setState(() => _buscandoLocalizacao = true);

    // 1. O GPS do aparelho está ligado?
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      if (!mounted) return;
      setState(() => _buscandoLocalizacao = false);
      _avisar('Ative a localização do aparelho para continuar.');
      return;
    }

    // 2. O usuário já autorizou o app a usar o GPS?
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => _buscandoLocalizacao = false);
      _avisar('Permissão de localização negada.');
      return;
    }

    // 3. Com o serviço ligado e a permissão concedida, lemos a posição.
    final Position posicao = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() {
      _latitude = posicao.latitude.toStringAsFixed(6);
      _longitude = posicao.longitude.toStringAsFixed(6);
      _buscandoLocalizacao = false;
    });
  }

  // ---------------------------------------------------------------
  // SALVAR NO BANCO
  // ---------------------------------------------------------------
  Future<void> _salvarCadastro() async {
    if (_nomeController.text.trim().isEmpty ||
        _culinariaController.text.trim().isEmpty) {
      _avisar('Informe o nome do prato e o tipo de culinária.');
      return;
    }

    // Aceita tanto "32,90" quanto "32.90".
    final preco = double.tryParse(
      _precoController.text.trim().replaceAll(',', '.'),
    );
    if (preco == null || preco <= 0) {
      _avisar('Informe um preço válido, como 32,90.');
      return;
    }

    final nota = double.tryParse(
      _rankingController.text.trim().replaceAll(',', '.'),
    );
    if (nota == null || nota < 1 || nota > 5) {
      _avisar('O ranking deve ser um número de 1 a 5.');
      return;
    }

    setState(() => _salvando = true);

    // Mapa que representa uma linha do banco. As chaves precisam ser
    // idênticas aos nomes das colunas da tabela 'restaurante'.
    final Map<String, dynamic> dadosRestaurante = {
      'res_nm_restaurante': _nomeController.text.trim(),
      'res_ds_tipo_culinaria': _culinariaController.text.trim(),
      'res_ds_categoria': _categoria,
      'res_vl_preco': preco,
      'res_nu_ranking': nota,
      'res_nu_avaliacoes': 1,
      'res_ds_recomendacao': _descricaoController.text.trim(),
      'res_nu_latitude': _latitude, // Coordenada vinda do hardware de GPS
      'res_nu_longitude': _longitude, // Coordenada vinda do hardware de GPS
      'res_im_foto': _fotoPrato?.path ?? '', // Caminho da foto tirada
    };

    await DatabaseHelper.instancia
        .inserirDados('restaurante', dadosRestaurante);

    if (!mounted) return;
    setState(() => _salvando = false);

    _avisar('Prato cadastrado!');
    Navigator.pop(context);
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo,
      appBar: AppBar(title: const Text('Novo prato')),

      // SingleChildScrollView evita estouro de layout quando o teclado sobe.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------------------------------------------------------
            // FOTO DO PRATO
            // ------------------------------------------------------
            GestureDetector(
              onTap: _escolherOrigemFoto,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  color: AppCores.superficieAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppCores.borda,
                    // Borda tracejada não existe nativamente no Flutter;
                    // usamos uma borda simples um pouco mais grossa.
                    width: 1.4,
                  ),
                ),
                // Se _fotoPrato não for nula, desenhamos a imagem
                // capturada; se for, mostramos o convite para tirar a foto.
                child: _fotoPrato != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_fotoPrato!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: AppCores.textoClaro,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Toque para adicionar a foto do prato',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppCores.textoSuave,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (_fotoPrato != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _escolherOrigemFoto,
                    icon: const Icon(Icons.refresh, size: 17),
                    label: const Text('Trocar foto'),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _fotoPrato = null),
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: const Text('Remover'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppCores.textoSuave,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 26),

            // ------------------------------------------------------
            // DADOS DO PRATO
            // ------------------------------------------------------
            const RotuloCampo('Nome do prato'),
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex.: Fettuccine ao Pesto',
                prefixIcon: Icon(Icons.restaurant_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            const RotuloCampo('Tipo de culinária'),
            TextField(
              controller: _culinariaController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex.: Italiana',
                prefixIcon: Icon(Icons.public, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            const RotuloCampo('Categoria'),
            // DropdownButtonFormField herda o visual dos demais campos.
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, size: 20),
              ),
              items: _categorias
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor != null) setState(() => _categoria = valor);
              },
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RotuloCampo('Preço'),
                      TextField(
                        controller: _precoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '32,90',
                          prefixText: 'R\$  ',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RotuloCampo('Nota (1 a 5)'),
                      TextField(
                        controller: _rankingController,
                        // Teclado numérico com casa decimal.
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: '4,8',
                          prefixIcon: Icon(Icons.star_border, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const RotuloCampo('Descrição e recomendações'),
            TextField(
              controller: _descricaoController,
              // maxLines: 4 transforma o campo em caixa de texto livre.
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'O que torna esse prato especial?',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 26),

            // ------------------------------------------------------
            // GPS
            // ------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppCores.superficie,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppCores.borda),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 19,
                        color: AppCores.laranja,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Localização',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppCores.texto,
                        ),
                      ),
                      const Spacer(),
                      if (_latitude.isNotEmpty)
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppCores.verde,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _latitude.isEmpty
                        ? 'Nenhuma coordenada capturada ainda.'
                        : 'Lat $_latitude  ·  Long $_longitude',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppCores.textoSuave,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed:
                        _buscandoLocalizacao ? null : _pegarLocalizacao,
                    icon: _buscandoLocalizacao
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppCores.laranja,
                            ),
                          )
                        : const Icon(Icons.my_location, size: 18),
                    label: Text(
                      _buscandoLocalizacao
                          ? 'Buscando sinal de GPS...'
                          : 'Obter localização atual',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _salvando ? null : _salvarCadastro,
              child: _salvando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Salvar prato'),
            ),
          ],
        ),
      ),
    );
  }
}
