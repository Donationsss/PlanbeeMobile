import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../anotacoes_store.dart';
import '../estudos_store.dart';
import '../rotina_store.dart';
import 'app_database.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;

  /// Foto de perfil em base64 (já redimensionada ao escolher).
  /// Null (ou vazia) = usa o ícone padrão de usuário.
  final String? foto;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.foto,
  });

  /// Bytes da foto prontos para o Image.memory, ou null se não houver.
  Uint8List? get fotoBytes {
    final dados = foto;
    if (dados == null || dados.isEmpty) return null;
    try {
      return base64Decode(dados);
    } catch (_) {
      return null;
    }
  }
}

/// Erro com mensagem pronta para mostrar ao usuário.
class AuthException implements Exception {
  final String mensagem;
  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cadastro, login e sessão. As contas ficam no SQLite do aparelho;
/// a senha nunca é guardada em texto: só o hash SHA-256 com um sal único.
class AuthService {
  AuthService._();

  /// Mensagem para erros inesperados. Em modo debug inclui o erro real,
  /// para facilitar descobrir o que houve (plugin, plataforma, banco...).
  static String mensagemInesperada(String base, Object erro, StackTrace st) {
    debugPrint('[Planbee] $base\n$erro\n$st');
    if (!kDebugMode) return base;
    return '$base\n[debug] ${erro.runtimeType}: $erro';
  }

  static const _chaveSessao = 'usuario_logado';

  /// Usuário logado. É um ValueNotifier para que o avatar do appbar (e a
  /// tela de perfil) se atualizem sozinhos quando a foto muda.
  static final ValueNotifier<Usuario?> _usuario = ValueNotifier<Usuario?>(null);

  static Usuario? get usuario => _usuario.value;

  static set usuario(Usuario? u) => _usuario.value = u;

  static ValueListenable<Usuario?> get usuarioListenable => _usuario;

  static bool get logado => usuario != null;

  static bool emailValido(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  static String _novoSal() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static String _hash(String senha, String sal) =>
      sha256.convert(utf8.encode('$sal:$senha')).toString();

  static Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
    bool iniciarSessao = true,
  }) async {
    final n = nome.trim();
    final e = email.trim().toLowerCase();

    if (e.isEmpty || !emailValido(e)) {
      throw const AuthException('Digite um email válido.');
    }
    if (n.length < 2) {
      throw const AuthException('Digite um nome de usuário (mínimo 2 letras).');
    }
    if (senha.length < 6) {
      throw const AuthException('A senha precisa ter pelo menos 6 caracteres.');
    }

    final db = await AppDatabase.instance.db;
    final existe = await db.query('usuarios',
        columns: ['id'], where: 'email = ?', whereArgs: [e], limit: 1);
    if (existe.isNotEmpty) {
      throw const AuthException('Já existe uma conta com esse email.');
    }

    final sal = _novoSal();
    final id = await db.insert('usuarios', {
      'nome': n,
      'email': e,
      'senha_hash': _hash(senha, sal),
      'salt': sal,
      'criado_em': DateTime.now().toIso8601String(),
    });

    final u = Usuario(id: id, nome: n, email: e);
    if (!iniciarSessao) return u; // só cria a conta, sem logar
    try {
      await _iniciarSessao(u);
    } catch (_) {
      // Não deixa uma conta "meio criada" para trás.
      usuario = null;
      await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
      rethrow;
    }
    return u;
  }

  static Future<Usuario> entrar({
    required String email,
    required String senha,
  }) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty || senha.isEmpty) {
      throw const AuthException('Preencha email e senha.');
    }

    final db = await AppDatabase.instance.db;
    final r = await db.query('usuarios',
        where: 'email = ?', whereArgs: [e], limit: 1);

    // Mesma mensagem para email inexistente e senha errada.
    const erro = AuthException('Email ou senha incorretos.');
    if (r.isEmpty) throw erro;
    final linha = r.first;
    if (_hash(senha, linha['salt'] as String) != linha['senha_hash']) {
      throw erro;
    }

    final u = Usuario(
      id: linha['id'] as int,
      nome: linha['nome'] as String,
      email: linha['email'] as String,
      foto: linha['foto'] as String?,
    );
    await _iniciarSessao(u);
    return u;
  }

  /// Fluxo local de recuperação: verifica se o e-mail existe na conta do
  /// aparelho. O "código de verificação" é gerado pelo próprio app e mostrado
  /// na tela — não há envio de e-mail.
  static Future<Usuario> recuperarAcesso(String email) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) throw const AuthException('Digite seu email.');
    if (!emailValido(e)) throw const AuthException('Digite um email válido.');
    final db = await AppDatabase.instance.db;
    final r = await db.query('usuarios',
        where: 'email = ?', whereArgs: [e], limit: 1);
    if (r.isEmpty) throw const AuthException('Email não cadastrado.');
    final linha = r.first;
    return Usuario(
      id: linha['id'] as int,
      nome: linha['nome'] as String,
      email: linha['email'] as String,
      foto: linha['foto'] as String?,
    );
  }

  /// Troca a senha do usuário (fluxo de recuperação local).
  static Future<void> trocarSenha({
    required String email,
    required String novaSenha,
  }) async {
    final e = email.trim().toLowerCase();
    if (novaSenha.length < 6) {
      throw const AuthException('A senha precisa ter pelo menos 6 caracteres.');
    }
    final db = await AppDatabase.instance.db;
    final r = await db.query('usuarios',
        where: 'email = ?', whereArgs: [e], limit: 1);
    if (r.isEmpty) throw const AuthException('Email não cadastrado.');
    final sal = _novoSal();
    await db.update('usuarios', {
      'senha_hash': _hash(novaSenha, sal),
      'salt': sal,
    }, where: 'id = ?', whereArgs: [r.first['id'] as int]);
  }

  /// Chamado ao abrir o app: reentra sozinho se já havia alguém logado.
  static Future<bool> restaurarSessao() async {
    try {
      final id = int.tryParse(await AppDatabase.instance.lerConfig(_chaveSessao) ?? '');
      if (id == null) return false;

      final db = await AppDatabase.instance.db;
      final r = await db.query('usuarios',
          where: 'id = ?', whereArgs: [id], limit: 1);
      if (r.isEmpty) {
        await AppDatabase.instance.salvarConfig(_chaveSessao, null);
        return false;
      }

      usuario = Usuario(
        id: id,
        nome: r.first['nome'] as String,
        email: r.first['email'] as String,
        foto: r.first['foto'] as String?,
      );
      await _carregarDados(id);
      return true;
    } catch (e, st) {
      debugPrint('[Planbee] Falha ao restaurar a sessão\n$e\n$st');
      usuario = null;
      return false;
    }
  }

  static Future<void> sair() async {
    usuario = null;
    await AppDatabase.instance.salvarConfig(_chaveSessao, null);
    rotinaStore.limpar();
    estudosStore.limpar();
    anotacoesStore.limpar();
  }

  /// Troca (ou remove, passando null) a foto de perfil do usuário logado.
  /// [fotoBase64] deve vir já redimensionada para não inchar o banco.
  static Future<void> atualizarFoto(String? fotoBase64) async {
    final atual = usuario;
    if (atual == null) throw const AuthException('Nenhum usuário logado.');

    final db = await AppDatabase.instance.db;
    await db.update(
      'usuarios',
      {'foto': fotoBase64},
      where: 'id = ?',
      whereArgs: [atual.id],
    );

    usuario = Usuario(
      id: atual.id,
      nome: atual.nome,
      email: atual.email,
      foto: fotoBase64,
    );
  }

  static Future<void> _iniciarSessao(Usuario u) async {
    usuario = u;
    await AppDatabase.instance.salvarConfig(_chaveSessao, '${u.id}');
    await _carregarDados(u.id);
  }

  static Future<void> _carregarDados(int id) async {
    await Future.wait([
      rotinaStore.carregar(id),
      estudosStore.carregar(id),
      anotacoesStore.carregar(id),
    ]);
  }
}
