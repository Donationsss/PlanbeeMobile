import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Acesso único ao banco SQLite do Planbee.
///
/// Tabelas:
///  - usuarios            contas de login
///  - config              chave/valor (guarda o usuário logado)
///  - materias_rotina     matérias lançadas em cada dia da semana
///  - sessoes_estudo      estudos salvos (com anotação)
///  - anotacoes_calendario anotações por data
///  - ofensiva            sequência de dias seguidos de cada usuário
///  - ofensiva_dias       dias em que o usuário entrou no app
///
/// Todas as tabelas de dados têm usuario_id, então cada conta enxerga
/// só o que é seu. Ao apagar um usuário, os dados dele são apagados junto.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _nomeArquivo = 'planbee.db';
  static const _versao = 2;

  Future<Database>? _abrindo;

  Future<Database> get db {
    return _abrindo ??= _abrir().catchError((Object e, StackTrace st) {
      // Não guarda a falha: a próxima chamada tenta abrir de novo.
      _abrindo = null;
      throw e;
    });
  }

  Future<Database> _abrir() async {
    final caminho = p.join(await getDatabasesPath(), _nomeArquivo);
    return openDatabase(
      caminho,
      version: _versao,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _criar,
      onUpgrade: _atualizar,
    );
  }

  Future<void> _criar(Database db, int versao) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE usuarios (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nome        TEXT NOT NULL,
        email       TEXT NOT NULL UNIQUE,
        senha_hash  TEXT NOT NULL,
        salt        TEXT NOT NULL,
        criado_em   TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE config (
        chave TEXT PRIMARY KEY,
        valor TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE materias_rotina (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        dia         INTEGER NOT NULL CHECK (dia BETWEEN 0 AND 6),
        nome        TEXT NOT NULL,
        cor         INTEGER NOT NULL,
        ordem       INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute('''
      CREATE UNIQUE INDEX idx_materia_unica
      ON materias_rotina (usuario_id, dia, nome COLLATE NOCASE)
    ''');

    batch.execute('''
      CREATE TABLE sessoes_estudo (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        materia     TEXT NOT NULL,
        tipo        TEXT NOT NULL,
        assunto     TEXT NOT NULL,
        segundos    INTEGER NOT NULL,
        cor         INTEGER,
        anotacao    TEXT NOT NULL DEFAULT '',
        criado_em   TEXT NOT NULL
      )
    ''');
    batch.execute(
        'CREATE INDEX idx_sessoes_usuario ON sessoes_estudo (usuario_id, id)');

    batch.execute('''
      CREATE TABLE anotacoes_calendario (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        data        TEXT NOT NULL,
        texto       TEXT NOT NULL,
        criado_em   TEXT NOT NULL
      )
    ''');
    batch.execute(
        'CREATE INDEX idx_anotacoes_usuario_data ON anotacoes_calendario (usuario_id, data)');

    _tabelasOfensiva(batch);

    await batch.commit(noResult: true);
  }

  void _tabelasOfensiva(Batch batch) {
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ofensiva (
        usuario_id  INTEGER PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
        sequencia   INTEGER NOT NULL,
        ultimo_dia  TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS ofensiva_dias (
        usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        dia         TEXT NOT NULL,
        PRIMARY KEY (usuario_id, dia)
      )
    ''');
  }

  Future<void> _atualizar(Database db, int antiga, int nova) async {
    if (antiga < 2) {
      final batch = db.batch();
      _tabelasOfensiva(batch);
      await batch.commit(noResult: true);
    }
  }

  // ---- config (chave/valor) ----

  Future<String?> lerConfig(String chave) async {
    final d = await db;
    final r = await d.query('config',
        where: 'chave = ?', whereArgs: [chave], limit: 1);
    return r.isEmpty ? null : r.first['valor'] as String?;
  }

  Future<void> salvarConfig(String chave, String? valor) async {
    final d = await db;
    if (valor == null) {
      await d.delete('config', where: 'chave = ?', whereArgs: [chave]);
    } else {
      await d.insert('config', {'chave': chave, 'valor': valor},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
