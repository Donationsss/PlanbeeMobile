import 'dart:math';

import 'package:flutter/material.dart';
import 'package:planbeemobile/alterar_senha.dart';

import 'data/auth_service.dart';

/// Recuperação de senha.
///
/// Fluxo 100% local (sem serviço de e-mail): o usuário informa o e-mail,
/// o app gera um código de verificação que é mostrado na tela, o usuário
/// digita o código e, em seguida, troca a senha pelo mini formulário.
class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;
  String? _codigo; // código de verificação (fluxo local)
  int _etapa = 0; // 0 = e-mail, 1 = código

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (_carregando) return;
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _erro = 'Digite seu email.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _erro = 'Digite um email válido.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.recuperarAcesso(email);
      // Fluxo local: sem e-mail real, o código aparece direto na tela.
      final codigo = List.generate(6, (_) => Random().nextInt(10)).join();
      if (!mounted) return;
      setState(() {
        _codigo = codigo;
        _etapa = 1;
      });
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (e, st) {
      if (mounted) {
        setState(() => _erro = AuthService.mensagemInesperada(
            'Não foi possível gerar o código. Tente novamente.', e, st));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _verificarCodigo() async {
    if (_carregando) return;
    final codigo = _codigoCtrl.text.trim();
    if (codigo.isEmpty) {
      setState(() => _erro = 'Digite o código recebido.');
      return;
    }
    if (codigo != _codigo) {
      setState(() => _erro = 'Código inválido. Tente novamente.');
      return;
    }

    // Código confirmado: segue para a mini página de troca de senha.
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlterarSenha(email: _emailCtrl.text.trim()),
      ),
    );
    if (!mounted) return;
    // Volta para a recuperação (e-mail/código) quando a senha for trocada.
    setState(() {
      _etapa = 0;
      _codigoCtrl.clear();
      _erro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDA5E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    width: 100,
                    height: 100,
                  ),
                  const Text(
                    "Planbee",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  spacing: 30,
                  children: [
                    Column(
                      children: [
                        Text(
                          _etapa == 0 ? 'Recuperação de senha' : 'Verificação de código',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 350,
                          child: Text(
                            _etapa == 0
                                ? 'Informe seu email para começar.'
                                : 'Digite o código que foi enviado.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_etapa == 0)
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              decoration: InputDecoration(
                                labelText: "Email",
                                suffixIcon: const Icon(Icons.mail),
                                hintText: "Digite seu email",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        if (_etapa == 1) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: _codigoCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.center,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: "Código",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (_codigo != null)
                            Text('Código de verificação: $_codigo',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8)),
                        ],
                        if (_erro != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 350,
                              child: Text(
                                _erro!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color(0xFFB00020),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (_etapa == 0)
                          ElevatedButton(
                            onPressed: _carregando ? null : _enviarCodigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCB20),
                              elevation: 10,
                              fixedSize: const Size(150, 50),
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.black),
                                  )
                                : const Text("Enviar código",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                          ),
                        if (_etapa == 1)
                          ElevatedButton(
                            onPressed: _carregando ? null : _verificarCodigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCB20),
                              elevation: 10,
                              fixedSize: const Size(150, 50),
                            ),
                            child: _carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.black),
                                  )
                                : const Text("Verificar código",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
