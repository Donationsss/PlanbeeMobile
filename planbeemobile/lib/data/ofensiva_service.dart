import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Situação da ofensiva de um usuário.
class Ofensiva {
  /// Número mostrado ao lado do favo.
  final int sequencia;

  /// Dias da semana atual em que o usuário entrou: índice 0 = segunda ... 6 = domingo.
  final List<bool> semana;

  const Ofensiva({required this.sequencia, required this.semana});

  static Ofensiva vazia() =>
      Ofensiva(sequencia: 0, semana: List<bool>.filled(7, false));
}

/// Ofensiva no estilo Duolingo.
///
/// Regras:
///  - Entrar no app no mesmo dia não muda nada.
///  - Entrar em dias seguidos soma 1 e a bolinha do dia fica verde.
///  - Ficar [diasSemEntrarParaPerder] dias COMPLETOS sem entrar zera a
///    ofensiva (volta a 1 no próximo acesso). Pular só 1 dia é perdoado.
///
/// Exemplo (último acesso na segunda):
///   terça        -> +1
///   quarta       -> +1 (pulou só a terça)
///   quinta+      -> zera (pulou terça e quarta)
class OfensivaService {
  OfensivaService._();

  static const diasSemEntrarParaPerder = 2;

  /// Chame ao abrir o app/tela inicial. É seguro chamar várias vezes no mesmo dia.
  static Future<Ofensiva> registrarAcesso(int usuarioId,
      {DateTime? agora}) async {
    final db = await AppDatabase.instance.db;
    final hoje = _soData(agora ?? DateTime.now());

    await db.transaction((txn) async {
      final r = await txn.query('ofensiva',
          where: 'usuario_id = ?', whereArgs: [usuarioId], limit: 1);

      var sequencia = 1;
      if (r.isNotEmpty) {
        final atual = r.first['sequencia'] as int;
        final ultimo = _ler(r.first['ultimo_dia'] as String);
        final diff = hoje.difference(ultimo).inDays;

        if (diff <= 0) return; // já entrou hoje (ou o relógio voltou)

        final diasSemEntrar = diff - 1;
        sequencia =
            diasSemEntrar >= diasSemEntrarParaPerder ? 1 : atual + 1;
      }

      await txn.insert(
        'ofensiva',
        {
          'usuario_id': usuarioId,
          'sequencia': sequencia,
          'ultimo_dia': _chave(hoje),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'ofensiva_dias',
        {'usuario_id': usuarioId, 'dia': _chave(hoje)},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });

    return ler(usuarioId, agora: agora);
  }

  /// Lê a ofensiva sem registrar acesso.
  static Future<Ofensiva> ler(int usuarioId, {DateTime? agora}) async {
    final db = await AppDatabase.instance.db;
    final hoje = _soData(agora ?? DateTime.now());

    final r = await db.query('ofensiva',
        where: 'usuario_id = ?', whereArgs: [usuarioId], limit: 1);
    if (r.isEmpty) return Ofensiva.vazia();

    // Se já passou tempo demais, a ofensiva está zerada (mesmo antes de entrar).
    final ultimo = _ler(r.first['ultimo_dia'] as String);
    final diasSemEntrar = hoje.difference(ultimo).inDays - 1;
    final sequencia = diasSemEntrar >= diasSemEntrarParaPerder
        ? 0
        : r.first['sequencia'] as int;

    final segunda = hoje.subtract(Duration(days: hoje.weekday - 1));
    final domingo = segunda.add(const Duration(days: 6));
    final dias = await db.query(
      'ofensiva_dias',
      columns: ['dia'],
      where: 'usuario_id = ? AND dia BETWEEN ? AND ?',
      whereArgs: [usuarioId, _chave(segunda), _chave(domingo)],
    );
    final visitados = dias.map((d) => d['dia'] as String).toSet();
    final semana = List<bool>.generate(
      7,
      (i) => visitados.contains(_chave(segunda.add(Duration(days: i)))),
    );

    return Ofensiva(sequencia: sequencia, semana: semana);
  }

  // ---- datas (sempre em UTC "só data", para a conta de dias não sofrer com fuso/horário de verão) ----

  static DateTime _soData(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static String _chave(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime _ler(String chave) {
    final p = chave.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }
}
